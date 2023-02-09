#!/bin/bash
readonly PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

source /usr/share/makepkg/util/message.sh || exit

if [[ -t 2 && ! -o xtrace ]]; then
    colorize
fi

# upgrade vcs packages to latest commits
if [[ $(aur vercmp-devel "$@" | tee updates) ]]; then
    printf "\n$(column -t updates)\n\n$(wc -l updates) found.  "
    cut -d\  -f1 updates > vcs.txt
    xargs -a vcs.txt aur sync --no-ver-argv --noconfirm --noview --sign "$@"
else
    msg2 "No updates found"
fi