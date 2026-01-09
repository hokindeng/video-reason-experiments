#!/usr/bin/env python3
"""
Cleanup HunyuanVideo Output Folders

Fixes the issue where HunyuanVideo creates timestamp folders (hunyuan_{timestamp}/)
inside the video/ directory. This script:
1. Finds all hunyuan_{timestamp} folders
2. Moves the video file from hunyuan_{timestamp}/ up to video/
3. Removes the empty timestamp folder
4. Renames video to standard 'video.mp4' format
"""

import sys
from pathlib import Path
import shutil
from typing import List, Tuple

def find_timestamp_folders(base_dir: Path) -> List[Path]:
    """Find all hunyuan_{timestamp} folders in the output directory."""
    timestamp_folders = []
    
    # Find all folders matching pattern hunyuan_*
    for folder in base_dir.rglob("hunyuan_*"):
        if folder.is_dir() and folder.name.startswith("hunyuan_"):
            timestamp_folders.append(folder)
    
    return timestamp_folders

def cleanup_folder(timestamp_folder: Path) -> Tuple[bool, str]:
    """
    Move video from timestamp folder to parent and clean up.
    
    Returns:
        (success, message)
    """
    parent = timestamp_folder.parent
    
    # Find MP4 files in timestamp folder
    video_files = list(timestamp_folder.glob("*.mp4"))
    
    if not video_files:
        return False, f"No video files found in {timestamp_folder}"
    
    # Take the first (should only be one)
    video_file = video_files[0]
    
    # Target location: parent/video.mp4
    target_path = parent / "video.mp4"
    
    # If target already exists, check if we should replace it
    if target_path.exists():
        # Keep the newer file (by modification time)
        if video_file.stat().st_mtime > target_path.stat().st_mtime:
            target_path.unlink()
            shutil.move(str(video_file), str(target_path))
            msg = f"Replaced older video at {target_path}"
        else:
            msg = f"Kept existing newer video at {target_path}"
    else:
        shutil.move(str(video_file), str(target_path))
        msg = f"Moved video to {target_path}"
    
    # Remove timestamp folder completely (we've already saved the best video)
    if timestamp_folder.exists():
        shutil.rmtree(timestamp_folder)
        msg += f" | Removed {timestamp_folder.name}"
    
    return True, msg

def main():
    """Main cleanup process."""
    import argparse
    
    parser = argparse.ArgumentParser(description="Cleanup HunyuanVideo timestamp folders")
    parser.add_argument(
        "--base-dir",
        type=str,
        default="data/outputs/hunyuan-video-i2v",
        help="Base directory to scan for timestamp folders"
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
    
    print(f"🔍 Scanning for timestamp folders in: {base_dir}")
    timestamp_folders = find_timestamp_folders(base_dir)
    
    print(f"📊 Found {len(timestamp_folders)} timestamp folders\n")
    
    if not timestamp_folders:
        print("✅ No cleanup needed!")
        return 0
    
    if args.dry_run:
        print("🔍 DRY RUN - No changes will be made\n")
    
    success_count = 0
    error_count = 0
    
    for i, folder in enumerate(timestamp_folders, 1):
        relative_path = folder.relative_to(base_dir)
        print(f"[{i}/{len(timestamp_folders)}] {relative_path}")
        
        if args.dry_run:
            # Just check what's in there
            video_files = list(folder.glob("*.mp4"))
            if video_files:
                print(f"   Would move: {video_files[0].name}")
            else:
                print(f"   ⚠️  No video files found")
        else:
            success, message = cleanup_folder(folder)
            if success:
                print(f"   ✅ {message}")
                success_count += 1
            else:
                print(f"   ❌ {message}")
                error_count += 1
    
    print(f"\n{'='*60}")
    if args.dry_run:
        print(f"DRY RUN: Would process {len(timestamp_folders)} folders")
    else:
        print(f"✅ Success: {success_count}")
        print(f"❌ Errors: {error_count}")
        print(f"📊 Total processed: {success_count + error_count}")
    
    return 0 if error_count == 0 else 1

if __name__ == "__main__":
    sys.exit(main())

