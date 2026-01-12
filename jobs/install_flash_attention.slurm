#!/bin/bash
#SBATCH --job-name=flash-attn-install
#SBATCH --account=bdqf-dtai-gh
#SBATCH --partition=ghx4-interactive
#SBATCH --nodes=1
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=32
#SBATCH --mem=64G
#SBATCH --time=02:00:00
#SBATCH --output=/u/yli8/hokin/video-reason-experiments/logs/flash_attn_install_%j.out
#SBATCH --error=/u/yli8/hokin/video-reason-experiments/logs/flash_attn_install_%j.err

##############################################################################
# Flash-Attention Installation Batch Job for Grace-Hopper (GH200)
#
# Submit with: sbatch jobs/install_flash_attention.slurm
# Monitor with: tail -f logs/flash_attn_install_<JOBID>.out
##############################################################################

set -euo pipefail

echo "════════════════════════════════════════════════════════════════"
echo "Flash-Attention Installation on Compute Node"
echo "════════════════════════════════════════════════════════════════"
echo "Job ID: ${SLURM_JOB_ID}"
echo "Node: $(hostname)"
echo "Started: $(date)"
echo ""

# Load correct compiler (GCC 13 for CUDA 12.6 compatibility)
echo "Loading compatible compiler..."
echo "Current GCC: $(gcc --version | head -1 2>/dev/null || echo 'not found')"

# Unload current GCC and load GCC 13.2
module unload gcc gcc-native 2>/dev/null || true
module load gcc-native/13.2

# The module loads but PATH may not update, so explicitly find and use GCC 13.2
echo "Finding GCC 13.2 path..."

# Check common GCC paths
for GCC_PATH in /opt/cray/pe/gcc/13.2.0/bin/gcc \
                /usr/bin/gcc-13 \
                /opt/gcc/13.2.0/bin/gcc \
                $(which gcc-13 2>/dev/null) \
                $(find /opt -name "gcc" -path "*/13.2*/bin/gcc" 2>/dev/null | head -1); do
    if [[ -x "$GCC_PATH" ]]; then
        GCC_VERSION=$($GCC_PATH -dumpversion 2>/dev/null || echo "0")
        GCC_MAJOR=$(echo "$GCC_VERSION" | cut -d. -f1)
        if [[ "$GCC_MAJOR" == "13" ]]; then
            echo "✓ Found GCC 13.x at: $GCC_PATH"
            export CC="$GCC_PATH"
            export CXX="${GCC_PATH/gcc/g++}"
            export PATH="$(dirname "$GCC_PATH"):$PATH"
            break
        fi
    fi
done

echo "After setup:"
echo "  CC: ${CC:-gcc}"
echo "  GCC: $(${CC:-gcc} --version | head -1)"

# Verify GCC version is correct (should be 13.x)
GCC_VERSION=$(${CC:-gcc} -dumpversion 2>/dev/null || echo "0")
GCC_MAJOR=$(echo "$GCC_VERSION" | cut -d. -f1)

if [[ "$GCC_MAJOR" -lt 9 ]]; then
    echo "❌ ERROR: GCC version $GCC_VERSION is too old (need ≥9 for PyTorch)"
    echo "Available modules:"
    module avail gcc
    exit 1
elif [[ "$GCC_MAJOR" -gt 13 ]]; then
    echo "❌ ERROR: GCC version $GCC_VERSION is too new for CUDA 12.6 (need ≤13)"
    exit 1
else
    echo "✓ GCC version $GCC_VERSION is compatible"
fi

echo "  NVCC: $(nvcc --version | grep release)"
echo "  CUDA_HOME: ${CUDA_HOME}"
echo ""

# Check GPU
echo "GPU on this node:"
nvidia-smi -L
echo ""

# Activate virtual environment
VENV_PATH="/u/yli8/hokin/video-reason-experiments/VMEvalKit/envs/hunyuan-video-i2v"

if [[ ! -f "${VENV_PATH}/bin/python" ]]; then
    echo "❌ Virtual environment not found: ${VENV_PATH}"
    echo "   Please run hunyuan-video-i2v setup first."
    exit 1
fi

source "${VENV_PATH}/bin/activate"
echo "✓ Activated: ${VENV_PATH}"
echo "  Python: $(python --version)"
echo ""

# Verify PyTorch
python -c "import torch; print(f'PyTorch: {torch.__version__}'); print(f'CUDA: {torch.version.cuda}'); print(f'GPU available: {torch.cuda.is_available()}')"
echo ""

# Install build dependencies
echo "Installing build dependencies..."
pip install -q --upgrade pip setuptools wheel
pip install -q ninja==1.11.1.1 packaging==24.2
echo "✓ Build dependencies installed"
echo ""

# Configure build environment
export MAX_JOBS=4  # Reduced from 8 to prevent OOM kills
export TORCH_CUDA_ARCH_LIST="8.0;9.0"  # Ampere (A100) + Hopper (H100/GH200)
export FLASH_ATTENTION_FORCE_BUILD=TRUE

echo "Build configuration:"
echo "  MAX_JOBS: ${MAX_JOBS}"
echo "  TORCH_CUDA_ARCH_LIST: ${TORCH_CUDA_ARCH_LIST}"
echo "  CUDA_HOME: ${CUDA_HOME}"
echo ""

# Install flash-attention
echo "════════════════════════════════════════════════════════════════"
echo "Compiling flash-attention from source..."
echo "════════════════════════════════════════════════════════════════"
echo "This typically takes 15-30 minutes."
echo "Compilation started: $(date)"
echo ""

pip install flash-attn==2.7.4.post1 --no-build-isolation -v

BUILD_EXIT=$?

echo ""
echo "Compilation finished: $(date)"
echo ""

if [[ $BUILD_EXIT -ne 0 ]]; then
    echo "❌ Build failed with exit code ${BUILD_EXIT}"
    echo "Check the error messages above for details."
    exit 1
fi

# Verify installation
echo "════════════════════════════════════════════════════════════════"
echo "Verifying installation..."
echo "════════════════════════════════════════════════════════════════"

python - <<'PYVERIFY'
import flash_attn
print(f"✓ flash_attn version: {flash_attn.__version__}")
print(f"✓ Location: {flash_attn.__file__}")

from flash_attn import flash_attn_func
print("✓ flash_attn_func imported successfully")

import torch
if torch.cuda.is_available():
    print(f"✓ GPU: {torch.cuda.get_device_name(0)}")
    print("✓ Flash-attention is ready for GPU operations")

print("\n" + "="*60)
print("Flash-Attention installation SUCCESSFUL!")
print("="*60)
PYVERIFY

VERIFY_EXIT=$?

if [[ $VERIFY_EXIT -ne 0 ]]; then
    echo ""
    echo "❌ Installation verification failed"
    exit 1
fi

deactivate

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "✅ Installation Complete!"
echo "════════════════════════════════════════════════════════════════"
echo "Job ID: ${SLURM_JOB_ID}"
echo "Finished: $(date)"
echo ""
echo "Flash-attention is now available in:"
echo "  ${VENV_PATH}"
echo ""
echo "Your HunyuanVideo jobs will automatically use flash-attention"
echo "for faster video generation."
echo ""

