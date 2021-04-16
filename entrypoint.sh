#!/bin/bash

set -e

# setup a regular user
USER_ID=${USER_ID:-30000}
GROUP_ID=${GROUP_ID:-30000}
groupadd -o --gid $GROUP_ID group
useradd -o --uid $USER_ID --gid $GROUP_ID --create-home --home-dir /user user

if [ "$1" = shell ]; then
    shift
    exec bash -- "$@"
fi

# populate home directory on first run
if [ -z "$(ls -A ~user/.ghidra/)" ]; then
    chown -R user:group /preconfig/
    cp -r --preserve /preconfig/.ghidra/. ~user/.ghidra/
fi

RUN_SCRIPT=/ghidra/support/launch.sh
MAXMEM=${MAXMEM:-1G}
RUN_COMMAND=$(printf "%q " "$RUN_SCRIPT" fg Ghidra $MAXMEM "" ghidra.GhidraRun "$@")

exec su -c "$RUN_COMMAND" user
