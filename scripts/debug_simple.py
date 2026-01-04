#!/usr/bin/env python3
"""
Simple debug script to test HunyuanVideo directly
"""
import subprocess
import sys
from pathlib import Path

def main():
    # Test direct HunyuanVideo call
    vmevalkit_dir = Path(__file__).parent.parent / "VMEvalKit"
    
    cmd = [
        "/home/hokindeng/video-reason-experiments/VMEvalKit/envs/hunyuan-video-i2v/bin/python",
        "-c", 
        "import sys; print('Python path:'); [print(p) for p in sys.path]; print('Trying loguru import...'); import loguru; print('SUCCESS: loguru imported')"
    ]
    
    print("Testing loguru import in HunyuanVideo environment...")
    print(f"Command: {' '.join(cmd)}")
    
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
        print(f"Return code: {result.returncode}")
        print(f"STDOUT:\n{result.stdout}")
        if result.stderr:
            print(f"STDERR:\n{result.stderr}")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    main()
