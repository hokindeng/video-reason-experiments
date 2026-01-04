#!/usr/bin/env python3
"""
Simple wrapper for running VMEvalKit inference on all tasks.
Handles model setup and runs on everything in data/questions.
"""

import subprocess
import sys
from pathlib import Path
import argparse

def setup_model(model_name, vmevalkit_dir):
    """Set up the model if needed."""
    setup_script = vmevalkit_dir / "setup" / "models" / model_name / "setup.sh"
    
    if not setup_script.exists():
        print(f"⚠️  No setup script found for model: {model_name}")
        return True
    
    # Check if model is already set up
    model_checkpoints = {
        "hunyuan-video-i2v": vmevalkit_dir / "submodules" / "HunyuanVideo-I2V" / "ckpts" / "text_encoder_2",
        "cogvideox-5b-i2v": vmevalkit_dir / "submodules" / "CogVideoX" / "ckpts",
        "ltx-video": vmevalkit_dir / "submodules" / "ltx-video" / "ckpts"
    }
    
    checkpoint_path = model_checkpoints.get(model_name)
    if checkpoint_path and checkpoint_path.exists():
        print(f"✅ Model {model_name} already set up")
        return True
    
    print(f"🔧 Setting up model: {model_name}")
    
    # Make setup script executable and run it
    subprocess.run(["chmod", "+x", str(setup_script)], check=True)
    result = subprocess.run([str(setup_script)], cwd=vmevalkit_dir)
    
    if result.returncode != 0:
        print(f"❌ Model setup failed for: {model_name}")
        return False
    
    print(f"✅ Model setup completed for: {model_name}")
    return True

def main():
    parser = argparse.ArgumentParser(description="Run VMEvalKit inference on all tasks")
    parser.add_argument("--model", required=True, help="Model to run")
    parser.add_argument("--gpu", type=int, help="GPU to use")
    parser.add_argument("--skip-setup", action="store_true", help="Skip model setup")
    
    args = parser.parse_args()
    
    # Get paths
    project_root = Path(__file__).parent.parent
    vmevalkit_dir = project_root / "VMEvalKit"
    generate_script = vmevalkit_dir / "examples/generate_videos.py"
    questions_dir = project_root / "data/questions"
    output_dir = project_root / "data/outputs"
    
    # Setup model if needed
    if not args.skip_setup:
        if not setup_model(args.model, vmevalkit_dir):
            sys.exit(1)
    
    # Build command
    cmd = [
        sys.executable, str(generate_script),
        "--model", args.model,
        "--questions-dir", str(questions_dir),
        "--output-dir", str(output_dir)
    ]
    
    if args.gpu is not None:
        cmd.extend(["--gpu", str(args.gpu)])
    
    print(f"🚀 Running: {' '.join(cmd)}")
    print("=" * 80)
    
    # Run VMEvalKit with real-time output streaming
    process = subprocess.Popen(
        cmd, 
        cwd=vmevalkit_dir, 
        stdout=subprocess.PIPE, 
        stderr=subprocess.STDOUT,  # Merge stderr into stdout
        text=True, 
        bufsize=1,  # Line buffered
        universal_newlines=True
    )
    
    # Stream output in real-time
    for line in process.stdout:
        print(line, end='')  # Print without extra newline since line already has one
        sys.stdout.flush()
    
    # Wait for process to complete
    return_code = process.wait()
    
    print("=" * 80)
    if return_code != 0:
        print(f"❌ Process failed with exit code: {return_code}")
    else:
        print("✅ Process completed successfully")
    
    sys.exit(return_code)

if __name__ == "__main__":
    main()
