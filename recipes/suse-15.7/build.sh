#!/bin/bash
set -euxo pipefail

SINGULARITY_DEFDIR="$(realpath $(dirname "$0"))"

# Check that PRoot and the required environment variables exist
command -v proot                 || { echo "PRoot not found: module load CrayEnv PRoot"; exit 1; }
[[ -n "$SINGULARITY_CACHEDIR" ]] || { echo "SINGULARITY_CACHEDIR not set"; exit 1; }
[[ -n "$SINGULARITY_TMPDIR"   ]] || { echo "SINGULARITY_TMPDIR not set";   exit 1; }
[[ -n "$SINGULARITY_IMAGEDIR" ]] || { echo "SINGULARITY_IMAGEDIR not set"; exit 1; }

# Build
singularity build "$SINGULARITY_IMAGEDIR"/01-base.sif "$SINGULARITY_DEFDIR"/01-base.def
singularity build --build-arg BASE_IMAGE="$SINGULARITY_IMAGEDIR"/01-base.sif "$SINGULARITY_IMAGEDIR"/02-rocm.sif "$SINGULARITY_DEFDIR"/02-rocm.def
singularity build --build-arg BASE_IMAGE="$SINGULARITY_IMAGEDIR"/02-rocm.sif "$SINGULARITY_IMAGEDIR"/03-mpich.sif "$SINGULARITY_DEFDIR"/03-mpich.def
