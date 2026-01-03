#!/usr/bin/env python3
"""
Simple wrapper for running VMEvalKit evaluation experiments.
Calls VMEvalKit's score_videos.py with evaluation configs.
"""

import subprocess
import sys
from pathlib import Path
import argparse

# Get the VMEvalKit path
VMEVALKIT_DIR = Path(__file__).parent.parent / "VMEvalKit"
SCORE_SCRIPT = VMEVALKIT_DIR / "examples/score_videos.py"

def main():
    parser = argparse.ArgumentParser(description="Run VMEvalKit evaluation")
    parser.add_argument("--eval-method", required=True, 
                      choices=["multi_frame_uniform", "keyframe_detection", "hybrid_sampling"],
                      help="Evaluation method to use")
    
    args = parser.parse_args()
    
    # Get config path
    config_path = Path(__file__).parent.parent / f"configs/eval/{args.eval_method}.json"
    
    if not config_path.exists():
        print(f"❌ Config not found: {config_path}")
        sys.exit(1)
    
    # Build command for VMEvalKit
    cmd = [
        sys.executable, str(SCORE_SCRIPT),
        "--eval-config", str(config_path)
    ]
    
    print(f"🚀 Running evaluation: {args.eval_method}")
    print(f"📄 Config: {config_path}")
    print(f"🔧 Command: {' '.join(cmd)}")
    
    # Execute VMEvalKit
    result = subprocess.run(cmd, cwd=VMEVALKIT_DIR)
    sys.exit(result.returncode)

if __name__ == "__main__":
    main()
