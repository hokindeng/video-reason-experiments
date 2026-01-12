#!/bin/bash
#SBATCH --job-name=hunyuan-G18
#SBATCH --account=bdqf-dtai-gh
#SBATCH --partition=ghx4
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=8
#SBATCH --gpus-per-node=1
#SBATCH --mem-per-gpu=80G
#SBATCH --time=48:00:00
#SBATCH --output=/u/yli8/hokin/video-reason-experiments/logs/hunyuan_G18_%j.out
#SBATCH --error=/u/yli8/hokin/video-reason-experiments/logs/hunyuan_G18_%j.err

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
cd /u/yli8/hokin/video-reason-experiments

# Run inference
echo "Starting inference..."
echo "Model: hunyuan-video-i2v"
echo "Task: G-18_grid_shortest_path_data-generator"
echo "Questions dir: ./data/questions/G-18_grid_shortest_path_data-generator"
echo ""

./scripts/run_inference.sh \
    --model hunyuan-video-i2v \
    --gpu 0 \
    --questions-dir ./data/questions/G-18_grid_shortest_path_data-generator \
    --skip-setup

exit_code=$?

# Print completion information
echo ""
echo "=========================================="
echo "Job completed with exit code: $exit_code"
echo "End Time: $(date)"
echo "=========================================="

exit $exit_code
