#!/usr/bin/env python3
"""
S3 Sync Utility for Video Reasoning Experiments

PURPOSE:
    Simple wrapper around AWS CLI for uploading/downloading data to/from S3.
    Automatically loads credentials from .env file if present.

USAGE:
    # Upload generated videos
    python data/s3_sync.py upload data/outputs s3://bucket/prefix/

    # Download questions dataset
    python data/s3_sync.py download s3://bucket/questions/ data/questions

REQUIREMENTS:
    - aws-cli installed (module load aws-cli/2.27.49 on HPC)
    - Valid AWS credentials in .env or environment
    - python-dotenv package (optional, for .env loading)

AUTHENTICATION:
    Priority order:
    1. .env file (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_DEFAULT_REGION)
    2. Environment variables
    3. AWS credentials file (~/.aws/credentials)
    4. IAM role (if running on EC2)

EXAMPLES:
    # Upload all outputs
    module load aws-cli/2.27.49
    set -a && source .env && set +a
    python data/s3_sync.py upload data/outputs s3://vm-dataset-yijiangli/hunyuan/

    # Download specific task
    python data/s3_sync.py download s3://hokindeng/questions/G-1_object_trajectory_data-generator/ data/questions/

    # Sync bidirectionally (download then upload)
    python data/s3_sync.py download s3://bucket/questions/ data/questions
    # ... generate videos ...
    python data/s3_sync.py upload data/outputs s3://bucket/outputs/
"""

import os
import subprocess
import sys
from pathlib import Path
import argparse

# Load environment variables from .env file in project root
try:
    from dotenv import load_dotenv
    # Look for .env in project root (parent of data/)
    env_path = Path(__file__).parent.parent / '.env'
    load_dotenv(dotenv_path=env_path)
except ImportError:
    pass  # python-dotenv not installed, will use system environment variables


def upload(local_path: str, s3_uri: str):
    """
    Upload a file or directory to S3.
    
    Args:
        local_path: Path to local file or directory
        s3_uri: S3 destination URI (s3://bucket/prefix/)
    
    Behavior:
        - Single file: Uses 'aws s3 cp'
        - Directory: Uses 'aws s3 sync' (only uploads new/changed files)
    
    Raises:
        FileNotFoundError: If local_path doesn't exist
        subprocess.CalledProcessError: If AWS CLI command fails
    """
    local_path = Path(local_path)
    if not local_path.exists():
        raise FileNotFoundError(f"Path does not exist: {local_path}")
    
    print(f"📤 Uploading {local_path} to {s3_uri}")
    
    if local_path.is_file():
        cmd = ["aws", "s3", "cp", str(local_path), s3_uri]
    else:
        cmd = ["aws", "s3", "sync", str(local_path), s3_uri]
    
    subprocess.run(cmd, check=True)
    print(f"✅ Upload completed")


def download(s3_uri: str, local_path: str = None):
    """
    Download data from S3.
    
    Args:
        s3_uri: S3 source URI (s3://bucket/prefix/)
        local_path: Local destination path (default: current directory)
    
    Returns:
        str: Absolute path to downloaded content
    
    Behavior:
        - Uses 'aws s3 sync' (only downloads new/changed files)
        - Creates local directory if it doesn't exist
        - Preserves S3 directory structure
    
    Raises:
        subprocess.CalledProcessError: If AWS CLI command fails
    """
    if local_path is None:
        # Default to current directory
        local_path = "."
    
    local_path = Path(local_path)
    local_path.mkdir(parents=True, exist_ok=True)
    
    print(f"📥 Downloading from {s3_uri} to {local_path}")
    
    cmd = ["aws", "s3", "sync", s3_uri, str(local_path)]
    subprocess.run(cmd, check=True)
    print(f"✅ Download completed")
    
    return str(local_path)


def main():
    parser = argparse.ArgumentParser(description="Simple S3 upload/download tool")
    subparsers = parser.add_subparsers(dest='command', help='Command to execute')
    
    # Upload command
    upload_parser = subparsers.add_parser('upload', help='Upload files/directory to S3')
    upload_parser.add_argument('path', help='Local file or directory to upload')
    upload_parser.add_argument('s3_uri', help='S3 URI (s3://bucket/prefix)')
    
    # Download command
    download_parser = subparsers.add_parser('download', help='Download data from S3')
    download_parser.add_argument('s3_uri', help='S3 URI (s3://bucket/prefix)')
    download_parser.add_argument('local_path', nargs='?', help='Local destination path (default: current directory)')
    
    args = parser.parse_args()
    
    if args.command == 'upload':
        upload(args.path, args.s3_uri)
    elif args.command == 'download':
        download(args.s3_uri, args.local_path)
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
