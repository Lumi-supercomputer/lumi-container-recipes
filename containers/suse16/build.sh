#!/usr/bin/env bash
# Build the image and save it as an oci-archive for transfer to the cluster
# Usage: build.sh [PODMAN BUILD OPTIONS...], e.g. build.sh --build-arg MPICH_RELEASE=5.0.3 --build-arg MPICH_SHA256=...
SCRIPTDIR=$(realpath "$(dirname "$0")")
CONTAINER_NAME=$(basename $(realpath "$(dirname "$0")"))

[[ ! -e "$CONTAINER_NAME".tar ]] || { echo "$CONTAINER_NAME.tar exists. Remove it first."; exit 1; }

# Hash of the build files. A label set here does not invalidate cached layers, unlike a LABEL in the Containerfile.
RECIPE_HASH=$(cat "$SCRIPTDIR"/build.sh "$SCRIPTDIR"/Containerfile | sha256sum | cut --delimiter=' ' --fields=1)

podman build \
    --file "$SCRIPTDIR"/Containerfile \
    --pull=newer \
    --label eu.lumi-supercomputer.image.recipe_hash="$RECIPE_HASH" \
    --tag "$CONTAINER_NAME" \
    "$@" \
    || {
        echo "Build failed. Press <Enter> to continue"
        read -r
        exit 1
    }

podman save --format oci-archive --output "$CONTAINER_NAME".tar "$CONTAINER_NAME"
