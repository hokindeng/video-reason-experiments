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
echo "📌 Next: install flash-attn into this venv via SLURM:"
echo "   sbatch ${PROJECT_ROOT}/jobs/install_flash_attention.slurm"

deactivate

echo "✅ Setup complete!"
echo ""
echo "Environment location: ${VENV_PATH}"
echo ""
echo "Now you can submit jobs with --skip-setup flag"

