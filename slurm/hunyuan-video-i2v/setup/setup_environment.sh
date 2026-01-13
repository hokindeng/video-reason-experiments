#!/bin/bash
##############################################################################
# HunyuanVideo-I2V Environment Setup for ARM64 Grace-Hopper HPC
##############################################################################
#
# PURPOSE:
#   Create a working HunyuanVideo-I2V environment on ARM64 (aarch64) systems
#   with Python 3.12 and PyTorch 2.7+cu126.
#
# USAGE:
#   bash slurm/hunyuan-video-i2v/setup/setup_environment.sh
#
# WHAT IT DOES:
#   1. Creates virtual environment with --system-site-packages (reuses cluster torch)
#   2. Installs ARM64-compatible dependencies (upgraded versions with wheels)
#   3. Downloads model checkpoints from HuggingFace (~40GB total)
#
# REQUIREMENTS:
#   - Module: cuda/12.6.1
#   - Module: python/miniforge3_pytorch/2.7.0 (provides PyTorch 2.7+cu126)
#   - Internet access for HuggingFace downloads
#   - ~50GB disk space
#
# OUTPUT:
#   Virtual environment at: VMEvalKit/envs/hunyuan-video-i2v
#   Model checkpoints at: VMEvalKit/submodules/HunyuanVideo-I2V/ckpts/
#
# ARM64 NOTES:
#   - Many upstream pinned versions have no ARM64/cp312 wheels
#   - We upgrade to newer wheel-available versions
#   - numpy must be <2.0 for pandas/pyarrow compatibility
#   - deepspeed has no ARM64 wheel (made optional via code patch)
#
# AFTER THIS:
#   Run: sbatch slurm/hunyuan-video-i2v/setup/install_flash_attention.slurm
#   Then: ./slurm/submit/hunyuan/submit_all.sh
#
##############################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

cd "$PROJECT_ROOT"

echo "🔧 Setting up hunyuan-video-i2v environment..."

# Activate modules (order matters: python module loads craype-accel-nvidia90 which requires cuda first)
module purge
module load cuda/12.6.1
module load python/miniforge3_pytorch/2.7.0

# -----------------------------------------------------------------------------
# IMPORTANT (GH200 / aarch64):
# Upstream VMEvalKit hunyuan setup tries to install torch==2.4.0+cu121, which
# has no aarch64 wheels. On this HPC we must reuse the cluster's PyTorch
# (2.7.0.dev...+cu126) provided by python/miniforge3_pytorch/2.7.0.
# -----------------------------------------------------------------------------

MODEL="hunyuan-video-i2v"
VMEVALKIT_DIR="${PROJECT_ROOT}/VMEvalKit"
VENV_PATH="${VMEVALKIT_DIR}/envs/${MODEL}"

mkdir -p "${VMEVALKIT_DIR}/envs"

echo "🐍 Recreating venv (with system site-packages): ${VENV_PATH}"
rm -rf "${VENV_PATH}"
python -m venv --system-site-packages "${VENV_PATH}"

source "${VENV_PATH}/bin/activate"

# Pin build tools to the versions in the cluster python stack for reproducibility
pip install -q --upgrade "pip==25.0.1" "setuptools==75.8.0" "wheel==0.45.1"

echo "✅ Using cluster PyTorch (should be 2.7.0.dev...+cu126):"
python -c "import torch; print('torch', torch.__version__, 'cuda', torch.version.cuda)"

echo "📦 Installing HunyuanVideo-I2V dependencies (pinned)..."

# Core ML libraries (from HunyuanVideo requirements.txt)
pip install -q "opencv-python==4.9.0.80"      # Computer vision
pip install -q "diffusers==0.31.0"            # Diffusion models framework
pip install -q "accelerate==1.1.1"            # PyTorch training/inference utilities
pip install -q "einops==0.7.0"                # Tensor operations
pip install -q "safetensors==0.4.3"           # Safe model serialization
pip install -q "peft==0.13.2"                 # Parameter-efficient fine-tuning

# Data processing (upgraded for ARM64/cp312 wheel availability)
pip install -q --only-binary=:all: "pandas==2.2.3"   # Was 2.0.3 (no cp312 wheel)
pip install -q --only-binary=:all: "numpy==1.26.4"   # Was 1.24.4 (no cp312 wheel), must be <2.0
pip install -q --only-binary=:all: "pyarrow==14.0.1" # Arrow format support

# Transformers stack (HuggingFace)
pip install -q "transformers==4.39.3"         # Model loading
pip install -q "tokenizers==0.15.0"           # Fast tokenization

# Utilities
pip install -q "tqdm==4.66.2"                 # Progress bars
pip install -q "loguru==0.7.2"                # Logging
pip install -q "imageio==2.34.0"              # Image I/O
pip install -q "imageio-ffmpeg==0.5.1"        # Video encoding
pip install -q "tensorboard==2.19.0"          # Training monitoring

# Deepspeed (training-only, but imported by HunyuanVideo code)
# NOTE: Only 0.3.1.dev5 has ARM64 wheel, but it's incompatible with PyTorch 2.x
# We install it anyway (to satisfy import) but made the import optional via code patch
pip install -q --only-binary=:all: --no-deps "deepspeed"
pip install -q "tensorboardX==1.8" "ninja==1.11.1.1"  # Deepspeed dependencies
pip install -q "protobuf==3.20.3"             # tensorboardX 1.8 compatibility

# CLIP (required by HunyuanVideo for text encoding)
# Pin by commit SHA for reproducibility (no version tags on openai/CLIP repo)
pip install -q --no-build-isolation "git+https://github.com/openai/CLIP.git@dcba3cb2e2827b402d2701e7e1c7d9fed8a20ef1"

# VMEvalKit runner utilities
pip install -q --only-binary=:all: "Pillow==11.3.0"  # Was 9.5.0 (no cp312 wheel)
pip install -q "pydantic==2.12.5"                     # Data validation
pip install -q "pydantic-settings==2.12.0"            # Settings management
pip install -q "python-dotenv==1.2.1"                 # Environment variables
pip install -q "requests==2.32.5"                     # HTTP client
pip install -q "httpx==0.28.1"                        # Async HTTP client
pip install -q "huggingface_hub[cli]==0.26.2"         # Model downloads

echo "✅ Verifying torchvision ops are present (must be True):"
python -c "import torchvision; print(getattr(torchvision.extension,'_has_ops')())"

echo ""
echo "────────────────────────────────────────────────────────────────"
echo "Downloading Model Checkpoints"
echo "────────────────────────────────────────────────────────────────"

HUNYUAN_CKPaTS_DIR="${PROJECT_ROOT}/VMEvalKit/submodules/HunyuanVideo-I2V/ckpts"
HUNYUAN_MODEL_DIR="${HUNYUAN_CKPTS_DIR}/hunyuan-video-i2v-720p"
TEXT_ENCODER_DIR="${HUNYUAN_CKPTS_DIR}/text_encoder_i2v"
CLIP_TEXT_ENCODER_DIR="${HUNYUAN_CKPTS_DIR}/text_encoder_2"

# Download main model weights (~20GB)
if [[ -d "${HUNYUAN_MODEL_DIR}" ]] && [[ -n "$(ls -A "${HUNYUAN_MODEL_DIR}" 2>/dev/null)" ]]; then
    echo "⏭️  HunyuanVideo-I2V weights already present at ${HUNYUAN_MODEL_DIR}"
else
    echo "📥 Downloading HunyuanVideo-I2V weights (~20GB, resume supported)..."
    mkdir -p "${HUNYUAN_CKPTS_DIR}"
    huggingface-cli download tencent/HunyuanVideo-I2V \
        --local-dir "${HUNYUAN_CKPTS_DIR}" \
        --local-dir-use-symlinks False \
        --resume-download
    echo "   ✅ Weights ready at ${HUNYUAN_MODEL_DIR}"
fi

# Download text encoder (LLaVA-Llama-3-8B, ~16GB)
if [[ -d "${TEXT_ENCODER_DIR}" ]] && [[ -f "${TEXT_ENCODER_DIR}/preprocessor_config.json" ]]; then
    echo "⏭️  HunyuanVideo-I2V text encoder already present at ${TEXT_ENCODER_DIR}"
else
    if [[ -d "${TEXT_ENCODER_DIR}" ]]; then
        echo "📥 Removing incomplete text encoder..."
        rm -rf "${TEXT_ENCODER_DIR}"
    fi
    echo "📥 Downloading HunyuanVideo-I2V text encoder (~16GB)..."
    mkdir -p "${TEXT_ENCODER_DIR}"
    huggingface-cli download xtuner/llava-llama-3-8b-v1_1-transformers \
        --local-dir "${TEXT_ENCODER_DIR}" \
        --local-dir-use-symlinks False \
        --resume-download
    echo "   ✅ Text encoder ready at ${TEXT_ENCODER_DIR}"
fi

# Download CLIP text encoder (~1.7GB)
if [[ -d "${CLIP_TEXT_ENCODER_DIR}" ]] && [[ -n "$(ls -A "${CLIP_TEXT_ENCODER_DIR}" 2>/dev/null)" ]]; then
    echo "⏭️  HunyuanVideo-I2V CLIP text encoder already present at ${CLIP_TEXT_ENCODER_DIR}"
else
    if [[ -d "${CLIP_TEXT_ENCODER_DIR}" ]]; then
        echo "📥 Removing incomplete CLIP text encoder..."
        rm -rf "${CLIP_TEXT_ENCODER_DIR}"
    fi
    echo "📥 Downloading CLIP-L text encoder (~1.7GB)..."
    mkdir -p "${CLIP_TEXT_ENCODER_DIR}"
    huggingface-cli download openai/clip-vit-large-patch14 \
        --local-dir "${CLIP_TEXT_ENCODER_DIR}" \
        --local-dir-use-symlinks False \
        --resume-download
    echo "   ✅ CLIP text encoder ready at ${CLIP_TEXT_ENCODER_DIR}"
fi

deactivate

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "✅ HunyuanVideo-I2V Setup Complete!"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "Environment: ${VENV_PATH}"
echo "Checkpoints: ${HUNYUAN_CKPTS_DIR}"
echo ""
echo "📌 Next: install flash-attn into this venv via SLURM:"
echo "   sbatch ${PROJECT_ROOT}/slurm/hunyuan-video-i2v/setup/install_flash_attention.slurm"
echo ""
echo "Then submit jobs with --skip-setup flag:"
echo "   ./slurm/submit/hunyuan/submit_hunyuan_G1.sh"

