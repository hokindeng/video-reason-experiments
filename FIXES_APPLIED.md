# HunyuanVideo Output Structure Fixes

## Issues Found

### 1. Timestamp Folder Proliferation
**Problem**: HunyuanVideo wrapper was creating timestamped folders (`hunyuan_{timestamp}/`) inside the `video/` directory for every inference run, leading to:
- 415+ timestamp folders across all tasks
- Multiple duplicate videos for the same sample
- Broken output directory structure
- No cleanup of old attempts

**Root Cause**: In `VMEvalKit/vmevalkit/models/hunyuan_inference.py` (lines 82-84), the code was creating a new timestamp-based subdirectory:
```python
timestamp = int(time.time())
output_dir = self.output_dir / f"hunyuan_{timestamp}"  # ❌ Creates extra folder
```

### 2. Inconsistent Structure
**Expected Structure** (per README):
```
{model}/{task}/{question_id}/
├── question/
├── video/
│   └── video.mp4
└── metadata.json
```

**Actual Structure Before Fix**:
```
{model}/{task}/{question_id}/
└── hunyuan_{timestamp1}/
    └── video1.mp4
└── hunyuan_{timestamp2}/
    └── video2.mp4
└── hunyuan_{timestamp3}/
    └── video3.mp4
... (50+ folders per sample!)
```

## Fixes Applied

### 1. Code Fix: Remove Timestamp Folder Creation
**File**: `VMEvalKit/vmevalkit/models/hunyuan_inference.py`

**Changed**:
```python
# OLD (lines 82-84):
timestamp = int(time.time())
output_dir = self.output_dir / f"hunyuan_{timestamp}"
output_dir.mkdir(exist_ok=True, parents=True)

# NEW:
timestamp = int(start_time)  # Still used for generation_id
output_dir = self.output_dir  # Use directory directly
output_dir.mkdir(exist_ok=True, parents=True)
```

**Impact**: Future inference runs will no longer create timestamp folders.

### 2. Cleanup Scripts Created

#### `scripts/cleanup_hunyuan_folders.py`
Removes all `hunyuan_{timestamp}` folders and consolidates videos:
- Scans for all timestamp folders
- Moves newest video to parent directory as `video.mp4`
- Removes timestamp folders
- **Result**: Cleaned up 415 timestamp folders

#### `scripts/fix_video_structure.py`
Moves videos to correct location in run_id structure:
- Finds misplaced `video.mp4` files
- Moves them into proper `{run_id}/video/` directory
- **Result**: Fixed 8 video file locations

## Results

### Before
```bash
$ find data/outputs/hunyuan-video-i2v -name "hunyuan_*" -type d | wc -l
415  # 415 timestamp folders!
```

### After
```bash
$ find data/outputs/hunyuan-video-i2v -name "hunyuan_*" -type d | wc -l
0  # All cleaned up!
```

### Final Structure
```
data/outputs/hunyuan-video-i2v/
└── identify_objects_task/
    └── identify_objects_0000/
        └── hunyuan-video-i2v_identify_objects_0000_20260105_092934/
            ├── metadata.json
            ├── question/
            │   ├── first_frame.png
            │   └── prompt.txt
            └── video/
                └── video.mp4  ✅ Correct location!
```

## Summary

- **Issue**: HunyuanVideo creating 415+ unnecessary timestamp folders
- **Root Cause**: Wrapper code adding extra directory nesting
- **Fix**: 
  1. ✅ Updated code to use output directory directly
  2. ✅ Cleaned up all 415 timestamp folders
  3. ✅ Moved 8 videos to correct locations
- **Status**: All future inference runs will have clean output structure

## Files Modified

1. `VMEvalKit/vmevalkit/models/hunyuan_inference.py` - Remove timestamp folder creation
2. `scripts/cleanup_hunyuan_folders.py` - Cleanup script (new)
3. `scripts/fix_video_structure.py` - Structure fix script (new)

## Verification Commands

```bash
# Check no timestamp folders remain
find data/outputs/hunyuan-video-i2v -name "hunyuan_*" -type d

# Verify videos are in correct location
ls data/outputs/hunyuan-video-i2v/identify_objects_task/identify_objects_0000/*/video/video.mp4

# Check structure of a sample
ls -R data/outputs/hunyuan-video-i2v/identify_objects_task/identify_objects_0000/
```

