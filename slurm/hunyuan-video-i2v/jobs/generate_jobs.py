#!/usr/bin/env python3
"""
SLURM Job Generator for HunyuanVideo-I2V Inference

PURPOSE:
    Automatically generate SLURM batch job scripts for all tasks in data/questions/.
    Each task gets its own job script + individual submit script for flexibility.

USAGE:
    python3 slurm/hunyuan-video-i2v/jobs/generate_jobs.py

OUTPUT:
    - slurm/hunyuan-video-i2v/jobs/generated/hunyuan_G*.slurm (50 SLURM scripts)
    - slurm/submit/hunyuan/submit_hunyuan_G*.sh (50 submit helpers)
    - slurm/submit/hunyuan/submit_all.sh (master submit script)

CONFIGURATION:
    - Model: hunyuan-video-i2v (720p image-to-video)
    - Resources: 1 GPU, 8 CPUs, 80GB VRAM per job
    - Time limit: 48 hours (full partition maximum)
    - Partition: ghx4 (Grace-Hopper nodes)

REQUIREMENTS:
    - data/questions/ must contain G-* task directories
    - VMEvalKit submodule must be initialized
    - scripts/run_inference.sh must exist

NOTES:
    - Each job processes 50 videos (one task)
    - Jobs use --skip-setup flag (assumes environment pre-configured)
    - Logs save to logs/hunyuan_G*_<JOBID>.{out,err}
"""

from pathlib import Path
import re

# ============================================================================
# CONFIGURATION - Modify these for your HPC environment
# ============================================================================

PROJECT_ROOT = Path(__file__).parent.parent.parent.parent
QUESTIONS_DIR = PROJECT_ROOT / "data" / "questions"
JOBS_OUTPUT_DIR = PROJECT_ROOT / "slurm" / "hunyuan-video-i2v" / "jobs" / "generated"
SUBMIT_OUTPUT_DIR = PROJECT_ROOT / "slurm" / "submit" / "hunyuan"

# Model configuration
MODEL_NAME = "hunyuan-video-i2v"  # HunyuanVideo 720p image-to-video

# SLURM configuration (adjust for your cluster)
PARTITION = "ghx4"                # Grace-Hopper partition
ACCOUNT = "bdqf-dtai-gh"          # Your SLURM account
GPUS_PER_NODE = 1                 # HunyuanVideo needs 1 GPU per job
CPUS_PER_TASK = 8                 # 8 CPUs for data loading/preprocessing
TIME_LIMIT = "48:00:00"           # 48 hours (50 videos × ~3-5 min each)
MEMORY_PER_GPU = "80G"            # 80GB VRAM (HunyuanVideo uses ~60-70GB)

# SLURM job template
SLURM_TEMPLATE = """#!/bin/bash
#SBATCH --job-name={job_name}
#SBATCH --account={account}
#SBATCH --partition={partition}
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task={cpus}
#SBATCH --gpus-per-node={gpus}
#SBATCH --mem-per-gpu={memory}
#SBATCH --time={time_limit}
#SBATCH --output={project_dir}/logs/{log_prefix}_%j.out
#SBATCH --error={project_dir}/logs/{log_prefix}_%j.err

# Print job information
echo "=========================================="
echo "Job ID: $SLURM_JOB_ID"
echo "Job Name: $SLURM_JOB_NAME"
echo "Node: $SLURM_NODELIST"
echo "Start Time: $(date)"
echo "Working Directory: $SLURM_SUBMIT_DIR"
echo "=========================================="
echo ""

# Load required modules
module load python/miniforge3_pytorch/2.7.0
module load cuda/12.6.1

# Print loaded modules
echo "Loaded modules:"
module list
echo ""

# Print GPU information
echo "GPU Information:"
nvidia-smi
echo ""

# Change to project directory
cd {project_dir}

# Run inference
echo "Starting inference..."
echo "Model: {model_name}"
echo "Task: {task_name}"
echo "Questions dir: {questions_dir}"
echo ""

./scripts/run_inference.sh \\
    --model {model_name} \\
    --gpu 0 \\
    --questions-dir {questions_dir} \\
    --skip-setup

exit_code=$?

# Print completion information
echo ""
echo "=========================================="
echo "Job completed with exit code: $exit_code"
echo "End Time: $(date)"
echo "=========================================="

exit $exit_code
"""

def extract_task_number(dirname):
    """Extract task number from directory name like G-7 or O-15"""
    match = re.match(r'([GO])-(\d+)', dirname)
    if match:
        series = match.group(1)
        number = int(match.group(2))
        return (series, number)
    return None

def generate_job_scripts():
    """Generate SLURM job scripts for all tasks"""
    
    # Get all question directories
    if not QUESTIONS_DIR.exists():
        print(f"❌ Questions directory not found: {QUESTIONS_DIR}")
        return []
    
    task_dirs = sorted([d for d in QUESTIONS_DIR.iterdir() if d.is_dir()], 
                      key=lambda x: extract_task_number(x.name) or ('Z', 999))
    
    print(f"📂 Found {len(task_dirs)} tasks in {QUESTIONS_DIR}")
    print()
    
    generated_files = []
    
    for task_dir in task_dirs:
        task_name = task_dir.name
        task_info = extract_task_number(task_name)
        
        if task_info is None:
            print(f"⚠️  Skipping {task_name} (couldn't extract task number)")
            continue
        
        series, task_num = task_info
        
        # Generate short names for files
        task_short = f"{series}{task_num}"
        job_name = f"hunyuan-{task_short}"
        log_prefix = f"hunyuan_{task_short}"
        slurm_file = JOBS_OUTPUT_DIR / f"hunyuan_{task_short}.slurm"
        
        # Create SLURM script content
        content = SLURM_TEMPLATE.format(
            job_name=job_name,
            account=ACCOUNT,
            partition=PARTITION,
            cpus=CPUS_PER_TASK,
            gpus=GPUS_PER_NODE,
            memory=MEMORY_PER_GPU,
            time_limit=TIME_LIMIT,
            log_prefix=log_prefix,
            project_dir=PROJECT_ROOT,
            model_name=MODEL_NAME,
            task_name=task_name,
            questions_dir=f"./data/questions/{task_name}"
        )
        
        # Write SLURM script
        slurm_file.write_text(content)
        slurm_file.chmod(0o755)
        
        generated_files.append({
            'series': series,
            'task_num': task_num,
            'task_name': task_name,
            'slurm_file': slurm_file,
            'job_name': job_name
        })
        
        print(f"✅ Generated: {slurm_file.name} (Task: {task_name})")
    
    return generated_files

def generate_master_submit_script(job_files):
    """Generate a master script to submit all jobs"""
    
    submit_script = SUBMIT_OUTPUT_DIR / "submit_all.sh"
    
    content = """#!/bin/bash
#
# Submit all hunyuan-video-i2v inference jobs
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

cd "$PROJECT_ROOT"

echo "🚀 Submitting all hunyuan-video-i2v jobs..."
echo "   Total tasks: """ + str(len(job_files)) + """"
echo "   Model: """ + MODEL_NAME + """"
echo ""

# Array to store job IDs
declare -a JOB_IDS

"""
    
    for job_info in job_files:
        slurm_filename = job_info['slurm_file'].name
        content += f"""
# Submit {job_info['task_name']}
echo "Submitting: {job_info['task_name']}"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/{slurm_filename}")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"
"""
    
    content += """
echo ""
echo "✅ All jobs submitted successfully!"
echo ""
echo "Submitted job IDs: ${JOB_IDS[@]}"
echo ""
echo "Monitor all jobs with:"
echo "   squeue -u $USER"
echo ""
echo "View summary:"
echo "   squeue -u $USER | grep hunyuan"
echo ""
echo "Cancel all jobs if needed:"
echo "   scancel ${JOB_IDS[@]}"
echo ""
echo "Or cancel all hunyuan jobs:"
echo "   scancel -u $USER -n hunyuan-G*"
"""
    
    submit_script.write_text(content)
    submit_script.chmod(0o755)
    
    print()
    print(f"✅ Generated master submission script: {submit_script}")
    
    return submit_script

def generate_individual_submit_scripts(job_files):
    """Generate individual submission scripts for each task"""
    
    for job_info in job_files:
        task_short = f"{job_info['series']}{job_info['task_num']}"
        submit_script = SUBMIT_OUTPUT_DIR / f"submit_hunyuan_{task_short}.sh"
        slurm_filename = job_info['slurm_file'].name
        
        content = f"""#!/bin/bash
#
# Submit hunyuan-video-i2v inference job for {job_info['task_name']}
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${{BASH_SOURCE[0]}}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

cd "$PROJECT_ROOT"

JOB_FILE="$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/{slurm_filename}"

echo "🚀 Submitting inference job..."
echo "   Model: {MODEL_NAME}"
echo "   Task: {job_info['task_name']}"
echo ""

# Submit the job
JOB_ID=$(sbatch --parsable "$JOB_FILE")

echo "✅ Job submitted successfully!"
echo "   Job ID: $JOB_ID"
echo ""
echo "Monitor your job with:"
echo "   squeue -j $JOB_ID"
echo "   squeue -u $USER"
echo ""
echo "View logs in real-time:"
echo "   tail -f video-reason-experiments/logs/hunyuan_{task_short}_${{JOB_ID}}.out"
echo "   tail -f video-reason-experiments/logs/hunyuan_{task_short}_${{JOB_ID}}.err"
echo ""
echo "Cancel job if needed:"
echo "   scancel $JOB_ID"
"""
        
        submit_script.write_text(content)
        submit_script.chmod(0o755)

def main():
    print("=" * 60)
    print("Hunyuan-Video-I2V Batch Job Generator")
    print("=" * 60)
    print()
    print(f"📋 Configuration:")
    print(f"   Model: {MODEL_NAME}")
    print(f"   Partition: {PARTITION}")
    print(f"   GPUs per job: {GPUS_PER_NODE}")
    print(f"   Memory per GPU: {MEMORY_PER_GPU}")
    print(f"   Time limit: {TIME_LIMIT}")
    print()
    
    # Create logs directory if it doesn't exist
    logs_dir = PROJECT_ROOT / "logs"
    logs_dir.mkdir(parents=True, exist_ok=True)
    
    # Generate all job scripts
    job_files = generate_job_scripts()
    
    if not job_files:
        print("❌ No jobs generated!")
        return
    
    print()
    print(f"📝 Generated {len(job_files)} SLURM job scripts")
    print()
    
    # Generate individual submit scripts
    generate_individual_submit_scripts(job_files)
    print(f"✅ Generated {len(job_files)} individual submission scripts")
    print()
    
    # Generate master submit script
    master_script = generate_master_submit_script(job_files)
    
    print()
    print("=" * 60)
    print("🎉 All job scripts generated successfully!")
    print("=" * 60)
    print()
    print("📖 Usage:")
    print()
    print("  1. Submit ALL jobs at once:")
    print(f"     ./slurm/submit/hunyuan/submit_all.sh")
    print()
    print("  2. Submit individual jobs:")
    print(f"     ./slurm/submit/hunyuan/submit_hunyuan_G1.sh")
    print(f"     ./slurm/submit/hunyuan/submit_hunyuan_G7.sh")
    print("     ... etc")
    print()
    print("  3. Submit range of jobs:")
    print("     for i in {{1..10}}; do ./slurm/submit/hunyuan/submit_hunyuan_G$i.sh; done")
    print()
    print("⚠️  Note: Submitting all 50 jobs will use 50 GPUs simultaneously!")
    print()

if __name__ == "__main__":
    main()

