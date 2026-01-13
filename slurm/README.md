# SLURM Job Management

Organized collection of HPC setup scripts, job generators, and submission utilities for running video generation models on SLURM clusters.

---

## 📁 Directory Structure

```
slurm/
├── README.md                                    # This file
│
├── common/                                      # Shared utilities (all models)
│   ├── check_setup.sh                          # Pre-flight validation
│   ├── test_job.slurm                          # Test SLURM configuration
│   └── templates/                              # Reusable templates
│
├── submit/                                      # Submit scripts (all models)
│   └── hunyuan/                                # HunyuanVideo submitters
│       ├── submit_all.sh                       # Submit all 50 jobs
│       ├── submit_hunyuan_G1.sh                # Individual job submitters
│       └── ... (50 scripts)
│
└── hunyuan-video-i2v/                          # HunyuanVideo model
    ├── setup/                                  # Environment setup
    │   ├── setup_environment.sh                # Create venv + install deps
    │   ├── install_flash_attention.slurm       # Compile flash-attention
    │   └── config.py                           # HPC configuration (future)
    │
    ├── jobs/                                   # Job generation + scripts
    │   ├── generate_jobs.py                    # Generate SLURM scripts
    │   └── generated/                          # Auto-generated (gitignored)
    │       ├── hunyuan_G1.slurm                # SLURM batch scripts
    │       └── ... (50 scripts)
    │
    └── docs/                                   # Documentation
        ├── SETUP_GUIDE.md                      # Setup instructions
        └── FLASH_ATTENTION.md                  # Flash-attention guide
```

---

## 🚀 Quick Start

### One-Time Setup

```bash
# 1. Setup environment (~10 min + checkpoint downloads)
bash slurm/hunyuan-video-i2v/setup/setup_environment.sh

# 2. Install flash-attention (~30 min first time, 3s cached)
sbatch slurm/hunyuan-video-i2v/setup/install_flash_attention.slurm

# 3. Verify everything is ready
./slurm/common/check_setup.sh

# 4. Generate job scripts
python3 slurm/hunyuan-video-i2v/jobs/generate_jobs.py
```

### Running Jobs

```bash
# Submit all 50 jobs (requests 50 GPUs)
./slurm/submit/hunyuan/submit_all.sh

# Submit single job
./slurm/submit/hunyuan/submit_hunyuan_G1.sh

# Submit range of jobs
for i in {1..10}; do ./slurm/submit/hunyuan/submit_hunyuan_G$i.sh; done
```

### Monitoring

```bash
# Check job status
squeue -u $USER

# Watch specific job output
tail -f logs/hunyuan_G1_<JOBID>.out

# Count generated videos
find data/outputs/hunyuan-video-i2v -name "*.mp4" | wc -l
```

---

## 📋 File Descriptions

### `common/` - Shared Utilities

#### `check_setup.sh`
Pre-flight validation script that checks:
- Questions directory exists (with G-* tasks)
- Scripts are present and executable
- Model virtual environment exists
- SLURM commands available
- Partition accessible

#### `test_job.slurm`
Test SLURM configuration:
- Email notifications
- GPU allocation
- Module loading
- Job submission workflow

### `submit/` - Job Submission

All bash convenience scripts for submitting jobs. Organized by model:
- **`hunyuan/`** - HunyuanVideo submission scripts
  - `submit_all.sh` - Submit all 50 G-series tasks
  - `submit_hunyuan_G*.sh` - Individual task submitters (50 files)

### `hunyuan-video-i2v/` - HunyuanVideo Model

Complete HPC setup for HunyuanVideo-I2V (720p image-to-video generation):

#### `setup/` - Environment Setup
- **`setup_environment.sh`** - Creates ARM64-compatible virtual environment
  - Installs PyTorch 2.7+cu126 dependencies
  - Downloads model checkpoints (~40GB)
  - Runtime: ~10 minutes + downloads
  
- **`install_flash_attention.slurm`** - Compiles flash-attention from source
  - Handles ARM64 (aarch64) architecture
  - Uses compatible GCC version
  - Runtime: 15-30 min (first time), 3s (cached)

#### `jobs/` - Job Management
- **`generate_jobs.py`** - Generates SLURM batch scripts
  - Creates one script per task (50 total)
  - Generates corresponding submit helpers
  - Configurable resources (GPU, memory, time)
  
- **`generated/`** - Auto-generated files (gitignored)
  - Contains 50 SLURM batch scripts
  - Regenerate with `generate_jobs.py`

#### `docs/` - Documentation
- **`SETUP_GUIDE.md`** - Complete setup instructions
- **`FLASH_ATTENTION.md`** - Flash-attention troubleshooting

---

## 🔧 Adding New Models

To add a new model (e.g., `stable-diffusion-3`):

```bash
# 1. Create directory structure
mkdir -p slurm/stable-diffusion-3/{setup,jobs/generated,docs}
mkdir -p slurm/submit/stable-diffusion-3

# 2. Copy template files
cp slurm/hunyuan-video-i2v/setup/setup_environment.sh slurm/stable-diffusion-3/setup/
cp slurm/hunyuan-video-i2v/jobs/generate_jobs.py slurm/stable-diffusion-3/jobs/

# 3. Customize for your model
# - Edit setup scripts with model-specific dependencies
# - Update generate_jobs.py with model configuration
# - Create documentation

# 4. Generate and submit
python3 slurm/stable-diffusion-3/jobs/generate_jobs.py
./slurm/submit/stable-diffusion-3/submit_all.sh
```

---

## 📊 Resource Configuration

### HunyuanVideo-I2V Defaults
- **Partition**: ghx4 (Grace-Hopper)
- **GPUs per job**: 1 (80GB VRAM)
- **CPUs per task**: 8
- **Time limit**: 48 hours
- **Memory**: 80G per GPU

Edit in `slurm/hunyuan-video-i2v/jobs/generate_jobs.py`:
```python
PARTITION = "ghx4"
GPUS_PER_NODE = 1
CPUS_PER_TASK = 8
TIME_LIMIT = "48:00:00"
MEMORY_PER_GPU = "80G"
```

---

## 🎯 Current Status

### ✅ Models Configured
- **HunyuanVideo-I2V** - Production ready
  - Environment: Installed
  - Flash-attention: Compiled and working
  - Jobs: 50 tasks generated

### 📁 Generated Files
All auto-generated files live in `slurm/*/jobs/generated/` and are gitignored. Regenerate with:
```bash
python3 slurm/hunyuan-video-i2v/jobs/generate_jobs.py
```

---

## 📖 Related Documentation

- **[Project README](../README.md)** - Project overview
- **[HunyuanVideo Setup Guide](hunyuan-video-i2v/docs/SETUP_GUIDE.md)** - Detailed setup
- **[Flash-Attention Guide](hunyuan-video-i2v/docs/FLASH_ATTENTION.md)** - Compilation troubleshooting

---

**Organization**: HPC setup and SLURM job management  
**Last Updated**: January 13, 2026  
**Status**: ✅ Production Ready
