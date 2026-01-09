#!/usr/bin/env python3
"""
Restructure questions folders from:
    data/questions/G-12_grid_obtaining_award_data-generator/00000/
    
To:
    data/questions/G-12_grid_obtaining_award_data-generator/grid_obtaining_award/grid_obtaining_award_0000/
"""

import re
import shutil
from pathlib import Path


def extract_task_info(folder_name: str) -> tuple[str, str, str]:
    """Extract G-number, task name, and prefix from folder name."""
    # Match pattern: G-<number>_<task_name>
    match = re.match(r"(G-\d+)_(.+)", folder_name)
    if not match:
        raise ValueError(f"Folder name doesn't match expected pattern: {folder_name}")
    
    g_number = match.group(1)
    full_task_name = match.group(2)
    
    # Remove common suffixes to get the prefix for sample folders
    prefix = full_task_name
    for suffix in ["_data-generator", "-data-generator", "_data_generator", "_generator"]:
        if prefix.endswith(suffix):
            prefix = prefix[:-len(suffix)]
            break
    
    return g_number, full_task_name, prefix


def restructure_questions_dir(questions_dir: Path, dry_run: bool = False) -> None:
    """Restructure all G-* folders in questions directory."""
    
    g_folders = sorted([f for f in questions_dir.iterdir() if f.is_dir() and f.name.startswith("G-")])
    
    print(f"Found {len(g_folders)} task folders to restructure")
    print()
    
    for g_folder in g_folders:
        print(f"Processing: {g_folder.name}")
        
        g_number, full_task_name, prefix = extract_task_info(g_folder.name)
        print(f"  G-number: {g_number}, Task: {full_task_name}, Prefix: {prefix}")
        
        # Create nested task folder
        nested_folder = g_folder / prefix
        
        # Find all numbered sample folders (exclude the nested folder if it exists)
        sample_folders = sorted([
            f for f in g_folder.iterdir() 
            if f.is_dir() and re.match(r"^\d+$", f.name)
        ])
        
        if not sample_folders:
            # Check if already restructured
            if nested_folder.exists():
                print(f"  Already restructured, skipping")
                continue
            print(f"  No numbered folders found, skipping")
            continue
        
        print(f"  Found {len(sample_folders)} sample folders")
        
        if dry_run:
            print(f"  [DRY RUN] Would create: {nested_folder}")
            for sample in sample_folders[:3]:
                new_name = f"{prefix}_{int(sample.name):04d}"
                print(f"  [DRY RUN] Would rename: {sample.name} -> {prefix}/{new_name}")
            if len(sample_folders) > 3:
                print(f"  [DRY RUN] ... and {len(sample_folders) - 3} more")
            continue
        
        # Create nested folder
        nested_folder.mkdir(exist_ok=True)
        
        # Move and rename each sample folder
        for sample in sample_folders:
            sample_num = int(sample.name)
            # Use dynamic width: 4 digits for <10000, 5 digits for >=10000
            new_name = f"{prefix}_{sample_num:04d}" if sample_num < 10000 else f"{prefix}_{sample_num:05d}"
            new_path = nested_folder / new_name
            
            shutil.move(str(sample), str(new_path))
        
        print(f"  ✅ Restructured {len(sample_folders)} samples into {prefix}/")
    
    print()
    print("Done!")


def main() -> None:
    import argparse
    
    parser = argparse.ArgumentParser(description="Restructure questions folders")
    parser.add_argument(
        "--questions-dir",
        type=Path,
        default=Path(__file__).parent.parent / "data" / "questions",
        help="Path to questions directory"
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show what would be done without making changes"
    )
    
    args = parser.parse_args()
    
    if not args.questions_dir.exists():
        print(f"Error: Questions directory not found: {args.questions_dir}")
        return
    
    restructure_questions_dir(args.questions_dir, dry_run=args.dry_run)


if __name__ == "__main__":
    main()

