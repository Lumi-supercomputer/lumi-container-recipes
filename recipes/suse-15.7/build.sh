#!/bin/bash
set -euxo pipefail

SINGULARITY_DEFDIR="$(realpath $(dirname "$0"))"

# Check that PRoot and the required environment variables exist
command -v proot || { echo "PRoot not found: module load CrayEnv PRoot"; exit 1; }
[[ -n "$SINGULARITY_CACHEDIR" ]] || { echo "SINGULARITY_CACHEDIR not set"; exit 1; }
[[ -n "$SINGULARITY_TMPDIR"   ]] || { echo "SINGULARITY_TMPDIR not set"; exit 1; }
[[ -n "$SINGULARITY_IMAGEDIR" ]] || { echo "SINGULARITY_IMAGEDIR not set"; exit 1; }

# Build
singularity build "$SINGULARITY_DEFDIR"/01-rocm.sif 01-rocm.def
