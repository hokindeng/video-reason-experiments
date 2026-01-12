#!/bin/bash
#
# Setup hunyuan-video-i2v environment only (no inference)
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

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
pip install -q "opencv-python==4.9.0.80"
pip install -q "diffusers==0.31.0"
pip install -q "accelerate==1.1.1"
pip install -q --only-binary=:all: "pandas==2.2.3"
pip install -q --only-binary=:all: "numpy==1.26.4"
pip install -q "einops==0.7.0"
pip install -q "tqdm==4.66.2"
pip install -q "loguru==0.7.2"
pip install -q "imageio==2.34.0"
pip install -q "imageio-ffmpeg==0.5.1"
pip install -q "safetensors==0.4.3"
pip install -q "peft==0.13.2"
pip install -q "transformers==4.39.3"
pip install -q "tokenizers==0.15.0"
pip install -q --only-binary=:all: "pyarrow==14.0.1"
pip install -q "tensorboard==2.19.0"
pip install -q --only-binary=:all: --no-deps "deepspeed"  # Only 0.3.1.dev5 has aarch64 wheel; unused for inference
pip install -q "tensorboardX==1.8" "ninja==1.11.1.1"  # Required by deepspeed
pip install -q "protobuf==3.20.3"  # tensorboardX 1.8 needs protobuf 3.20.x

# Pin CLIP by commit SHA for reproducibility
pip install -q --no-build-isolation "git+https://github.com/openai/CLIP.git@dcba3cb2e2827b402d2701e7e1c7d9fed8a20ef1"

# Extra utilities used by VMEvalKit runner
pip install -q --only-binary=:all: "Pillow==11.3.0"
pip install -q "pydantic==2.12.5" "pydantic-settings==2.12.0" "python-dotenv==1.2.1"
pip install -q "requests==2.32.5" "httpx==0.28.1"
pip install -q "huggingface_hub[cli]==0.26.2"

echo "✅ Verifying torchvision ops are present (must be True):"
python -c "import torchvision; print(getattr(torchvision.extension,'_has_ops')())"

echo ""
echo "────────────────────────────────────────────────────────────────"
echo "Downloading Model Checkpoints"
echo "────────────────────────────────────────────────────────────────"

HUNYUAN_CKPTS_DIR="${PROJECT_ROOT}/VMEvalKit/submodules/HunyuanVideo-I2V/ckpts"
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
echo "   sbatch ${PROJECT_ROOT}/jobs/install_flash_attention.slurm"
echo ""
echo "Then submit jobs with --skip-setup flag:"
echo "   ./jobs/hunyuan_jobs/submit_hunyuan_G1.sh"

