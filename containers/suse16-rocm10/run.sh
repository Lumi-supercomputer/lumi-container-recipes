#!/usr/bin/env bash
set -euo pipefail

CUSER=user
CUID=1001
CGID=1001
MEMORY=16g # Memory limit. --memory-swap is memory plus swap, so setting it equal to MEMORY disables swap.
CONTAINER_NAME=$(basename $(realpath "$(dirname "$0")"))

podman run --rm -it \
    --pull=never \
    --user "$CUID":"$CGID" \
    --tmpfs /home/"$CUSER":rw,mode=1777,size=1g \
    --env HOME=/home/"$CUSER" \
    --workdir /home/"$CUSER" \
    --security-opt=no-new-privileges \
    --read-only \
    --network=none \
    --cap-drop=ALL \
    --memory "$MEMORY" \
    --memory-swap "$MEMORY" \
    --hostname "$CONTAINER_NAME" \
    "$CONTAINER_NAME" \
    "$@" || { echo "Error. Press <Enter> to continue"; read -r; }
