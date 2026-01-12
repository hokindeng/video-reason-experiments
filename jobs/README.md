# Jobs Directory

## Flash-Attention ✅
- **`FLASH_ATTENTION_SUCCESS.md`** - Complete setup guide and summary
- **`install_flash_attention.slurm`** - Working batch job (only file you need)

**Status**: ✅ **INSTALLED** - flash-attention 2.7.4.post1 working on Grace-Hopper HPC

## HunyuanVideo Jobs
- **`hunyuan_jobs/`** - All 50 HunyuanVideo inference jobs and submit scripts
- **`submit_all_hunyuan.sh`** - Submit all 50 jobs at once
- **`generate_all_hunyuan_jobs.py`** - Generate the job files

## Other
- **`check_setup.sh`** - Setup verification
- **`setup_hunyuan_only.sh`** - HunyuanVideo-only setup
- **`test_with_mail.slurm`** - Test job with email notifications

## Quick Commands
```bash
# Install flash-attention (if not already done)
sbatch jobs/install_flash_attention.slurm

# Submit all HunyuanVideo jobs
./jobs/submit_all_hunyuan.sh

# Check job status
squeue -u $USER
```
