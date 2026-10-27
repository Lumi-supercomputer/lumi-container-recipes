# SUSE 15.7 image for LUMI

```bash
# Local
./build.sh                                     # Builds podman-suse-15.7.tar in the current directory
./run.sh                                       # Opens a shell in the image, in a sandbox
rsync --partial --progress podman-suse-15.7.tar lumi:<SINGULARITY_IMAGEDIR>/

# LUMI
singularity build podman-suse-15.7.sif oci-archive://podman-suse-15.7.tar

singularity shell podman-suse-15.7.sif
```

## Version and linker checks

```bash
mpichversion
ldd /opt/mpich/lib/libmpi.so | grep --extended-regexp 'fabric|hsa'

ldd /opt/libfabric/lib/libfabric.so | grep --extended-regexp 'cxi|hsa'
fi_info
fi_info --version
fi_info --list
fi_info --provider=cxi

ldd /opt/aws-ofi-nccl/lib/librccl-net*.so | grep --extended-regexp 'fabric'

ldconfig --print-cache | grep rccl
```
