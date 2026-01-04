#!/usr/bin/env python3
"""Simple S3 sync tool for upload and download."""

import os
import subprocess
import sys
from pathlib import Path
import argparse

# Load environment variables from .env file
try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    pass  # dotenv not installed, use system env vars


def upload(local_path: str, s3_uri: str):
    """Upload a file or directory to S3."""
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
    """Download data from S3."""
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
