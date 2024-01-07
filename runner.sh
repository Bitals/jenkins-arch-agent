#!/usr/bin/env bash

cd /home/builder/.cache/aurutils/sync/"$AURPACKAGE"||exit 1
git clean -dfx

gpg --import $BITALSARK
gpg --fingerprint B85CCC7E84084D98FDCA5CB9619D32E653C5E767

if [[ -n "$PGPFINGER" ]]; then
    gpg --recv-keys $PGPFINGER
fi
if [[ -n "$PGPLINK" ]]; then
    curl $PGPLINK > "$AURPACKAGE"-key
    gpg --import "$AURPACKAGE"-key
fi

if [[ -z $Action ]] || [[ $Action == "default" ]]; then
    /opt/packagebuilder.sh || exit 1
elif [[ $Action == "custom" ]]; then
    /opt/custombuilder.sh || exit 1
elif [[ $Action == "force-rebuild" ]]; then
    /opt/rebuilder.sh || exit 1
elif [[ $Action == "update-devel" ]]; then
    /opt/update-devel.sh || exit 1
fi

#sudo pacman -Sc --noconfirm
##When aurutils will get a sane version number again
#sudo pacleaner -n 2 -m --delete --no-confirm
#TODO: write a custom sane cleaner affecting only the job package