# Model Inference Audit - Output Filename Issues
**Date:** January 5, 2026  
**Status:** ✅ ALL FIXED - All models now use standard filename

---

## Summary

After fixing HunyuanVideo, I audited all 13 model inference implementations. **10 models still use timestamped filenames** instead of the standard `video.mp4`. This defeats the purpose of the simplified output structure.

---

## Audit Results

| # | Model | Output Filename | Status | Issue |
|---|-------|-----------------|--------|-------|
| 1 | `hunyuan_inference.py` | `video.mp4` | ✅ Fixed | Already standardized |
| 2 | `luma_inference.py` | `video.mp4` | ✅ Good | Already standardized |
| 3 | `videocrafter_inference.py` | `video.mp4` | ✅ Good | Already standardized |
| 4 | `openai_inference.py` | `video.mp4` | ✅ Fixed | ~~sora_{model}_{timestamp}.mp4~~ |
| 5 | `veo_inference.py` | `video.mp4` | ✅ Fixed | ~~veo_{timestamp}.mp4~~ |
| 6 | `runway_inference.py` | `video.mp4` | ✅ Fixed | ~~runway_{model}_{timestamp}.mp4~~ |
| 7 | `ltx_inference.py` | `video.mp4` | ✅ Fixed | ~~ltx_{model}_{timestamp}.mp4~~ |
| 8 | `svd_inference.py` | `video.mp4` | ✅ Fixed | ~~svd_{model}_{timestamp}.mp4~~ |
| 9 | `wan_inference.py` | `video.mp4` | ✅ Fixed | ~~wan_{model}_{timestamp}.mp4~~ |
| 10 | `morphic_inference.py` | `video.mp4` | ✅ Fixed | ~~morphic_{timestamp}.mp4~~ |
| 11 | `sana_inference.py` | `video.mp4` | ✅ Fixed | ~~sana_{model}_{timestamp}.mp4~~ |
| 12 | `cogvideox_inference.py` | `video.mp4` | ✅ Fixed | ~~cogvideox_{model}_{timestamp}.mp4~~ |
| 13 | `dynamicrafter_inference.py` | `video.mp4` | ✅ Fixed | ~~{id}_{prompt}.mp4~~ |

**Score:** ✅ 13/13 models use standard filename (100%)  
**All models fixed!** 🎉

---

## Why This Is a Problem

### The Simplified Structure Depends on Standard Filenames

**Current structure (after refactoring):**
```
outputs/hunyuan-video-i2v/object_trajectory_task/object_trajectory_0000/
└── video/
    └── video.mp4  ← Simple, predictable path
```

**Problem with timestamps:**
```
outputs/sora-2/object_trajectory_task/object_trajectory_0000/
└── video/
    └── sora_2_1736047123.mp4  ← Unpredictable, changes every time
```

### Issues This Causes:

1. **Breaks skip-existing logic** - Can't easily check if video exists
2. **Inconsistent paths** - Different models use different patterns
3. **No predictability** - Can't know the filename ahead of time
4. **Harder to script** - Need to glob for `*.mp4` instead of direct path
5. **Defeats simplification** - We removed timestamp folders, but timestamps are still in filenames!

---

## Detailed Issues by Model

### ❌ openai_inference.py (Sora)
**Line 427:**
```python
output_filename = f"sora_{safe_model}_{timestamp}.mp4"
```
**Should be:**
```python
output_filename = "video.mp4"
```

### ❌ veo_inference.py (Google Veo)
**Line 437:**
```python
output_filename = f"veo_{int(time.time())}.mp4"
```
**Should be:**
```python
output_filename = "video.mp4"
```

### ❌ runway_inference.py (Runway Gen-3)
**Line 409:**
```python
output_filename = f"runway_{safe_model}_{timestamp}.mp4"
```
**Should be:**
```python
output_filename = "video.mp4"
```

### ❌ ltx_inference.py (LTX Video)
**Line 167:**
```python
output_filename = f"ltx_{safe_model}_{timestamp}.mp4"
```
**Should be:**
```python
output_filename = "video.mp4"
```

### ❌ svd_inference.py (Stable Video Diffusion)
**Line 160:**
```python
output_filename = f"svd_{safe_model}_{timestamp}.mp4"
```
**Should be:**
```python
output_filename = "video.mp4"
```

### ❌ wan_inference.py (WAN)
**Line 170:**
```python
output_filename = f"wan_{safe_model}_{timestamp}.mp4"
```
**Should be:**
```python
output_filename = "video.mp4"
```

### ❌ morphic_inference.py (Morphic)
**Line 150:**
```python
output_filename = f"morphic_{timestamp}.mp4"
```
**Should be:**
```python
output_filename = "video.mp4"
```

### ❌ sana_inference.py (Sana)
**Line 299:**
```python
output_filename = f"sana_{safe_model}_{timestamp}.mp4"
```
**Should be:**
```python
output_filename = "video.mp4"
```

### ❌ cogvideox_inference.py (CogVideoX)
**Line 339:**
```python
output_filename = f"cogvideox_{safe_model}_{timestamp}.mp4"
```
**Should be:**
```python
output_filename = "video.mp4"
```

### ❌ dynamicrafter_inference.py (DynamiCrafter)
**Line 381:**
```python
output_filename = f"{generation_id}_{prompt_slug}.mp4"
```
**Should be:**
```python
output_filename = "video.mp4"
```

---

## Additional Issues Found

### No Critical Import Issues
✅ No other models use `shutil`, `os.rename`, or `Path.rename` without imports
✅ All imports are correct (only HunyuanVideo had the missing shutil import)

---

## Recommended Fixes

### Option 1: Fix All Models (Recommended)
Change all 10 models to use standard `"video.mp4"` filename.

**Pros:**
- ✅ Consistent across all models
- ✅ Predictable paths
- ✅ Skip-existing works reliably
- ✅ Easy to script and process

**Cons:**
- ⚠️ Need to update 10 files
- ⚠️ Re-running same question overwrites (but this is intended behavior)

### Option 2: Leave As-Is
Keep timestamped filenames for these models.

**Pros:**
- ✅ No changes needed

**Cons:**
- ❌ Inconsistent with refactoring goals
- ❌ Breaks skip-existing logic
- ❌ Unpredictable paths
- ❌ Defeats simplification effort

---

## Recommendation

**Fix all 10 models** to use `"video.mp4"`. This ensures:
1. Consistent structure across all models
2. Predictable, simple paths
3. Skip-existing logic works correctly
4. Easy to find videos: `outputs/{model}/{task}/{id}/video/video.mp4`

The model name is already in the directory structure (`outputs/{model}/...`), so including it in the filename is redundant. The timestamp is unnecessary since we have one output per question (overwrites on re-run).

---

## Testing Checklist

After fixing, verify:
- [ ] All models use `video.mp4` as output filename
- [ ] Skip-existing logic works for all models
- [ ] Video paths are predictable: `{model}/{task}/{id}/video/video.mp4`
- [ ] No timestamps in filenames
- [ ] All models still generate videos successfully

---

## Files to Modify

1. `VMEvalKit/vmevalkit/models/openai_inference.py` - Line 427
2. `VMEvalKit/vmevalkit/models/veo_inference.py` - Line 437
3. `VMEvalKit/vmevalkit/models/runway_inference.py` - Line 409
4. `VMEvalKit/vmevalkit/models/ltx_inference.py` - Line 167
5. `VMEvalKit/vmevalkit/models/svd_inference.py` - Line 160
6. `VMEvalKit/vmevalkit/models/wan_inference.py` - Line 170
7. `VMEvalKit/vmevalkit/models/morphic_inference.py` - Line 150
8. `VMEvalKit/vmevalkit/models/sana_inference.py` - Line 299
9. `VMEvalKit/vmevalkit/models/cogvideox_inference.py` - Line 339
10. `VMEvalKit/vmevalkit/models/dynamicrafter_inference.py` - Line 381

