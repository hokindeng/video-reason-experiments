#!/usr/bin/env python3
"""
VMEvalKit Inference Runner

Run VMEvalKit inference on all tasks.
"""

import argparse
import os
import subprocess
import sys
from pathlib import Path


# Script configuration
SCRIPT_DIR = Path(__file__).resolve().parent
PROJECT_ROOT = SCRIPT_DIR.parent
VMEVALKIT_DIR = PROJECT_ROOT / "VMEvalKit"
GENERATE_SCRIPT = VMEVALKIT_DIR / "examples" / "generate_videos.py"
QUESTIONS_DIR = PROJECT_ROOT / "data" / "questions"
OUTPUT_DIR = PROJECT_ROOT / "data" / "outputs"

# Model checkpoint paths for checking if model is already set up
MODEL_CHECKPOINT_PATHS = {
    "hunyuan-video-i2v": VMEVALKIT_DIR / "submodules" / "HunyuanVideo-I2V" / "ckpts" / "text_encoder_2",
    "cogvideox-5b-i2v": VMEVALKIT_DIR / "submodules" / "CogVideoX" / "ckpts",
    "ltx-video": VMEVALKIT_DIR / "submodules" / "ltx-video" / "ckpts",
}


def setup_model(model_name: str) -> bool:
    """
    Setup model if needed.
    
    Args:
        model_name: Name of the model to setup
        
    Returns:
        True if setup succeeded or was skipped, False on failure
    """
    setup_script = VMEVALKIT_DIR / "setup" / "models" / model_name / "setup.sh"
    
    if not setup_script.exists():
        print(f"⚠️  No setup script found for model: {model_name}")
        return True
    
    # Check if model is already set up
    checkpoint_path = MODEL_CHECKPOINT_PATHS.get(model_name)
    if checkpoint_path and checkpoint_path.is_dir():
        print(f"✅ Model {model_name} already set up")
        return True
    
    print(f"🔧 Setting up model: {model_name}")
    
    # Make setup script executable and run it
    setup_script.chmod(setup_script.stat().st_mode | 0o111)
    
    try:
        result = subprocess.run(
            [str(setup_script)],
            check=True,
        )
        print(f"✅ Model setup completed for: {model_name}")
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ Model setup failed for: {model_name}", file=sys.stderr)
        return False


def parse_args() -> argparse.Namespace:
    """Parse command line arguments."""
    parser = argparse.ArgumentParser()
    
    parser.add_argument(
        "--model",
        required=True,
        help="Model to run",
    )
    parser.add_argument(
        "--gpu",
        default=None,
        help="GPU device ID to use",
    )
    parser.add_argument(
        "--skip-setup",
        action="store_true",
        help="Skip model setup",
    )
    parser.add_argument(
        "--questions-dir",
        default=None,
        help=f"Custom questions directory (default: {QUESTIONS_DIR})",
    )
    
    return parser.parse_args()


def main():
    """Main execution function."""
    args = parse_args()
    
    # Use custom questions directory if provided, otherwise use default
    # Convert to absolute path to avoid issues with subprocess cwd
    questions_dir = Path(args.questions_dir).resolve() if args.questions_dir else QUESTIONS_DIR
    
    print("🎯 VMEvalKit Inference Runner")
    print(f"Model: {args.model}")
    if args.gpu:
        print(f"GPU: {args.gpu}")
    print(f"Questions dir: {questions_dir}")
    print(f"Output dir: {OUTPUT_DIR}")
    print()
    
    # Build command list
    cmd = [
        sys.executable,
        str(GENERATE_SCRIPT),
        "--model", args.model,
        "--questions-dir", str(questions_dir),
        "--output-dir", str(OUTPUT_DIR),
    ]
    
    # Add GPU option if specified
    if args.gpu:
        cmd.extend(["--gpu", args.gpu])
    
    # Print command being executed
    print(f"🚀 Running: {' '.join(cmd)}")
    print(f"Working directory: {VMEVALKIT_DIR}")
    print("=" * 80)
    
    # Set environment for unbuffered output
    env = os.environ.copy()
    env["PYTHONUNBUFFERED"] = "1"
    
    result = subprocess.run(
        cmd,
        cwd=VMEVALKIT_DIR,
        env=env,
    )
    
    print("=" * 80)
    
    if result.returncode == 0:
        print("✅ Process completed successfully")
        sys.exit(0)
    else:
        print(f"❌ Process failed with exit code: {result.returncode}")
        sys.exit(result.returncode)


if __name__ == "__main__":
    main()

