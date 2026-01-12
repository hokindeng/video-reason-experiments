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
export OPENAI_API_KEY="your-openai-api-key"  # Required for evaluation

# AWS credentials (optional)
cp env.template .env  # Edit with your AWS credentials
```

## Usage

```bash
# Generate videos
./scripts/run_inference.sh --model hunyuan-video-i2v --gpu 0 --questions-dir ./data/questions

# Evaluate videos (methods: last_frame, multi_frame_uniform, keyframe_detection, hybrid_sampling)
./scripts/run_evaluation.sh --eval-method last_frame

# S3 sync
python data/s3_sync.py upload ./data/outputs s3://your-bucket/outputs
python data/s3_sync.py download s3://your-bucket/questions ./data/questions
```

## Models

**Supported models:** All 29+ models in VMEvalKit (see `VMEvalKit/docs/MODELS.md` for full list)

**Evaluation methods:** 
- `last_frame` - Fast single-frame evaluation (recommended)
- `multi_frame_uniform`, `keyframe_detection`, `hybrid_sampling` - Multi-frame evaluation

## License

Apache License 2.0 - See LICENSE file for details.
