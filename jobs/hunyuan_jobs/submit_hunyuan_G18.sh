#!/bin/bash
#
# Submit hunyuan-video-i2v inference job for G-18_grid_shortest_path_data-generator
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

JOB_FILE="$SCRIPT_DIR/hunyuan_G18.slurm"

echo "🚀 Submitting inference job..."
echo "   Model: hunyuan-video-i2v"
echo "   Task: G-18_grid_shortest_path_data-generator"
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
echo "   tail -f logs/hunyuan_G18_${JOB_ID}.out"
echo "   tail -f logs/hunyuan_G18_${JOB_ID}.err"
echo ""
echo "Cancel job if needed:"
echo "   scancel $JOB_ID"
