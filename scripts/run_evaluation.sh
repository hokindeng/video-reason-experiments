#!/bin/bash
#
# Simple wrapper for running VMEvalKit evaluation experiments.
# Calls VMEvalKit's score_videos.py with evaluation configs.
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VMEVALKIT_DIR="$SCRIPT_DIR/../VMEvalKit"
SCORE_SCRIPT="$VMEVALKIT_DIR/examples/score_videos.py"

usage() {
    echo "Usage: $0 --eval-method <method> [--evaluator <evaluator>]"
    echo ""
    echo "Options:"
    echo "  --eval-method    Evaluation method: multi_frame_uniform | keyframe_detection | hybrid_sampling | last_frame"
    echo "  --evaluator      VLM evaluator: gpt4o | internvl | qwen (optional, overrides config default)"
    echo ""
    echo "Examples:"
    echo "  $0 --eval-method last_frame"
    echo "  $0 --eval-method last_frame --evaluator internvl"
    exit 1
}

# Parse arguments
EVAL_METHOD=""
EVALUATOR=""
while [[ $# -gt 0 ]]; do
    case $1 in
        --eval-method)
            EVAL_METHOD="$2"
            shift 2
            ;;
        --evaluator)
            EVALUATOR="$2"
            shift 2
            ;;
        *)
            echo "❌ Unknown option: $1"
            usage
            ;;
    esac
done

# Validate eval method
if [[ -z "$EVAL_METHOD" ]]; then
    echo "❌ --eval-method is required"
    usage
fi

case "$EVAL_METHOD" in
    multi_frame_uniform|keyframe_detection|hybrid_sampling|last_frame)
        ;;
    *)
        echo "❌ Invalid eval method: $EVAL_METHOD"
        echo "   Must be one of: multi_frame_uniform, keyframe_detection, hybrid_sampling, last_frame"
        exit 1
        ;;
esac

# Get config path
CONFIG_PATH="$SCRIPT_DIR/../configs/eval/${EVAL_METHOD}.json"

if [[ ! -f "$CONFIG_PATH" ]]; then
    echo "❌ Config not found: $CONFIG_PATH"
    exit 1
fi

echo "🚀 Running evaluation: $EVAL_METHOD"
echo "📄 Config: $CONFIG_PATH"

# Build Python command
PYTHON_CMD="python \"$SCORE_SCRIPT\" --eval-config \"$CONFIG_PATH\""

# Add evaluator if specified
if [[ -n "$EVALUATOR" ]]; then
    PYTHON_CMD="$PYTHON_CMD --evaluator \"$EVALUATOR\""
    echo "🤖 Evaluator: $EVALUATOR (overriding config)"
else
    echo "🤖 Evaluator: (from config file)"
fi

# Execute VMEvalKit
cd "$VMEVALKIT_DIR"
eval $PYTHON_CMD

