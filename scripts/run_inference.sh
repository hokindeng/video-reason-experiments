#!/bin/bash

set -euo pipefail

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
VMEVALKIT_DIR="$PROJECT_ROOT/VMEvalKit"
GENERATE_SCRIPT="$VMEVALKIT_DIR/examples/generate_videos.py"
QUESTIONS_DIR="$PROJECT_ROOT/data/questions"
OUTPUT_DIR="$PROJECT_ROOT/data/outputs"

# Default values
MODEL=""
GPU=""
SKIP_SETUP=false
CUSTOM_QUESTIONS_DIR=""

# Help function
show_help() {
    cat << EOF
Usage: $0 --model MODEL [OPTIONS]

Run VMEvalKit inference on all tasks

Required arguments:
    --model MODEL                Model to run

Optional arguments:
    --gpu GPU                    GPU device ID to use
    --skip-setup                 Skip model setup
    --questions-dir DIR          Custom questions directory (default: data/questions)
    -h, --help                   Show this help message

Examples:
    $0 --model hunyuan-video-i2v
    $0 --model hunyuan-video-i2v --gpu 0
    $0 --model hunyuan-video-i2v --skip-setup
    $0 --model hunyuan-video-i2v --questions-dir ./custom_questions
EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --model)
            MODEL="$2"
            shift 2
            ;;
        --gpu)
            GPU="$2"
            shift 2
            ;;
        --skip-setup)
            SKIP_SETUP=true
            shift
            ;;
        --questions-dir)
            CUSTOM_QUESTIONS_DIR="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "❌ Unknown option: $1" >&2
            echo "Use --help for usage information." >&2
            exit 1
            ;;
    esac
done

# Validate required arguments
if [[ -z "$MODEL" ]]; then
    echo "❌ Error: --model is required" >&2
    echo "Use --help for usage information." >&2
    exit 1
fi

# Setup model function
setup_model() {
    local model_name="$1"
    local setup_script="$VMEVALKIT_DIR/setup/models/$model_name/setup.sh"
    
    if [[ ! -f "$setup_script" ]]; then
        echo "⚠️  No setup script found for model: $model_name"
        return 0
    fi
    
    # Check if model is already set up
    local checkpoint_path=""
    case "$model_name" in
        "hunyuan-video-i2v")
            checkpoint_path="$VMEVALKIT_DIR/submodules/HunyuanVideo-I2V/ckpts/text_encoder_2"
            ;;
        "cogvideox-5b-i2v")
            checkpoint_path="$VMEVALKIT_DIR/submodules/CogVideoX/ckpts"
            ;;
        "ltx-video")
            checkpoint_path="$VMEVALKIT_DIR/submodules/ltx-video/ckpts"
            ;;
    esac
    
    if [[ -n "$checkpoint_path" && -d "$checkpoint_path" ]]; then
        echo "✅ Model $model_name already set up"
        return 0
    fi
    
    echo "🔧 Setting up model: $model_name"
    
    # Make setup script executable and run it
    chmod +x "$setup_script"
    if ! "$setup_script"; then
        echo "❌ Model setup failed for: $model_name" >&2
        return 1
    fi
    
    echo "✅ Model setup completed for: $model_name"
    return 0
}

# Main execution
main() {
    # Use custom questions directory if provided, otherwise use default
    local questions_dir="${CUSTOM_QUESTIONS_DIR:-$QUESTIONS_DIR}"
    
    echo "🎯 VMEvalKit Inference Runner"
    echo "Model: $MODEL"
    [[ -n "$GPU" ]] && echo "GPU: $GPU"
    echo "Questions dir: $questions_dir"
    echo "Output dir: $OUTPUT_DIR"
    echo

    # Setup model if needed
    if [[ "$SKIP_SETUP" == false ]]; then
        if ! setup_model "$MODEL"; then
            exit 1
        fi
    fi
    
    # Build command array
    cmd_args=(
        "python" "$GENERATE_SCRIPT"
        "--model" "$MODEL"
        "--questions-dir" "$questions_dir"
        "--output-dir" "$OUTPUT_DIR"
    )
    
    # Add GPU option if specified
    if [[ -n "$GPU" ]]; then
        cmd_args+=("--gpu" "$GPU")
    fi
    
    # Print command being executed
    echo "🚀 Running: ${cmd_args[*]}"
    echo "Working directory: $VMEVALKIT_DIR"
    echo "$(printf '=%.0s' {1..80})"
    
    # Execute with real-time output streaming
    cd "$VMEVALKIT_DIR"
    
    # Use unbuffered output and exec to replace shell with python process
    export PYTHONUNBUFFERED=1
    
    # Execute the command with real-time streaming
    if "${cmd_args[@]}"; then
        echo "$(printf '=%.0s' {1..80})"
        echo "✅ Process completed successfully"
        exit 0
    else
        local exit_code=$?
        echo "$(printf '=%.0s' {1..80})"
        echo "❌ Process failed with exit code: $exit_code"
        exit $exit_code
    fi
}

# Run main function
main "$@"
