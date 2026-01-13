# Troubleshooting Guide - HunyuanVideo on Grace-Hopper HPC

Common issues and solutions for running HunyuanVideo-I2V with flash-attention on ARM64 HPC.

---

## Flash-Attention Installation Issues

### Error: "unsupported GNU version! gcc versions later than 13 are not supported!"

**Cause**: System GCC (14.2.0) is too new for CUDA 12.6

**Solution**: The installation script automatically finds GCC 13.2. If it fails:
```bash
# Manually check GCC availability
module avail gcc
module load gcc-native/13.2
gcc --version  # Should show 13.x
```

**Fix in script**: Already handled by explicit path finding in `jobs/install_flash_attention.slurm`

---

### Error: "OOM Killed" during flash-attention compilation

**Cause**: Too many parallel compilation jobs (`MAX_JOBS=8`)

**Solution**: Already fixed - script uses `MAX_JOBS=4`

**If still failing**: Edit `jobs/install_flash_attention.slurm`:
```bash
export MAX_JOBS=2  # Reduce from 4 to 2
```

---

### Error: "gcc version X is too old (need ≥9 for PyTorch)"

**Cause**: GCC module loaded but `gcc` command points to old system compiler

**Solution**: Already fixed - script explicitly finds and exports `CC=/usr/bin/gcc-13`

**Verify manually**:
```bash
module load gcc-native/13.2
export CC=/usr/bin/gcc-13
export CXX=/usr/bin/g++-13
$CC --version  # Should show 13.x
```

---

### Flash-attention compiles but imports fail

**Symptoms**:
```python
>>> import flash_attn
ModuleNotFoundError: No module named 'flash_attn'
```

**Cause**: Wrong virtual environment activated

**Solution**: Ensure you're in the correct venv:
```bash
source /u/yli8/hokin/video-reason-experiments/VMEvalKit/envs/hunyuan-video-i2v/bin/activate
python -c "import flash_attn; print(flash_attn.__version__)"
```

---

## HunyuanVideo Environment Issues

### Error: "Could not find a version that satisfies the requirement torch==2.4.0+cu121"

**Cause**: No ARM64 wheels for torch 2.4.0+cu121

**Solution**: Already fixed - `jobs/setup_hunyuan_only.sh` uses cluster PyTorch 2.7+cu126 with `--system-site-packages`

**Do NOT** try to install torch manually - use the setup script.

---

### Error: "AttributeError: _ARRAY_API not found" (pyarrow/pandas)

**Cause**: NumPy 2.x incompatibility with pyarrow built against numpy 1.x

**Solution**: Already fixed - setup script pins `numpy==1.26.4` (< 2.0)

**If you see this**: Recreate venv:
```bash
rm -rf VMEvalKit/envs/hunyuan-video-i2v
bash jobs/setup_hunyuan_only.sh
```

---

### Error: "ModuleNotFoundError: No module named 'deepspeed'"

**Cause**: HunyuanVideo imports deepspeed but it has no ARM64 wheel

**Solution**: Already fixed - patched `VMEvalKit/submodules/HunyuanVideo-I2V/hyvideo/utils/helpers.py`:
```python
try:
    import deepspeed
except ImportError:
    deepspeed = None  # Optional: only needed for training
```

**Verify patch is applied**:
```bash
grep -A 2 "import deepspeed" VMEvalKit/submodules/HunyuanVideo-I2V/hyvideo/utils/helpers.py
# Should show try-except block
```

---

### Error: "TypeError: Descriptors cannot be created directly" (protobuf)

**Cause**: tensorboardX 1.8 incompatible with protobuf 4.x+

**Solution**: Already fixed - setup script installs `protobuf==3.20.3`

**Manual fix if needed**:
```bash
source VMEvalKit/envs/hunyuan-video-i2v/bin/activate
pip install protobuf==3.20.3
```

---

### Error: "Missing required checkpoint directory: .../ckpts/text_encoder_2"

**Cause**: Model checkpoints not downloaded

**Solution**: Run the setup script which downloads all checkpoints:
```bash
bash jobs/setup_hunyuan_only.sh
```

**Manual download** (if automatic fails):
```bash
source VMEvalKit/envs/hunyuan-video-i2v/bin/activate

# Main model (~20GB)
huggingface-cli download tencent/HunyuanVideo-I2V \
    --local-dir VMEvalKit/submodules/HunyuanVideo-I2V/ckpts

# Text encoder (~16GB)
huggingface-cli download xtuner/llava-llama-3-8b-v1_1-transformers \
    --local-dir VMEvalKit/submodules/HunyuanVideo-I2V/ckpts/text_encoder_i2v

# CLIP encoder (~1.7GB)
huggingface-cli download openai/clip-vit-large-patch14 \
    --local-dir VMEvalKit/submodules/HunyuanVideo-I2V/ckpts/text_encoder_2
```

---

## SLURM Job Issues

### Jobs fail immediately (exit in < 10 seconds)

**Check logs**: `cat logs/hunyuan_G1_<JOBID>.err`

**Common causes**:

1. **Flash-attention not installed**
   ```bash
   sbatch jobs/install_flash_attention.slurm
   ```

2. **Checkpoints missing**
   ```bash
   bash jobs/setup_hunyuan_only.sh
   ```

3. **Module load order wrong**  
   Already fixed in all job scripts - CUDA loads before python module

---

### Jobs pending forever (PD status)

**Check reason**:
```bash
squeue -u $USER -o "%.18i %.9P %.8j %.8u %.2t %.10M %.6D %.20R"
```

**Common reasons**:
- `(Priority)` - Normal, waiting for higher priority jobs
- `(Resources)` - No GPUs available, will run when free
- `(QOSMaxJobsPerUser)` - Hit job limit, wait for some to complete

**Solutions**:
- Wait for cluster resources
- Cancel some jobs: `scancel <JOBID>`
- Check partition status: `sinfo -p ghx4`

---

### Job killed with OOM

**Symptoms**: `slurmstepd: error: Detected 1 oom_kill event`

**Cause**: Job exceeded memory allocation (80GB)

**Solution**: Increase memory in job script:
```bash
#SBATCH --mem-per-gpu=100G  # Was 80G
```

Or enable CPU offloading (already default in our setup):
```python
# In HunyuanVideo inference, --use-cpu-offload flag is automatically added
```

---

## Module System Issues

### Error: "These module(s) cannot be loaded: cray-libsci"

**Cause**: `python/miniforge3_pytorch/2.7.0` tries to load Cray modules that aren't available yet

**Solution**: Load CUDA first:
```bash
module purge
module load cuda/12.6.1  # Load this FIRST
module load python/miniforge3_pytorch/2.7.0
```

**This is already fixed** in all setup and job scripts.

---

### Warning: "conda environment has been detected"

**Message**: `A conda environment has been detected CONDA_PREFIX=...`

**Impact**: Harmless warning, doesn't affect functionality

**To suppress**: Run `conda deactivate` before loading python module (not necessary)

---

## AWS S3 Issues

### Error: "InvalidAccessKeyId" or "AccessDenied"

**Cause**: Invalid or missing AWS credentials

**Solution**: Update `.env` file:
```bash
AWS_ACCESS_KEY_ID="AKIA..."
AWS_SECRET_ACCESS_KEY="..."
AWS_DEFAULT_REGION="us-east-2"
```

**Then**:
```bash
module load aws-cli/2.27.49
set -a && source .env && set +a
aws sts get-caller-identity  # Verify credentials work
```

---

### S3 sync very slow

**Cause**: Network bandwidth or large file sizes

**Options**:
1. Use `--no-progress` flag (already in scripts)
2. Upload from compute node (better network):
   ```bash
   srun --partition=ghx4-interactive --pty bash
   # Then run s3_sync.py
   ```
3. Compress before upload (not recommended - prefer raw videos)

---

## Performance Issues

### Video generation slower than expected

**Expected**: 3-5 min per 720p video with flash-attention

**If slower, check**:

1. **Flash-attention actually installed?**
   ```bash
   source VMEvalKit/envs/hunyuan-video-i2v/bin/activate
   python -c "from flash_attn import flash_attn_func; print('✓ flash-attn available')"
   ```

2. **GPU fully utilized?**
   ```bash
   srun --jobid=<JOBID> nvidia-smi
   # Should show 100% GPU util, ~59GB VRAM
   ```

3. **CPU offloading enabled?**  
   Already enabled by default in our setup

---

### Jobs using too much memory

**Symptoms**: Jobs killed with OOM, even with 80GB allocation

**Solutions**:

1. **Reduce video resolution** (in job script):
   ```bash
   # Modify questions to use 540p or 360p instead of 720p
   ```

2. **Enable CPU offloading** (already default)

3. **Increase memory allocation**:
   ```bash
   #SBATCH --mem-per-gpu=100G
   ```

---

## Dataset Issues

### Questions directory empty

**Check**:
```bash
ls data/questions/G-*/
```

**If empty**:
```bash
module load aws-cli/2.27.49
set -a && source .env && set +a
aws s3 sync s3://hokindeng/questions/ data/questions
```

---

### Missing first_frame.png or prompt.txt

**Symptoms**: Job skips tasks

**Check task structure**:
```bash
ls data/questions/G-1_object_trajectory_data-generator/object_trajectory_task/object_trajectory_0000/
# Should have: first_frame.png, prompt.txt, ground_truth.mp4
```

**Fix**: Re-sync from S3

---

## Debugging Commands

### Check virtual environment
```bash
source VMEvalKit/envs/hunyuan-video-i2v/bin/activate

# Verify key imports
python -c "import torch; print('torch:', torch.__version__)"
python -c "import flash_attn; print('flash_attn:', flash_attn.__version__)"
python -c "import diffusers, transformers, accelerate; print('✓ All imports OK')"

# Check installed packages
pip list | grep -E "torch|flash|diffusers|transformers"
```

### Check model checkpoints
```bash
ls -lh VMEvalKit/submodules/HunyuanVideo-I2V/ckpts/

# Should see:
# hunyuan-video-i2v-720p/ (~29GB)
# text_encoder_i2v/ (~16GB)
# text_encoder_2/ (~1.7GB)
```

### Check GPU status during job
```bash
# Get job ID
squeue -u $USER

# Check GPU usage
srun --jobid=<JOBID> nvidia-smi

# Should show:
# - GPU Util: 100%
# - Memory: ~59GB / 97GB
# - Power: 400-600W
# - Process: python running
```

### Check job accounting
```bash
# Today's jobs
sacct -u $USER --starttime today --format=JobID,JobName%30,State,Elapsed,NodeList

# Specific job details
sacct -j <JOBID> --format=JobID,JobName,State,Elapsed,MaxRSS,MaxVMSize,NodeList

# Failed jobs
sacct -u $USER --starttime today --state=FAILED --format=JobID,JobName%30,ExitCode
```

---

## Getting Help

### 1. Check Documentation
- Start with [QUICKSTART.md](QUICKSTART.md)
- Review [AGENT_HISTORY.md](AGENT_HISTORY.md) for detailed context
- See [jobs/FLASH_ATTENTION_SUCCESS.md](jobs/FLASH_ATTENTION_SUCCESS.md) for flash-attention specifics

### 2. Verify Setup
```bash
./jobs/check_setup.sh
```

Expected output: `✅ All pre-flight checks passed!`

### 3. Test in Interactive Session
```bash
# Request interactive GPU node
srun --partition=ghx4-interactive --gres=gpu:1 --cpus-per-task=8 --mem=64G --pty bash

# Load modules
module load cuda/12.6.1
module load python/miniforge3_pytorch/2.7.0

# Activate venv
source VMEvalKit/envs/hunyuan-video-i2v/bin/activate

# Test imports
python -c "import flash_attn; from hyvideo.config import parse_args; print('✓ All working')"
```

### 4. Check System Status
```bash
# Partition availability
sinfo -p ghx4

# Your job priority
sprio -u $USER

# Node details
scontrol show node <nodename>
```

---

## Emergency Procedures

### Cancel All Jobs
```bash
# Cancel all your jobs
scancel -u $USER

# Cancel specific pattern
scancel -u $USER -n "hunyuan-G*"

# Cancel specific job
scancel <JOBID>
```

### Clean and Restart
```bash
# 1. Clean virtual environment
rm -rf VMEvalKit/envs/hunyuan-video-i2v

# 2. Re-run setup
bash jobs/setup_hunyuan_only.sh

# 3. Reinstall flash-attention
sbatch jobs/install_flash_attention.slurm

# 4. Wait for completion, then resubmit jobs
./jobs/submit_all_hunyuan.sh
```

### Disk Space Issues
```bash
# Check usage
du -sh data/outputs/
du -sh VMEvalKit/envs/
du -sh VMEvalKit/submodules/HunyuanVideo-I2V/ckpts/

# Clean up old outputs (CAREFUL!)
# rm -rf data/outputs/hunyuan-video-i2v/  # Only if backed up to S3!

# Clean pip cache
rm -rf ~/.cache/pip/
```

---

## Performance Optimization

### Reduce Memory Usage
1. Lower video resolution (540p instead of 720p)
2. Reduce video length (64 frames instead of 129)
3. Enable CPU offloading (already default)

### Speed Up Generation
1. ✅ Use flash-attention (already configured)
2. ✅ Use CPU offloading (already default)
3. Consider FP8 inference (requires additional setup)
4. Multi-GPU with xDiT (requires xfuser package)

---

## Known Issues

### Issue: Deepspeed import error on fresh setup
**Status**: ✅ FIXED - deepspeed import made optional
**Patch location**: `VMEvalKit/submodules/HunyuanVideo-I2V/hyvideo/utils/helpers.py`

### Issue: NumPy 2.x breaks pandas/pyarrow  
**Status**: ✅ FIXED - numpy pinned to 1.26.4
**Location**: `jobs/setup_hunyuan_only.sh`

### Issue: No ARM64 wheels for old package versions
**Status**: ✅ FIXED - upgraded to wheel-available versions
**Documented**: See Phase 4 in `AGENT_HISTORY.md`

---

## Contact & Support

### Before Asking for Help

1. ✅ Read [QUICKSTART.md](QUICKSTART.md)
2. ✅ Check this troubleshooting guide
3. ✅ Review [AGENT_HISTORY.md](AGENT_HISTORY.md)
4. ✅ Run `./jobs/check_setup.sh`
5. ✅ Check job logs: `logs/hunyuan_G*_<JOBID>.{out,err}`

### Include in Bug Reports

```bash
# System info
uname -a
module list

# Environment info
source VMEvalKit/envs/hunyuan-video-i2v/bin/activate
python --version
pip list | grep -E "torch|flash|diffusers"

# Job info (if job-related)
squeue -j <JOBID>
cat logs/hunyuan_G*_<JOBID>.err | tail -100

# Checkpoint status
ls -lh VMEvalKit/submodules/HunyuanVideo-I2V/ckpts/
```

---

## FAQs

### Q: How long does setup take?
**A**: ~40 minutes total:
- Environment setup: ~10 min
- Flash-attention compilation: ~30 min (first time), ~3 sec (cached wheel)

### Q: Can I use this on x86_64 systems?
**A**: Yes, but use standard installation (no ARM64-specific fixes needed). Flash-attention has pre-built x86_64 wheels.

### Q: Do I need flash-attention?
**A**: Highly recommended - 40-50% speedup for essentially no downsides. But HunyuanVideo will work without it (just slower).

### Q: Can I run multiple jobs per GPU?
**A**: Not recommended - HunyuanVideo uses 60-80GB VRAM per job. GH200 has 97GB, so only 1 job per GPU.

### Q: How do I update to newer HunyuanVideo version?
**A**:
```bash
cd VMEvalKit/submodules/HunyuanVideo-I2V
git pull origin main
cd ../../..
# Re-run setup if requirements changed
bash jobs/setup_hunyuan_only.sh
```

### Q: Can I use other models besides HunyuanVideo?
**A**: Yes! VMEvalKit supports 29+ models. See `VMEvalKit/docs/MODELS.md`. Each requires its own setup script.

---

**Last Updated**: January 12, 2026  
**System**: NCSA Delta Grace-Hopper GH200  
**Status**: ✅ All issues resolved, production ready
