#!/usr/bin/env bash

packarray=""
if [[ "$1" =~ \ |\' ]]
then
    packarray=true
    declare -a packages
    IFS=' ' read -r -a packages <<< "$1"
else
    packarray=false
    packages=$1
fi


for pkgname in ${packages[*]}
do
    echo "Syncing $pkgname dependencies..."
    #mv /home/builder/rebuild.log /home/builder/rebuild.log.old
    #for i in $( find .cache/aurutils/sync/*/.SRCINFO -exec grep -sm 1 "pkgname" {} \;|tr -d ' '|cut -d "=" -f 2 ); do
    #    echo
    #    echo "AURPACKAGE=" $i >> /home/builder/rebuild.log
    #    echo
    pkgbase=$( aur query -t info "$pkgname"|jq -r '.results[].PackageBase' )
    if [ ! -d /home/builder/.cache/aurutils/sync/"$pkgbase" ]; then
        cd /home/builder/.cache/aurutils/sync/|| exit 1
        git clone https://aur.archlinux.org/"$pkgbase".git || exit 1
    # else
        # cd /home/builder/.cache/aurutils/sync/"$pkgbase" || exit 1
    fi
    cd /home/builder/.cache/aurutils/sync/"$pkgbase" || exit 1
    git fetch
    git pull
    makepkg -soe --nocheck --noprepare --skipchecksums --skippgpcheck --noconfirm|| makepkg -so --nocheck --noprepare --skipchecksums --skippgpcheck --noconfirm || exit 1
    if [[ $Bump == true ]]; then
        # aur sync --makepkg-args --cleanbuild -A --noconfirm --noview --rebuild=.1 --sign --database Bitals --root /home/builder/bitalsrepo "$pkgname"|| exit 1
        
        c_pkgrel=$(grep "pkgrel=" PKGBUILD|cut -d "=" -f 2)
        n_pkgrel=$(bc <<< $c_pkgrel+0.1)
        echo "Bumping pkgrel with 0.1 ($n_pkgrel)"
        # sed -i "s/pkgrel=$c_pkgrel/pkgrel=$n_pkgrel/" PKGBUILD ||exit 1
        setconf -a PKGBUILD pkgrel=$n_pkgrel

        echo "Building $pkgname"
        aur build  --margs --noconfirm,--cleanbuild,--syncdeps --sign --database Bitals --root /home/builder/bitalsrepo "$pkgname"|| rebuild="failed"
        if [[ $rebuild == "failed" ]]; then
            echo "Rebuild for $pkgname failed, restoring original pkgrel" 
            # sed -i "s/pkgrel=$n_pkgrel/pkgrel=$c_pkgrel/" PKGBUILD ||exit 1
            setconf PKGBUILD pkgrel=$c_pkgrel
            exit 1
        fi
    else
        echo "Building $pkgname"
        aur sync --makepkg-args --cleanbuild -A --noconfirm --noview --rebuild --sign --database Bitals --root /home/builder/bitalsrepo "$pkgname"|| exit 1
    fi
done
#done
#sudo kill $( cat /opt/piavpn-manual/pia_pid )
