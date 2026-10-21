#!/bin/bash
set -euxo pipefail

SINGULARITY_DEFDIR="$(realpath $(dirname "$0"))"

command -v proot || { echo "PRoot not found: module load CrayEnv PRoot"; exit 1; }

# Check that the required environment variables exist
[[ -n "$SINGULARITY_CACHEDIR" ]] || { echo "SINGULARITY_CACHEDIR not set"; exit 1; }
[[ -n "$SINGULARITY_TMPDIR"   ]] || { echo "SINGULARITY_TMPDIR not set"; exit 1; }
[[ -n "$SINGULARITY_IMAGEDIR" ]] || { echo "SINGULARITY_IMAGEDIR not set"; exit 1; }
