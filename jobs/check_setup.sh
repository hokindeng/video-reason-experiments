#!/bin/bash
#
# Pre-flight checks before generating and submitting jobs
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "=========================================="
echo "Pre-Flight Setup Checker"
echo "=========================================="
echo ""

cd "$PROJECT_ROOT"

# Check 1: Questions directory
echo "✓ Checking questions directory..."
QUESTIONS_DIR="$PROJECT_ROOT/data/questions"
if [[ ! -d "$QUESTIONS_DIR" ]]; then
    echo "❌ Questions directory not found: $QUESTIONS_DIR"
    exit 1
fi

TASK_COUNT=$(ls -1d "$QUESTIONS_DIR"/G-* 2>/dev/null | wc -l)
echo "  Found $TASK_COUNT tasks in $QUESTIONS_DIR"
if [[ $TASK_COUNT -eq 0 ]]; then
    echo "❌ No task directories found!"
    exit 1
fi
echo ""

# Check 2: Scripts directory
echo "✓ Checking scripts..."
INFERENCE_SCRIPT="$PROJECT_ROOT/scripts/run_inference.sh"
if [[ ! -f "$INFERENCE_SCRIPT" ]]; then
    echo "❌ Inference script not found: $INFERENCE_SCRIPT"
    exit 1
fi
if [[ ! -x "$INFERENCE_SCRIPT" ]]; then
    echo "⚠️  Making inference script executable..."
    chmod +x "$INFERENCE_SCRIPT"
fi
echo "  Inference script: OK"
echo ""

# Check 3: Model environment
echo "✓ Checking model environment..."
MODEL_ENV="$PROJECT_ROOT/VMEvalKit/envs/hunyuan-video-i2v"
if [[ -d "$MODEL_ENV" ]]; then
    echo "  Model venv exists: $MODEL_ENV"
    echo "  Status: READY (will use --skip-setup)"
else
    echo "  Model venv NOT found: $MODEL_ENV"
    echo "  Status: First run will setup model (slower)"
fi
echo ""

# Check 4: Logs directory
echo "✓ Checking/creating logs directory..."
LOGS_DIR="$PROJECT_ROOT/logs"
if [[ ! -d "$LOGS_DIR" ]]; then
    echo "  Creating logs directory: $LOGS_DIR"
    mkdir -p "$LOGS_DIR"
fi
echo "  Logs directory: $LOGS_DIR"
echo ""

# Check 5: Output directory
echo "✓ Checking/creating output directory..."
OUTPUT_DIR="$PROJECT_ROOT/data/outputs"
if [[ ! -d "$OUTPUT_DIR" ]]; then
    echo "  Creating output directory: $OUTPUT_DIR"
    mkdir -p "$OUTPUT_DIR"
fi
echo "  Output directory: $OUTPUT_DIR"
echo ""

# Check 6: SLURM availability
echo "✓ Checking SLURM..."
if ! command -v sbatch &> /dev/null; then
    echo "❌ sbatch command not found. SLURM not available?"
    exit 1
fi
echo "  SLURM commands: OK"
echo ""

# Check 7: Partition availability
echo "✓ Checking ghx4 partition..."
if sinfo -p ghx4 &> /dev/null; then
    echo "  Partition ghx4: Available"
    sinfo -p ghx4 | head -5
else
    echo "⚠️  Could not check ghx4 partition status"
fi
echo ""

# Check 8: Current job queue
echo "✓ Checking your current jobs..."
JOB_COUNT=$(squeue -u $USER 2>/dev/null | tail -n +2 | wc -l)
echo "  Current jobs running/queued: $JOB_COUNT"
if [[ $JOB_COUNT -gt 0 ]]; then
    echo ""
    squeue -u $USER
fi
echo ""

# Check 9: Python dependencies
echo "✓ Checking Python..."
if ! command -v python3 &> /dev/null; then
    echo "❌ python3 not found"
    exit 1
fi
PYTHON_VERSION=$(python3 --version)
echo "  Python: $PYTHON_VERSION"
echo ""

# Summary
echo "=========================================="
echo "Summary"
echo "=========================================="
echo ""
echo "✅ All pre-flight checks passed!"
echo ""
echo "📊 Configuration:"
echo "   Tasks found: $TASK_COUNT"
echo "   Model: hunyuan-video-i2v"
echo "   Partition: ghx4"
echo "   GPU per job: 1 (80GB VRAM)"
echo "   Time limit: 48 hours (full partition limit)"
echo ""
echo "🚀 Next steps:"
echo ""
echo "  1. Generate job scripts:"
echo "     python3 jobs/generate_all_hunyuan_jobs.py"
echo ""
echo "  2. Review generated files in jobs/"
echo ""
echo "  3. Submit jobs:"
echo "     ./jobs/submit_all_hunyuan.sh      # All 50 jobs"
echo "     ./jobs/hunyuan_jobs/submit_hunyuan_G1.sh       # Single job"
echo "     for i in {1..10}; do ./jobs/hunyuan_jobs/submit_hunyuan_G\$i.sh; done  # First 10"
echo ""
echo "⚠️  Note: Submitting all 50 jobs will request 50 GPUs!"
echo "    Consider submitting in smaller batches."
echo ""

