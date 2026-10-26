# SUSE 15.7 image for LUMI

```bash
# Local
./build.sh                                     # Builds podman-suse-15.7.tar in the current directory
./run.sh                                       # Opens a shell in the image, in a sandbox
rsync --partial --progress podman-suse-15.7.tar lumi:<SINGULARITY_IMAGEDIR>/

# LUMI
singularity build "$SINGULARITY_IMAGEDIR"/podman-suse-15.7.sif oci-archive://"$SINGULARITY_IMAGEDIR"/podman-suse-15.7.tar
```
