# Output Structure Refactoring - Dependency Analysis

## Target Structure

```
data/outputs/
└── {model}/                      # e.g., hunyuan-video-i2v
    └── {task}/                   # e.g., object_trajectory_task
        └── {question_id}/        # e.g., object_trajectory_0000
            ├── question/         # Question inputs
            │   ├── first_frame.png
            │   ├── final_frame.png (if exists)
            │   ├── prompt.txt
            │   └── ground_truth.mp4 (NEW - copied from questions/)
            └── video/            # Generated output
                └── video.mp4     # Simple filename
```

**Key Changes:**
1. ❌ Remove run timestamp folder (e.g., `run_20260105_014231/`)
2. ❌ Remove `metadata.json` at root
3. ❌ Remove `question_metadata.json` inside question folder
4. ✅ Add `ground_truth.mp4` to question folder
5. ✅ Flatten video to simple `video/video.mp4` path

---

## Dependency Analysis

### ✅ **COMPATIBLE - No Changes Needed**

#### 1. **Evaluation Scripts Discovery Pattern**
**Files:**
- `vmevalkit/eval/gpt4o_eval.py` (line 205-210)
- `vmevalkit/eval/internvl.py` (line 329-334)
- `vmevalkit/eval/multiframe_eval.py` (line 427-431)

**Current behavior:**
```python
run_dir = select_latest_run(task_dir)  # Gets most recent run by mtime
video_files = sorted((run_dir / "video").glob("*.mp4"))
```

**Why it works:**
- `select_latest_run()` picks the most recent subdirectory by mtime
- After our changes, `task_dir` itself becomes the "run dir" (no timestamp subfolder)
- **BUT**: `select_latest_run()` will return `None` if `task_dir` has no subdirectories
- **NEEDS FIX**: We need to update `select_latest_run()` to handle flat structure

---

#### 2. **Question Folder Access**
**Files:**
- `vmevalkit/eval/gpt4o_eval.py` (line 127-129)
- `vmevalkit/eval/internvl.py` (line 159-161, 226-228)
- `vmevalkit/eval/multiframe_eval.py` (line 267-269)
- `vmevalkit/eval/human_eval.py` (line 71-73)

**Current behavior:**
```python
task_dir = Path(video_path).parent.parent  # Goes up from video/file.mp4 to run_dir
first_frame_path = task_dir / "question" / "first_frame.png"
final_frame_path = task_dir / "question" / "final_frame.png"
prompt_path = task_dir / "question" / "prompt.txt"
```

**Why it works:**
- **Before**: `video_path` = `.../run_20260105/video/video.mp4` → `parent.parent` = `.../run_20260105/`
- **After**: `video_path` = `.../object_trajectory_0000/video/video.mp4` → `parent.parent` = `.../object_trajectory_0000/`
- Same relative path logic, just one fewer level of nesting
- ✅ **NO CHANGES NEEDED**

---

#### 3. **Video Globbing Pattern**
**All evaluators look for:**
```python
video_files = sorted((run_dir / "video").glob("*.mp4"))
```

**Why it works:**
- We're renaming to `video.mp4`, which matches `*.mp4` pattern
- ✅ **NO CHANGES NEEDED**

---

### ⚠️ **NEEDS UPDATING**

#### 4. **`question_metadata.json` Usage**
**Files:**
- `vmevalkit/eval/internvl.py` (line 162, 169-171, 228, 240-242)

**Current behavior:**
```python
question_metadata_path = task_dir / "question" / "question_metadata.json"
if question_metadata_path.exists():
    question_metadata = json.load(question_metadata_path.open())
    goal = question_metadata.get("goal")
```

**Issue:**
- We're removing `question_metadata.json`
- This file is used as fallback for "goal-based evaluation" when no final_frame exists

**Solution:**
- The evaluator already has fallback logic:
  1. Check `question_metadata.json` → goal field
  2. Check `goal.txt`
  3. Use `prompt.txt` as goal
- Since we're keeping `prompt.txt`, it will fall back to that
- ✅ **NO CODE CHANGES NEEDED** (graceful degradation)

---

#### 5. **S3 Uploader**
**File:** `vmevalkit/utils/s3_uploader.py` (line 109-183)

**Current behavior:**
```python
def upload_inference_folder(self, inference_dir: str, prefix: Optional[str] = None):
    # Uploads everything recursively
    for file_path in inference_path.rglob('*'):
        ...
    
    # Special handling for metadata.json
    if 'metadata.json' in uploaded_files:
        print(f"   Metadata: {uploaded_files['metadata.json']}")
```

**Impact:**
- The recursive upload still works fine
- Just won't find `metadata.json` anymore
- The print statement has a conditional check, so it won't error

**Solution:**
- Update the summary print logic to not expect `metadata.json`
- ✅ **MINOR UPDATE NEEDED** (optional, won't break)

---

#### 6. **Human Evaluator Discovery**
**File:** `vmevalkit/eval/human_eval.py` (line 64-83)

**Current behavior:**
```python
def _get_task_data(self, model_name: str, task_type: str, task_id: str):
    task_dir = self.inference_dir / model_name / task_type / task_id
    output_dirs = list(task_dir.iterdir())  # Gets run folders
    if not output_dirs: return None
    
    output_dir = output_dirs[0]  # Takes first run folder
    video_files = list((output_dir / "video").glob("*.mp4"))
```

**Issue:**
- Expects `task_dir` to have subdirectories (run folders)
- After changes, `task_dir` IS the output folder (no subdirs)

**Solution:**
- Check if `task_dir` itself has a `video/` folder
- If yes, use `task_dir` directly
- If no, fall back to checking subdirectories (for backward compatibility)
- ✅ **NEEDS UPDATE**

---

#### 7. **`select_latest_run()` Function**
**File:** `vmevalkit/eval/run_selector.py` (line 5-20)

**Current behavior:**
```python
def select_latest_run(task_dir: Path) -> Optional[Path]:
    run_dirs = [p for p in task_dir.iterdir() if p.is_dir()]
    if not run_dirs:
        return None
    run_dirs.sort(key=lambda p: p.stat().st_mtime, reverse=True)
    return run_dirs[0]
```

**Issue:**
- Returns `None` when `task_dir` has no subdirectories
- After changes, there are no run subdirectories

**Solution:**
- Check if `task_dir` itself contains a `video/` folder
- If yes, return `task_dir` itself
- If no, check for subdirectories (backward compatibility)
- ✅ **NEEDS UPDATE** (critical!)

---

#### 8. **Video Generation Examples**
**File:** `examples/generate_videos.py` (line 350-374)

**Current behavior:**
```python
run_id_pattern = f"{model_name}_{task_id}_*"
domain_dir_name = f"{domain}_task"
task_folder = model_output_dir / domain_dir_name / task_id
existing_dirs = list(task_folder.glob(run_id_pattern))

# Check if run folder has video
for run_dir in existing_dirs:
    video_dir = run_dir / "video"
    if video_dir.exists():
        video_files = list(video_dir.glob("*.mp4"))
```

**Issue:**
- Looks for run folders matching pattern `{model}_{task}_*`
- After changes, no run folders exist

**Solution:**
- Check if `task_folder / "video" / "video.mp4"` exists directly
- If yes, skip
- ✅ **NEEDS UPDATE**

---

## Files to Modify

### 🔴 **Critical (Must Update)**

1. **`VMEvalKit/vmevalkit/eval/run_selector.py`**
   - Update `select_latest_run()` to handle flat structure

2. **`VMEvalKit/vmevalkit/eval/human_eval.py`**
   - Update `_get_task_data()` to handle flat structure

3. **`VMEvalKit/vmevalkit/runner/inference.py`**
   - Remove run timestamp folder creation
   - Remove `_save_metadata()` call
   - Add ground_truth.mp4 copying to `_setup_question_folder()`
   - Update console output

4. **`VMEvalKit/vmevalkit/models/hunyuan_inference.py`**
   - Flatten video output to `video/video.mp4`

5. **`VMEvalKit/vmevalkit/models/luma_inference.py`**
   - Flatten video output to `video/video.mp4`

6. **`VMEvalKit/vmevalkit/models/videocrafter_inference.py`**
   - Flatten video output to `video/video.mp4`

### 🟡 **Optional (Nice to Have)**

7. **`VMEvalKit/vmevalkit/utils/s3_uploader.py`**
   - Update print logic to not mention metadata.json

8. **`VMEvalKit/examples/generate_videos.py`**
   - Update skip-existing check to work with flat structure

---

## Testing Checklist

After implementing changes, test:

- [ ] Video generation creates correct structure
- [ ] GPT-4O evaluation finds videos
- [ ] InternVL evaluation finds videos
- [ ] Multi-frame evaluation finds videos
- [ ] Human evaluation finds videos
- [ ] Skip-existing logic works in generate_videos.py
- [ ] S3 upload still works
- [ ] Ground truth video is copied correctly

---

## Migration Strategy

For existing outputs with old structure:

```bash
# Script to flatten existing outputs (optional)
for run_dir in outputs/*/*/*/*/; do
    if [[ -d "$run_dir/video" ]]; then
        # Find and move video to simple name
        find "$run_dir/video" -name "*.mp4" -exec mv {} "$run_dir/video/video.mp4" \;
        
        # Clean up nested directories
        find "$run_dir/video" -mindepth 1 -type d -exec rm -rf {} + 2>/dev/null
    fi
done
```

Or: Keep old outputs as-is, new runs use new structure (backward compatible if we update `select_latest_run` properly)

