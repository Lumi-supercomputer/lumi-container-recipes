#!/bin/bash
set -euxo pipefail

SINGULARITY_DEFDIR="$(realpath $(dirname "$0"))"

# Check that PRoot and the required environment variables exist
command -v proot                 || { echo "PRoot not found: module load CrayEnv PRoot"; exit 1; }
[[ -n "$SINGULARITY_CACHEDIR" ]] || { echo "SINGULARITY_CACHEDIR not set"; exit 1; }
[[ -n "$SINGULARITY_TMPDIR"   ]] || { echo "SINGULARITY_TMPDIR not set";   exit 1; }
[[ -n "$SINGULARITY_IMAGEDIR" ]] || { echo "SINGULARITY_IMAGEDIR not set"; exit 1; }


# Recipe
# Construct hash from build files
RECIPE_HASH=$(cat "$SINGULARITY_DEFDIR"/build.sh "$SINGULARITY_DEFDIR"/*.def | sha256sum | cut --delimiter=' ' --fields=1)

# Base image
SUSE_BASE_IMAGE=registry.suse.com/bci/gcc:15@sha256:1997398d083d39594ec668bb2ee1d7593a5483baf10ac78602985d6fe86cf671

# Versions
OPENSUSE_SP=15.7
ROCM_SLES_VER=sles15
ROCM_RELEASE=7.14
ROCM_ARCH=gfx90a
SHS_RELEASE=12.0.2
LIBFABRIC_RELEASE=2.7.0
MPICH_RELEASE=5.0.2
AWS_OFI_NCCL_RELEASE=1.22.0
PYTHON_RELEASE=3.13
# OSU_RELEASE=7.5.1
PYTHON_PACKAGE_PREFIX=python${PYTHON_RELEASE//./} # Removes the dots, e.g. 3.13 becomes python313

# Hashes, which change with the versions above
CLUSTER_KEY_SHA256=d546e147623ed42fd2c22f0791e97819d5d65c35bdce92d69f0218ebbaf98984
AMD_KEY_SHA256=090a4bf906822c5eb450ae8024b728b9281f2fccb0304641eb75018e4ec6a6dd
CXI_DRIVER_SHA256=9d10c8783b64844303651afa9f9500a9a86918827446d469797925340f9c7ec7
CASSINI_SHA256=478a7bed6eedae6ba7035e7a0fc5662689f3d6dcffce27533e0a4ae1d35727b2
KDREG2_SHA256=d58b93e059e18dd96a4a5d7e99afbe650848cec954fdbbb1a031308246d0d212
LIBCXI_SHA256=339d3e88671c1283cb4da214a86ad80ff3a8ac39a43912e63486fb8dab44b08e
LIBFABRIC_SHA256=366000427e194d4ce22e272519b608afbebb1fc9915bcf5da924157a8a47fe10
MPICH_SHA256=928c2f18d350a91443fe8024ad01ce2c6009e9c551e0a73e797fc567f119137d
AWS_OFI_NCCL_SHA256=c791bd33b73c089bd37e314c8e7c551a5247e3feee53f077e0835daf730db09a
# OSU_SHA256=FILL_IN_SHA256_OF_OSU_TARBALL

# Repositories, packages and tarballs
CLUSTER_REPO=https://download.opensuse.org/repositories/network:cluster/$OPENSUSE_SP
ROCM_REPO=https://repo.amd.com/rocm/packages-multi-arch/$ROCM_SLES_VER/x86_64
CLUSTER_KEY_URL=$CLUSTER_REPO/repodata/repomd.xml.key
AMD_KEY_URL=https://repo.amd.com/rocm/packages-multi-arch/gpg/rocm.gpg
ROCM_PACKAGE=amdrocm-core-devel$ROCM_RELEASE-$ROCM_ARCH
PYTHON=python$PYTHON_RELEASE
CXI_DRIVER_URL=https://github.com/HewlettPackard/shs-cxi-driver/archive/refs/tags/release/shs-$SHS_RELEASE.tar.gz
CASSINI_URL=https://github.com/HewlettPackard/shs-cassini-headers/archive/refs/tags/release/shs-$SHS_RELEASE.tar.gz
KDREG2_URL=https://github.com/HewlettPackard/shs-kdreg2/archive/refs/tags/release/shs-$SHS_RELEASE.tar.gz
LIBCXI_URL=https://github.com/HewlettPackard/shs-libcxi/archive/refs/tags/release/shs-$SHS_RELEASE.tar.gz
LIBFABRIC_URL=https://github.com/ofiwg/libfabric/releases/download/v$LIBFABRIC_RELEASE/libfabric-$LIBFABRIC_RELEASE.tar.bz2
MPICH_URL=https://www.mpich.org/static/downloads/$MPICH_RELEASE/mpich-$MPICH_RELEASE.tar.gz
AWS_OFI_NCCL_URL=https://github.com/aws/aws-ofi-nccl/releases/download/v$AWS_OFI_NCCL_RELEASE/aws-ofi-nccl-$AWS_OFI_NCCL_RELEASE.tar.gz
# OSU_URL=https://mvapich.cse.ohio-state.edu/download/mvapich/osu-micro-benchmarks-$OSU_RELEASE.tar.gz

# Directories
ROCM_PATH=/opt/rocm
ROCM_CORE_PATH=$ROCM_PATH/core-$ROCM_RELEASE
LIBCXI_PATH=/opt/libcxi
LIBFABRIC_PATH=/opt/libfabric
MPICH_PATH=/opt/mpich
AWS_OFI_NCCL_PATH=/opt/aws-ofi-nccl
VENV_PATH=/opt/venv
# OSU_PATH=/opt/osu

# Compilers
CC=gcc-15
CXX=g++-15
FC=gfortran-15
F77=gfortran-15

# Pass the variables used by the def files to all images
BUILD_ARGS=(
    --build-arg "RECIPE_HASH=$RECIPE_HASH"
    --build-arg "SUSE_BASE_IMAGE=$SUSE_BASE_IMAGE"
    --build-arg "PYTHON_PACKAGE_PREFIX=$PYTHON_PACKAGE_PREFIX"
    --build-arg "CLUSTER_KEY_SHA256=$CLUSTER_KEY_SHA256"
    --build-arg "AMD_KEY_SHA256=$AMD_KEY_SHA256"
    --build-arg "CXI_DRIVER_SHA256=$CXI_DRIVER_SHA256"
    --build-arg "CASSINI_SHA256=$CASSINI_SHA256"
    --build-arg "KDREG2_SHA256=$KDREG2_SHA256"
    --build-arg "LIBCXI_SHA256=$LIBCXI_SHA256"
    --build-arg "LIBFABRIC_SHA256=$LIBFABRIC_SHA256"
    --build-arg "MPICH_SHA256=$MPICH_SHA256"
    --build-arg "AWS_OFI_NCCL_SHA256=$AWS_OFI_NCCL_SHA256"
    # --build-arg "OSU_SHA256=$OSU_SHA256"
    --build-arg "CLUSTER_REPO=$CLUSTER_REPO"
    --build-arg "ROCM_REPO=$ROCM_REPO"
    --build-arg "CLUSTER_KEY_URL=$CLUSTER_KEY_URL"
    --build-arg "AMD_KEY_URL=$AMD_KEY_URL"
    --build-arg "ROCM_PACKAGE=$ROCM_PACKAGE"
    --build-arg "PYTHON=$PYTHON"
    --build-arg "CXI_DRIVER_URL=$CXI_DRIVER_URL"
    --build-arg "CASSINI_URL=$CASSINI_URL"
    --build-arg "KDREG2_URL=$KDREG2_URL"
    --build-arg "LIBCXI_URL=$LIBCXI_URL"
    --build-arg "LIBFABRIC_URL=$LIBFABRIC_URL"
    --build-arg "MPICH_URL=$MPICH_URL"
    --build-arg "AWS_OFI_NCCL_URL=$AWS_OFI_NCCL_URL"
    # --build-arg "OSU_URL=$OSU_URL"
    --build-arg "ROCM_PATH=$ROCM_PATH"
    --build-arg "ROCM_CORE_PATH=$ROCM_CORE_PATH"
    --build-arg "LIBCXI_PATH=$LIBCXI_PATH"
    --build-arg "LIBFABRIC_PATH=$LIBFABRIC_PATH"
    --build-arg "MPICH_PATH=$MPICH_PATH"
    --build-arg "AWS_OFI_NCCL_PATH=$AWS_OFI_NCCL_PATH"
    --build-arg "VENV_PATH=$VENV_PATH"
    # --build-arg "OSU_PATH=$OSU_PATH"
    --build-arg "CC=$CC"
    --build-arg "CXX=$CXX"
    --build-arg "FC=$FC"
    --build-arg "F77=$F77"
)

# Build
singularity build "${BUILD_ARGS[@]}" "$SINGULARITY_IMAGEDIR"/01-rocm.sif "$SINGULARITY_DEFDIR"/01-rocm.def
singularity build "${BUILD_ARGS[@]}" --build-arg BASE_IMAGE="$SINGULARITY_IMAGEDIR"/01-rocm.sif "$SINGULARITY_IMAGEDIR"/02-network.sif "$SINGULARITY_DEFDIR"/02-network.def
singularity build "${BUILD_ARGS[@]}" --build-arg BASE_IMAGE="$SINGULARITY_IMAGEDIR"/02-network.sif "$SINGULARITY_IMAGEDIR"/03-python.sif "$SINGULARITY_DEFDIR"/03-python.def
# singularity build "${BUILD_ARGS[@]}" --build-arg BASE_IMAGE="$SINGULARITY_IMAGEDIR"/03-python.sif "$SINGULARITY_IMAGEDIR"/04-osu.sif "$SINGULARITY_DEFDIR"/04-osu.def
