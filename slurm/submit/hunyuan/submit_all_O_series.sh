#!/bin/bash
#
# Submit all O-series hunyuan-video-i2v inference jobs
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

cd "$PROJECT_ROOT"

echo "🚀 Submitting all O-series hunyuan-video-i2v jobs..."
echo "   Total tasks: 50"
echo "   Model: hunyuan-video-i2v"
echo ""

# Array to store job IDs
declare -a JOB_IDS

# Submit all O-series jobs
for i in {1..50}; do
    echo "Submitting: O-$i"
    SUBMIT_SCRIPT="$SCRIPT_DIR/submit_hunyuan_O${i}.sh"
    
    if [[ -f "$SUBMIT_SCRIPT" ]]; then
        JOB_ID=$(bash "$SUBMIT_SCRIPT" 2>&1 | grep "Job ID:" | awk '{print $NF}')
        if [[ -n "$JOB_ID" ]]; then
            JOB_IDS+=($JOB_ID)
            echo "  ✓ Job ID: $JOB_ID"
        else
            echo "  ✗ Failed to submit"
        fi
    else
        echo "  ⚠ Script not found: $SUBMIT_SCRIPT"
    fi
done

echo ""
echo "✅ All O-series jobs submitted!"
echo ""
echo "Submitted job IDs: ${JOB_IDS[@]}"
echo ""
echo "Monitor all jobs with:"
echo "   squeue -u $USER"
echo ""
echo "View O-series jobs:"
echo "   squeue -u $USER | grep 'hunyuan-O'"
echo ""
echo "Cancel all O-series jobs if needed:"
echo "   scancel -u $USER -n 'hunyuan-O*'"
