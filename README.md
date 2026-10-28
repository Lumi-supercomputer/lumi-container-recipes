# LUMI Container Recipes

A collection of container recipes for testing software stacks on high-performance computing systems.

## Directories

| Directory     | Description             |
|---------------|-------------------------|
| `recipes/`    | Singularity definitions |
| `containers/` | Podman Containerfiles   |

See `README.md` in each directory for more detailed instructions

## Temporary and cache directories

In typical use, `/tmp` and `/scratch` should be used for storing the intermediate files instead of `/home`.

On LUMI, this can be achieved with, e.g., the following definitions.

```bash
export SINGULARITY_TMPDIR="/tmp/$USER/singularity/tmp"
export SINGULARITY_CACHEDIR="/tmp/$USER/singularity/cache"
export SINGULARITY_IMAGEDIR="/scratch/$ACCOUNT/$USER/singularity/containers"
mkdir -p "$SINGULARITY_TMPDIR"
mkdir -p "$SINGULARITY_CACHEDIR"
mkdir -p "$SINGULARITY_IMAGEDIR"
```
