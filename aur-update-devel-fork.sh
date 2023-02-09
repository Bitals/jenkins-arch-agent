#!/bin/bash
readonly PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

source /usr/share/makepkg/util/message.sh || exit

if [[ -t 2 && ! -o xtrace ]]; then
    colorize
fi

# upgrade vcs packages to latest commits
if [[ $(aur vercmp-devel "$@" | tee updates) ]]; then
    printf "\n$(column -t updates)\n\n$(wc -l updates) found.  "
    read -r -p "Proceed? [y/N] " response
    case "$response" in
        [yY]|[yY][eE][sS])
            # If build dependences are not installed, then --noconfirm is
            # required, or the command will terminate at the y/N prompt for
            # installing the dependency
            cut -d\  -f1 updates > vcs.txt
            xargs -a vcs.txt aur sync --no-ver-argv --noconfirm --noview --sign "$@"
            ;;
    esac
else
    msg2 "No updates found"
fi