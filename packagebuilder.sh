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
  if [ $( echo "$pkgname"|rev|cut -d "-" -f 1|rev ) == "git" ]; then
    /opt/rebuilder.sh "$pkgname" || exit 1
  else
    echo Building "$pkgname"...
    aur sync -A --noconfirm --noview --sign --database Bitals --root /home/builder/bitalsrepo "$pkgname" || exit 1
    #TODO: refactor version feedback to Jenkins
    # echo $(grep -m 1 epoch= /home/builder/.cache/aurutils/sync/"$pkgname"/PKGBUILD|cut -d = -f 2):$(grep -m 1 pkgver= /home/builder/.cache/aurutils/sync/"$pkgname"/PKGBUILD|cut -d = -f 2)-$(grep -m 1 pkgrel= /home/builder/.cache/aurutils/sync/"$pkgname"/PKGBUILD|cut -d = -f 2) > jenkins-ver-info
    #sudo kill $( cat /opt/piavpn-manual/pia_pid )
  fi
done
