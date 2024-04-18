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
    echo Rebuilding "$pkgname"...
    #mv /home/builder/rebuild.log /home/builder/rebuild.log.old
    #for i in $( find .cache/aurutils/sync/*/.SRCINFO -exec grep -sm 1 "pkgname" {} \;|tr -d ' '|cut -d "=" -f 2 ); do
    #    echo
    #    echo "AURPACKAGE=" $i >> /home/builder/rebuild.log
    #    echo
    pkgbase=$( aur query -t info "$pkgname"|jq -r '.results[].PackageBase' )
    if [ ! -d /home/builder/.cache/aurutils/sync/"$pkgbase" ]; then
        cd /home/builder/.cache/aurutils/sync/|| exit 1
        git clone https://aur.archlinux.org/"$pkgbase".git || exit 1
    fi
    cd /home/builder/.cache/aurutils/sync/"$pkgbase" || exit 1
    makepkg -soe --nocheck --noprepare --skipchecksums --skippgpcheck --noconfirm|| makepkg -so --nocheck --noprepare --skipchecksums --skippgpcheck --noconfirm || exit 1
    aur sync --makepkg-args --cleanbuild -A --noconfirm --noview --rebuild --sign --database Bitals --root /home/builder/bitalsrepo "$pkgname"|| exit 1
done
#done
#sudo kill $( cat /opt/piavpn-manual/pia_pid )
