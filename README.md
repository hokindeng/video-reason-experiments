# video-reason-experiments

Wrapper for running video reasoning experiments using VMEvalKit.

## Setup

```bash
# Clone and setup
git clone https://github.com/hokindeng/video-reason-experiments.git
cd video-reason-experiments
git submodule update --init --recursive --remote --merge

# Environment
python3 -m venv env && source env/bin/activate
pip install -r requirements.txt

# AWS credentials (optional)
cp env.template .env  # Edit with your AWS credentials
```

## Usage

```bash
# Generate videos
./scripts/run_inference.sh --model hunyuan-video-i2v --gpu 0 --questions-dir ./data/questions

# Evaluate videos  
./scripts/run_evaluation.sh --eval-method hybrid_sampling

# S3 sync
python data/s3_sync.py upload ./data/outputs s3://your-bucket/outputs
python data/s3_sync.py download s3://your-bucket/questions ./data/questions
```

## Models

**Supported models:** `hunyuan-video-i2v`, `cogvideox-5b-i2v`, `ltx-video`

**Evaluation methods:** `multi_frame_uniform`, `keyframe_detection`, `hybrid_sampling`

## License

Apache License 2.0 - See LICENSE file for details.
