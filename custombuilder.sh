#!/usr/bin/env bash

echo Building "$OWNPACKAGE"...

cd /home/builder/workspace/AUR/"$OWNPACKAGE" || exit 1
#makepkg --printsrcinfo > .SRCINFO
#aur graph .SRCINFO | tsort | tac > queue
#repo-remove /home/builder/bitalsrepo/Bitals.db.tar.gz $OWNPACKAGE
# rm -rf /home/builder/bitalsrepo/$OWNPACKAGE.pkg.tar.zst
# rm -rf    $OWNPACKAGE.pkg.tar.zst.sig
# rm -rf /home/builder/
# rm -rf /home/builder/
deps=""
for i in $( grep "depends" .SRCINFO|grep -v optdepends|cut -d "=" -f 2|cut -d ":" -f 1 ); do
    deps+="$i "
done
sudo pacman -S --noconfirm $deps
if [[ $Bump == true ]]; then
    # aur sync --makepkg-args --cleanbuild -A --noconfirm --noview --rebuild=.1 --sign --database Bitals --root /home/builder/bitalsrepo "$pkgname"|| exit 1
    
    c_pkgrel=$(grep "pkgrel=" PKGBUILD|cut -d "=" -f 2)
    n_pkgrel=$(bc <<< $c_pkgrel+0.1)
    echo "Bumping pkgrel with 0.1 ($n_pkgrel)"
    # sed -i "s/pkgrel=$c_pkgrel/pkgrel=$n_pkgrel/" PKGBUILD ||exit 1
    setconf -a PKGBUILD pkgrel=$n_pkgrel

    echo "Building $pkgname"
    # aur build  --margs --noconfirm,--cleanbuild,--syncdeps --sign --database Bitals --root /home/builder/bitalsrepo "$pkgname"|| rebuild="failed"
    aur build -f --database Bitals --root /home/builder/bitalsrepo $OWNPACKAGE|| exit 1
    if [[ $rebuild == "failed" ]]; then
        echo "Rebuild for $pkgname failed, restoring original pkgrel" 
        # sed -i "s/pkgrel=$n_pkgrel/pkgrel=$c_pkgrel/" PKGBUILD ||exit 1
        setconf PKGBUILD pkgrel=$c_pkgrel
        exit 1
    fi
else
    echo "Building $pkgname"
    aur build -f --database Bitals --root /home/builder/bitalsrepo $OWNPACKAGE|| exit 1
fi

sudo pacman -Sy --noconfirm $OWNPACKAGE || exit 1
#sudo kill $( cat /opt/piavpn-manual/pia_pid )
