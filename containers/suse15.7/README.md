# SUSE 15.7 image for LUMI

```bash
# Local
./build.sh                                     # Builds podman-suse-15.7.tar in the current directory
./run.sh                                       # Opens a shell in the image, in a sandbox
rsync --partial --progress podman-suse-15.7.tar lumi:<SINGULARITY_IMAGEDIR>/

# LUMI
singularity build podman-suse-15.7.sif oci-archive://podman-suse-15.7.tar

singularity shell podman-suse-15.7.sif

singularity exec podman-suse-15.7.sif <commands>
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

## Tests

```bash
# Intra-node
amd-smi topology
TransferBench p2p # CPU-GPU bandwidth matrix
TransferBench a2a

# RVS
rvs
rvs --listGpus
rvs --listTests
ldd /opt/rocm/extras-7/bin/rvs | grep 'not found'

# OSU, two nodes, one GPU each
export MPIR_CVAR_CH4_OFI_ENABLE_HMEM=1
export NCCL_DEBUG=INFO
OSU="srun --mpi=pmi2 --nodes=2 --ntasks-per-node=1 --gpus-per-node=1 singularity exec podman-suse-15.7.sif"

$OSU osu_bw --accelerator rocm H H
$OSU osu_bw --accelerator rocm D D
$OSU osu_latency --accelerator rocm D D
$OSU osu_put_bw --accelerator rocm D D
$OSU osu_xccl_bw --accelerator rocm D D
$OSU osu_xccl_allreduce --accelerator rocm
```
