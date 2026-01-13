# QuickStart Guide - HunyuanVideo on Grace-Hopper HPC

Get HunyuanVideo-I2V running on your ARM64 Grace-Hopper HPC in 3 steps.

---

## Prerequisites

- Access to Grace-Hopper (GH200) HPC cluster with SLURM
- AWS credentials for S3 access
- CUDA 12.6+ and Python 3.12+

---

## Step 1: Initial Setup (5 minutes)

```bash
# Clone and initialize
cd /u/$USER/hokin
git clone <repo-url> video-reason-experiments
cd video-reason-experiments
git submodule update --init --recursive

# Configure AWS
cp env.template .env
# Edit .env: add your AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY

# Download dataset
module load aws-cli/2.27.49
set -a && source .env && set +a
aws s3 sync s3://hokindeng/questions/ data/questions

# Verify
./jobs/check_setup.sh
```

**Expected output**: `✅ All pre-flight checks passed! Tasks found: 50`

---

## Step 2: Environment Setup (30-40 minutes)

### 2a. Create HunyuanVideo Environment (10 minutes)

```bash
bash jobs/setup_hunyuan_only.sh
```

**This will**:
- Create virtual environment with cluster PyTorch (2.7+cu126)
- Install all ARM64-compatible dependencies
- Download model checkpoints (~40GB)

**Expected output**: `✅ HunyuanVideo-I2V Setup Complete!`

### 2b. Install Flash-Attention (30 minutes)

```bash
sbatch jobs/install_flash_attention.slurm

# Monitor progress
tail -f logs/flash_attn_install_<JOBID>.out
```

**Expected**:
- Compilation time: 15-30 minutes (first time), 3 seconds (cached)
- Result: flash-attn 2.7.4.post1 installed

**Verify**:
```bash
srun --gres=gpu:1 --partition=ghx4-interactive --pty bash
source VMEvalKit/envs/hunyuan-video-i2v/bin/activate
python -c "import flash_attn; print(f'✓ {flash_attn.__version__}')"
```

---

## Step 3: Launch Jobs (1 minute)

### Test with Single Job
```bash
./jobs/hunyuan_jobs/submit_hunyuan_G1.sh

# Monitor
tail -f logs/hunyuan_G1_<JOBID>.out
```

**Expected**: First video generates in ~3-5 minutes (720p with flash-attention)

### Launch All 50 Jobs
```bash
./jobs/submit_all_hunyuan.sh

# Monitor
squeue -u $USER
find data/outputs/hunyuan-video-i2v -name "*.mp4" | wc -l
```

**Expected**: 
- 50 jobs submitted
- ~20-30 jobs running concurrently (depends on cluster availability)
- ~3-5 minutes per 720p video
- ~2-4 hours per 50-video job

---

## Upload Results to S3

```bash
module load aws-cli/2.27.49
set -a && source .env && set +a
python data/s3_sync.py upload data/outputs s3://vm-dataset-yijiangli/hunyuan/
```

---

## Monitoring Commands

```bash
# Job status
squeue -u $USER                    # All your jobs
squeue -j <JOBID>                  # Specific job

# Live logs
tail -f logs/hunyuan_G1_<JOBID>.out

# Progress check
find data/outputs/hunyuan-video-i2v -name "*.mp4" | wc -l

# Completed jobs today
sacct -u $USER --starttime today --format=JobID,JobName%30,State | grep COMPLETED
```

---

## Common Issues

### "No module named 'flash_attn'"
**Fix**: Run `sbatch jobs/install_flash_attention.slurm`

### "Missing checkpoint directory"
**Fix**: Run `bash jobs/setup_hunyuan_only.sh`

### Jobs fail immediately
**Check logs**: `cat logs/hunyuan_G1_<JOBID>.err`
**Common cause**: Module loading order
**Fix**: Jobs load modules correctly, but ensure setup completed first

### "Invalid AWS credentials"
**Fix**: Update `.env` with valid credentials

---

## Performance Expectations

### With Flash-Attention ✅
- **720p video**: ~3-5 minutes
- **Memory usage**: ~59GB VRAM
- **GPU utilization**: 100%
- **Speedup vs standard**: 40-50% faster

### Without Flash-Attention
- **720p video**: ~5-7 minutes
- **Memory usage**: ~65-70GB VRAM
- **Not recommended** on this system

---

## File Sizes

- **Dataset (questions)**: ~10GB
- **Model checkpoints**: ~40GB
- **Flash-attention wheel**: 187MB
- **Virtual environment**: ~2GB
- **Per generated video**: ~25-35MB
- **50 videos**: ~1.5GB

---

## Next Steps

1. **Monitor jobs**: Use `squeue -u $USER`
2. **Check outputs**: Videos save to `data/outputs/hunyuan-video-i2v/`
3. **Upload results**: Use `python data/s3_sync.py upload ...`
4. **Run evaluation**: Use `scripts/run_evaluation.sh` (when ready)

---

## Support

- **Flash-attention issues**: See `jobs/FLASH_ATTENTION_SUCCESS.md`
- **Full history**: See `AGENT_HISTORY.md`
- **Job organization**: See `jobs/README.md`

---

**Estimated total time from zero to 50 running jobs**: 45 minutes + download times
