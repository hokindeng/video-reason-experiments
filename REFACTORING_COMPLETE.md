# Output Structure Refactoring - Complete ✅

## Summary

Successfully refactored the output directory structure from nested run folders to a flat, simple structure.

---

## New Structure

```
data/outputs/
└── {model}/                      # e.g., hunyuan-video-i2v
    └── {task}/                   # e.g., object_trajectory_task
        └── {question_id}/        # e.g., object_trajectory_0000
            ├── question/         # Question inputs (self-contained)
            │   ├── first_frame.png
            │   ├── final_frame.png (if exists)
            │   ├── prompt.txt
            │   └── ground_truth.mp4 (NEW!)
            └── video/            # Generated output
                └── video.mp4     # Simple, standard filename
```

**Path to generated video:** `outputs/{model}/{task}/{question_id}/video/video.mp4`

---

## Files Modified (8 files)

### 1. ✅ `vmevalkit/eval/run_selector.py`
**Changes:**
- Updated `select_latest_run()` to check if task_dir itself is a flat structure (has `video/` folder)
- Falls back to checking subdirectories for backward compatibility
- **Backward compatible:** ✅

### 2. ✅ `vmevalkit/eval/human_eval.py`
**Changes:**
- Updated `_get_task_data()` to handle flat structure
- Checks if task_dir itself contains `video/` and `question/` folders
- Falls back to checking subdirectories for old structure
- **Backward compatible:** ✅

### 3. ✅ `vmevalkit/runner/inference.py`
**Changes:**
- Removed run timestamp folder creation (no more `run_20260105_014231/`)
- Changed from: `inference_dir = task_base_dir / run_id`
- Changed to: `inference_dir = task_base_dir`
- Removed run_id generation and metadata tracking
- Removed `_save_metadata()` call (no more `metadata.json`)
- Removed `question_metadata.json` creation
- **Added:** Ground truth video copying to question folder
- Updated console output messages
- **Backward compatible:** ❌ (new runs use new structure)

### 4. ✅ `vmevalkit/models/hunyuan_inference.py`
**Changes:**
- Updated video output handling to flatten nested structure
- Searches recursively for generated `.mp4` files
- Moves/renames to `video/video.mp4`
- Cleans up nested directories created by the model
- **Result:** Always outputs to `video/video.mp4`

### 5. ✅ `vmevalkit/models/luma_inference.py`
**Changes:**
- Changed default output filename from `luma_{generation_id}.mp4` to `video.mp4`
- Simple change since Luma downloads directly to final location
- **Result:** Always outputs to `video/video.mp4`

### 6. ✅ `vmevalkit/models/videocrafter_inference.py`
**Changes:**
- Changed default output filename from `videocrafter_{timestamp}.mp4` to `video.mp4`
- Removed timestamp from filename generation
- **Result:** Always outputs to `video/video.mp4`

### 7. ✅ `vmevalkit/utils/s3_uploader.py`
**Changes:**
- Updated summary print logic to not expect `metadata.json`
- Now shows video and question file counts without requiring metadata
- **Backward compatible:** ✅

### 8. ✅ `examples/generate_videos.py`
**Changes:**
- Updated skip-existing logic to check for `task_folder/video/video.mp4` directly
- Falls back to checking subdirectories for old structure
- **Backward compatible:** ✅

---

## Key Improvements

### Before (Old Structure)
```
outputs/hunyuan-video-i2v/object_trajectory_task/object_trajectory_0000/
└── hunyuan-video-i2v_object_trajectory_0000_20260105_014231/
    ├── metadata.json
    ├── question/
    │   └── question_metadata.json
    └── video/
        └── hunyuan_1767577351/
            └── 2026-01-05-02:12:59_seed0_The_scene_contains....mp4
```

**Issues:**
- 5 levels of nesting
- Long, truncated filenames
- Redundant metadata files
- Complex paths

### After (New Structure)
```
outputs/hunyuan-video-i2v/object_trajectory_task/object_trajectory_0000/
├── question/
│   ├── first_frame.png
│   ├── final_frame.png
│   ├── prompt.txt
│   └── ground_truth.mp4        # For evaluation comparison
└── video/
    └── video.mp4               # Clean, simple name
```

**Benefits:**
- ✅ 50% fewer directory levels
- ✅ Simple, predictable paths
- ✅ No redundant metadata
- ✅ Self-contained (includes ground truth for eval)
- ✅ Easy to script and process
- ✅ Clean filenames

---

## Backward Compatibility

**Evaluation scripts:** ✅ Fully backward compatible
- `select_latest_run()` handles both structures
- `human_eval.py` handles both structures
- All evaluation scripts work with old outputs

**New inference runs:** ❌ Will use new structure only
- Re-running a question overwrites previous output
- No version history (one output per question)

**Migration:** Optional
- Old outputs remain functional
- New outputs use new structure
- No migration required

---

## Testing Recommendations

1. **Generate a test video:**
   ```bash
   python examples/generate_videos.py --model hunyuan-video-i2v --max-tasks 1
   ```
   
2. **Verify structure:**
   ```bash
   ls -R outputs/hunyuan-video-i2v/
   # Should see: task/question_id/video/video.mp4
   ```

3. **Test evaluation:**
   ```bash
   python examples/score_videos.py --eval-method gpt4o
   ```
   
4. **Test skip-existing:**
   ```bash
   python examples/generate_videos.py --model hunyuan-video-i2v --skip-existing
   # Should skip already generated videos
   ```

---

## Notes

- **Ground truth copying:** Now included in question folder for self-contained evaluation
- **No metadata.json:** All necessary info is in the structure itself
- **Overwrite behavior:** Re-running same question overwrites (simpler workflow)
- **Video discovery:** All evaluators use `*.mp4` glob which still works
- **Question data:** Evaluators read directly from question folder

---

## Date Completed
January 5, 2026

