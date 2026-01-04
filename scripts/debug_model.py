#!/usr/bin/env python3
"""
Debug script to test HunyuanVideo model loading
"""
import subprocess
import sys
import os
from pathlib import Path

def main():
    # Try running just one task with timeout and detailed logging
    vmevalkit_dir = Path(__file__).parent.parent / "VMEvalKit"
    questions_dir = Path(__file__).parent.parent / "data/questions"
    output_dir = Path(__file__).parent.parent / "data/outputs"
    
    # Find the first task
    task_dirs = list((questions_dir / "object_trajectory_task").glob("object_trajectory_*"))
    if not task_dirs:
        print("No tasks found!")
        return
    
    first_task = task_dirs[0].name
    print(f"Testing with first task: {first_task}")
    
    cmd = [
        sys.executable,
        str(vmevalkit_dir / "examples/generate_videos.py"),
        "--model", "hunyuan-video-i2v",
        "--questions-dir", str(questions_dir),
        "--output-dir", str(output_dir),
        "--task-id", first_task  # Run just one task
    ]
    
    print(f"Command: {' '.join(cmd)}")
    print("Running with 60 second timeout...")
    print("=" * 80)
    
    try:
        # Use timeout and stream output
        process = subprocess.Popen(
            cmd,
            cwd=str(vmevalkit_dir),
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            bufsize=1,
            universal_newlines=True,
            env=dict(os.environ, PYTHONUNBUFFERED="1")  # Force unbuffered output
        )
        
        import signal
        def timeout_handler(signum, frame):
            print("\n🚨 TIMEOUT! Process is hanging...")
            process.terminate()
            
        signal.signal(signal.SIGALRM, timeout_handler)
        signal.alarm(60)  # 60 second timeout
        
        # Stream output
        for line in process.stdout:
            print(line, end='')
            sys.stdout.flush()
            
        return_code = process.wait()
        signal.alarm(0)  # Cancel timeout
        
        print(f"\nProcess completed with return code: {return_code}")
        
    except Exception as e:
        print(f"\nError: {e}")

if __name__ == "__main__":
    main()
