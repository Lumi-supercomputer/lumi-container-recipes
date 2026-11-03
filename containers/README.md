# Singularity containers for LUMI

## Obtaining the image

### Typical workflow: Fetch the image to the remote machine from an image registry

> `suse16` used here as an example. Replace with the correct version.

> The CI runner and the signing keys reside in a separate fork at `https://github.com/jpekkila/lumi-container-recipes`.

```bash
# Once: Fetch the public key and add it to the keyring
wget --output-document=public.asc https://raw.githubusercontent.com/<OWNER>/<REPO>/main/public.asc
singularity key import public.asc

# Once: login with a CLI secret. See https://docs.csc.fi/cloud/satama/cli/ on how to get the token.
singularity registry login --username <SATAMA_USERNAME> oras://satama.csc.fi

# Pull and vefiry the image
singularity pull suse16.sif oras://satama.csc.fi/<PROJECT>/suse16:latest  # Or :<COMMIT SHA> instead of :latest for a fixed build
singularity verify --local suse16.sif                                     # Verify the authenticity of the image
```

### Testing workflow: Build the image manually on the local machine and convert it to .sif on the remote
```bash
# On the local machine with rootless podman
./build.sh # Builds the suse16 image
./run.sh   # Opens the image in a sandboxed shell. Useful for testing that linking etc succeeded on the local machine.

# Transfer the image to the remote machine
podman save --format oci-archive --output suse16.tar suse16
rsync --partial --progress suse16.tar lumi:<SINGULARITY_IMAGEDIR>/

# On the remote machine: Convert the podman image to a singularity .sif
singularity build suse16.sif oci-archive://suse16.tar    # Build SIF
```

## Running

```bash
srun --pty <other flags> singularity shell suse16.sif    # Interactive run
srun <other flags> singularity exec suse16.sif <command> # Run a command in the container
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
