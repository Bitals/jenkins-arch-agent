#!/usr/bin/env bash

gpg --import $BITALSARK
gpg --fingerprint B85CCC7E84084D98FDCA5CB9619D32E653C5E767
if [[ -n "$PGPFINGER" ]]; then
    gpg --recv-keys $PGPFINGER
fi
if [[ -n "$PGPLINK" ]]; then
    curl $PGPLINK > "$AURPACKAGE"-key
    gpg --import "$AURPACKAGE"-key
fi

echo Updating pacman databases...
sudo pacman -Syy

#TODO: replace $AURPACKAGE and $OWNPACKAGE with $PACKAGE

#Check if we are dealing with an array
#Current Jenkins jobs are incapable of defining arrays, so I just convert strings to them if needed
packarray=""
if [[ "$AURPACKAGE" =~ \ |\' ]]
then
    packarray=true
    declare -a packages
    IFS=' ' read -r -a packages <<< "$AURPACKAGE"
else
    packarray=false
    packages=$AURPACKAGE
fi

# BASH is incapable of passing down arrays, so they have to be expanded here and re-arrayed again inside
# This is ugly, but I don't know of another in-memory solution
if [[ -z $Action ]] || [[ $Action == "default" ]]; then
    /opt/packagebuilder.sh "${packages[*]}" || exit 1
elif [[ $Action == "custom" ]]; then
    /opt/custombuilder.sh "${packages[*]}" || exit 1
elif [[ $Action == "force-rebuild" ]]; then
    /opt/rebuilder.sh "${packages[*]}" || exit 1
elif [[ $Action == "update-devel" ]]; then
    /opt/update-devel.sh "${packages[*]}" || exit 1
fi

#sudo pacman -Sc --noconfirm
#When aurutils will get a sane version number again
#sudo pacleaner -n 2 -m --delete --no-confirm
#TODO: write a custom sane cleaner affecting only the job package
