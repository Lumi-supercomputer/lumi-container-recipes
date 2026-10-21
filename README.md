# LUMI Container Recipes

A collection of container recipes for testing software stacks on high-performance computing systems.

## Building

```bash
# Ensure ACCOUNT is defined before calling
export SINGULARITY_TMPDIR="/tmp/$USER/singularity/tmp"
export SINGULARITY_CACHEDIR="/tmp/$USER/singularity/cache"
export SINGULARITY_IMAGEDIR="/scratch/$ACCOUNT/$USER/singularity/containers"
mkdir -p "$SINGULARITY_TMPDIR"
mkdir -p "$SINGULARITY_CACHEDIR"
mkdir -p "$SINGULARITY_IMAGEDIR"

singularity build "$SINGULARITY_IMAGEDIR/container.sif" container.def
```

## Running

```bash
singularity shell "$SINGULARITY_IMAGEDIR/container.sif"
```
