#!/usr/bin/env python3
"""
Simple wrapper for running VMEvalKit evaluation experiments.
Calls VMEvalKit's score_videos.py with evaluation configs.
"""

import argparse
import os
import subprocess
import sys
from pathlib import Path


def main():
    parser = argparse.ArgumentParser(
        description="Run VMEvalKit evaluation experiments",
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    parser.add_argument(
        "--eval-method",
        type=str,
        required=True,
        choices=["multi_frame_uniform", "keyframe_detection", "hybrid_sampling"],
        help="Evaluation method to use"
    )
    
    args = parser.parse_args()
    
    # Get script directory and relevant paths
    script_dir = Path(__file__).resolve().parent
    vmevalkit_dir = script_dir.parent / "VMEvalKit"
    score_script = vmevalkit_dir / "examples" / "score_videos.py"
    config_path = script_dir.parent / "configs" / "eval" / f"{args.eval_method}.json"
    
    # Validate config file exists
    if not config_path.exists():
        print(f"❌ Config not found: {config_path}")
        sys.exit(1)
    
    # Validate score script exists
    if not score_script.exists():
        print(f"❌ Score script not found: {score_script}")
        sys.exit(1)
    
    print(f"🚀 Running evaluation: {args.eval_method}")
    print(f"📄 Config: {config_path}")
    
    # Execute VMEvalKit
    try:
        subprocess.run(
            [sys.executable, str(score_script), "--eval-config", str(config_path)],
            cwd=str(vmevalkit_dir),
            check=True
        )
    except subprocess.CalledProcessError as e:
        print(f"❌ Evaluation failed with exit code {e.returncode}")
        sys.exit(e.returncode)
    except Exception as e:
        print(f"❌ Error running evaluation: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()

