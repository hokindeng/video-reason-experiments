#!/bin/bash
#
# Submit hunyuan-video-i2v inference job for G-17_grid_avoid_red_block_data-generator
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

cd "$PROJECT_ROOT"

JOB_FILE="$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_G17.slurm"

echo "🚀 Submitting inference job..."
echo "   Model: hunyuan-video-i2v"
echo "   Task: G-17_grid_avoid_red_block_data-generator"
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
echo "   tail -f video-reason-experiments/logs/hunyuan_G17_${JOB_ID}.out"
echo "   tail -f video-reason-experiments/logs/hunyuan_G17_${JOB_ID}.err"
echo ""
echo "Cancel job if needed:"
echo "   scancel $JOB_ID"
