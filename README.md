# video-reason-experiments

This is the codebase for running all VM datasets on video models using VMEvalKit.

## Quick Setup Guide

### Prerequisites

- Python 3.8+
- Git with submodule support
- CUDA-capable GPU (for model inference)
- AWS account (for S3 data sync)

### 1. Clone Repository

```bash
git clone <repository-url> video-reason-experiments
cd video-reason-experiments
```

### 2. Initialize VMEvalKit Submodule

**For first-time setup** (uses locked commit version):

```bash
git submodule update --init --recursive
```

### 3. Create Virtual Environment

Create and activate a Python virtual environment:

```bash
python3 -m venv env
source env/bin/activate  # On Linux/macOS
# env\Scripts\activate  # On Windows
```

### 4. Install Dependencies

```bash
pip install -r requirements.txt
```

### 5. Configure AWS Credentials

Copy the environment template and fill in your AWS credentials:

```bash
cp env.template .env
```

Edit `.env` with your credentials:

```bash
AWS_ACCESS_KEY_ID=your_access_key_here
AWS_SECRET_ACCESS_KEY=your_secret_key_here
AWS_DEFAULT_REGION=us-east-1
AWS_S3_BUCKET=vm-dataset
```

### 6. Download Question Data (Optional)

If your questions are stored in S3:

```bash
python data/s3_sync.py download s3://your-bucket/questions ./data/questions
```

## Usage

### Running Inference

Generate videos from prompts using a specific model:

```bash
./scripts/run_inference.sh --model hunyuan-video-i2v
```

Optional flags:
- `--gpu <device_id>` - Specify GPU device
- `--skip-setup` - Skip model checkpoint setup
- `--questions-dir <path>` - Custom questions folder (default: `data/questions`)

Examples:
```bash
# Basic usage
./scripts/run_inference.sh --model hunyuan-video-i2v --gpu 0

# With custom questions folder
./scripts/run_inference.sh --model hunyuan-video-i2v \
    --questions-dir ./custom_questions

python scripts/run_inference.py --model wan-2.2-ti2v-5b --questions-dir ./data/questions/G-1_object_trajectory_task --gpu 2

```

### Running Evaluation

Evaluate generated videos using one of three strategies:

```bash
./scripts/run_evaluation.sh --eval-method <method>
```

Available methods:
- `multi_frame_uniform` - Uniform sampling across frames
- `keyframe_detection` - SSIM-based keyframe detection
- `hybrid_sampling` - Combined approach

Example:
```bash
./scripts/run_evaluation.sh --eval-method hybrid_sampling
```

### Syncing Data with S3

Upload results:
```bash
python data/s3_sync.py upload ./data/outputs s3://your-bucket/outputs
```

Download datasets:
```bash
python data/s3_sync.py download s3://your-bucket/datasets ./data/datasets
```

## Supported Models

- `hunyuan-video-i2v` - Hunyuan Video I2V
- `cogvideox-5b-i2v` - CogVideoX 5B I2V
- `ltx-video` - LTX Video

Models are automatically set up on first run (downloads checkpoints to `VMEvalKit/submodules/`).

## Directory Structure

```
video-reason-experiments/
├── configs/eval/          # Evaluation configurations
│   ├── multi_frame_uniform.json
│   ├── keyframe_detection.json
│   └── hybrid_sampling.json
├── data/
│   ├── questions/         # Input prompts (created on first run)
│   ├── outputs/           # Generated videos (created on first run)
│   ├── evaluations/       # Evaluation results (created on first run)
│   └── s3_sync.py        # S3 utility script
├── scripts/
│   ├── run_inference.sh   # Video generation runner
│   └── run_evaluation.sh  # Evaluation runner
└── VMEvalKit/            # Git submodule
```

## Evaluation Strategies

### Multi-Frame Uniform
- Samples 8 frames uniformly from last 3 seconds
- Uses histogram-based metrics
- Best for smooth, continuous motion

### Keyframe Detection
- Detects significant frame changes using SSIM
- Focuses on important visual transitions
- Best for scene changes and cuts

### Hybrid Sampling
- Combines uniform and keyframe approaches
- Balanced temporal weighting
- Best general-purpose strategy

## License

Apache License 2.0 - See LICENSE file for details.
