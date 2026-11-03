# SUSE 16 image for LUMI

```bash
# Local
./build.sh                                     # Builds the suse16 image
./run.sh                                       # Opens a shell in the image, in a sandbox
podman save --format oci-archive --output suse16.tar suse16
rsync --partial --progress suse16.tar lumi:<SINGULARITY_IMAGEDIR>/

# LUMI
singularity build suse16.sif oci-archive://suse16.tar # Build SIF
singularity shell suse16.sif                          # Interactive run
singularity exec suse16.sif <commands>                # Run a command in the container
```

## Signed image from CI

```bash
# LUMI
wget --output-document=public.asc https://raw.githubusercontent.com/<OWNER>/<REPO>/main/public.asc
singularity key import public.asc              # Once
singularity registry login --username <SATAMA_USERNAME> oras://satama.csc.fi  # Once, if the project is private. Prompts for the satama CLI secret
singularity pull suse16.sif oras://satama.csc.fi/<PROJECT>/suse16:latest  # Or :<COMMIT SHA> for a fixed build
singularity verify --local suse16.sif          # Fails unless signed by a key in the local keyring
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
ldd /opt/rocm/extras-10/bin/rvs | grep 'not found'

# OSU, two nodes, one GPU each
export MPIR_CVAR_CH4_OFI_ENABLE_HMEM=1
export NCCL_DEBUG=INFO
OSU="srun --mpi=pmi2 --nodes=2 --ntasks-per-node=1 --gpus-per-node=1 singularity exec suse16.sif"

$OSU osu_bw --accelerator rocm H H
$OSU osu_bw --accelerator rocm D D
$OSU osu_latency --accelerator rocm D D
$OSU osu_put_bw --accelerator rocm D D
$OSU osu_xccl_bw --accelerator rocm D D
$OSU osu_xccl_allreduce --accelerator rocm
```
