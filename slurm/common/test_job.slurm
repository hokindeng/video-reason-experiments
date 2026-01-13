#!/bin/bash
#SBATCH --job-name=test-mail
#SBATCH --account=bdqf-dtai-gh
#SBATCH --partition=ghx4
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=8
#SBATCH --gpus-per-node=1
#SBATCH --mem-per-gpu=80G
#SBATCH --time=00:10:00
#SBATCH --output=/u/yli8/hokin/video-reason-experiments/logs/test_mail_%j.out
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=$USER@$(hostname -d)

echo "Test with mail directives successful!"
hostname
nvidia-smi

