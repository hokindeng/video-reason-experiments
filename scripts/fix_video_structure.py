#!/usr/bin/env python3
"""
Fix Video Structure

Moves video.mp4 files from the question_id level into the proper run_id/video/ folder.

Current structure (broken):
    {task}/{question_id}/
    ├── video.mp4  (wrong place!)
    └── {run_id}/
        ├── metadata.json
        ├── question/
        └── video/ (empty!)

Target structure:
    {task}/{question_id}/
    └── {run_id}/
        ├── metadata.json
        ├── question/
        └── video/
            └── video.mp4  (correct place!)
"""

import sys
import shutil
from pathlib import Path
from typing import List, Tuple

def find_misplaced_videos(base_dir: Path) -> List[Tuple[Path, Path]]:
    """
    Find video.mp4 files at question_id level and their target run_id/video/ folder.
    
    Returns:
        List of (source_video_path, target_video_dir) tuples
    """
    moves = []
    
    # Find all video.mp4 files
    for video_file in base_dir.rglob("video.mp4"):
        # Check if it's at the question_id level (should have run_id sibling folders)
        parent = video_file.parent
        
        # Look for run_id folders (they have timestamps in the name)
        run_id_folders = [f for f in parent.iterdir() if f.is_dir() and "_" in f.name]
        
        if run_id_folders:
            # This video.mp4 is at the wrong level, needs to move into run_id/video/
            # Use the most recent run_id folder
            newest_run_id = max(run_id_folders, key=lambda p: p.stat().st_mtime)
            target_video_dir = newest_run_id / "video"
            
            if target_video_dir.exists():
                moves.append((video_file, target_video_dir))
    
    return moves

def main():
    """Main fix process."""
    import argparse
    
    parser = argparse.ArgumentParser(description="Fix video.mp4 file locations")
    parser.add_argument(
        "--base-dir",
        type=str,
        default="data/outputs/hunyuan-video-i2v",
        help="Base directory to scan"
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show what would be done without making changes"
    )
    
    args = parser.parse_args()
    
    base_dir = Path(args.base_dir)
    
    if not base_dir.exists():
        print(f"❌ Base directory does not exist: {base_dir}")
        return 1
    
    print(f"🔍 Scanning for misplaced video.mp4 files in: {base_dir}")
    moves = find_misplaced_videos(base_dir)
    
    print(f"📊 Found {len(moves)} misplaced videos\n")
    
    if not moves:
        print("✅ No fixes needed!")
        return 0
    
    if args.dry_run:
        print("🔍 DRY RUN - No changes will be made\n")
    
    success_count = 0
    error_count = 0
    
    for i, (source, target_dir) in enumerate(moves, 1):
        relative_source = source.relative_to(base_dir)
        relative_target = (target_dir / "video.mp4").relative_to(base_dir)
        
        print(f"[{i}/{len(moves)}] Moving video")
        print(f"   From: {relative_source}")
        print(f"   To:   {relative_target}")
        
        if args.dry_run:
            print(f"   Would move file")
        else:
            target_file = target_dir / "video.mp4"
            
            # Check if target already exists
            if target_file.exists():
                # Compare sizes to decide
                if source.stat().st_size > target_file.stat().st_size:
                    target_file.unlink()
                    shutil.move(str(source), str(target_file))
                    print(f"   ✅ Replaced smaller file")
                    success_count += 1
                else:
                    source.unlink()  # Remove the duplicate
                    print(f"   ✅ Removed duplicate (kept larger file)")
                    success_count += 1
            else:
                shutil.move(str(source), str(target_file))
                print(f"   ✅ Moved file")
                success_count += 1
    
    print(f"\n{'='*60}")
    if args.dry_run:
        print(f"DRY RUN: Would process {len(moves)} files")
    else:
        print(f"✅ Success: {success_count}")
        print(f"❌ Errors: {error_count}")
        print(f"📊 Total processed: {success_count + error_count}")
    
    return 0 if error_count == 0 else 1

if __name__ == "__main__":
    sys.exit(main())

