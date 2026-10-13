# Image Processing from Scratch (Base MATLAB)

Pure-MATLAB image-processing pipeline written from the ground up — no
Image Processing Toolbox, no `im*` functions. Images are plain double
arrays (RGB scenes in `[0,1]`, grayscale in `[0,1]`, binary as logical);
every kernel, threshold and labeler is hand-built. Fully deterministic:
no randomness anywhere, no downloads, no binary assets.

## What it showcases

`run_pipeline` composes the whole chain on a synthetic scene (black canvas
with a white rectangle, a green disc, a yellow disc): grayscale luma →
hand-built Gaussian blur → from-scratch Sobel gradients → histogram Otsu
threshold → binary opening → BFS connected-component labeling. Each stage
is an independently tested, documented function.

## Quick start

```matlab
cd matlab/projects/image-processing
generate_figures   % writes images/pipeline_stages.png + images/final_labels.png
cd ../..; run_checks   % repo-wide: checkcode lint + runtests over projects/
```

Tests can also be run directly: `results = runtests('tests')`.

## Function inventory

| Function | Input scale | Output | Notes |
|---|---|---|---|
| `to_grayscale` | double `[0,1]` or uint8 | double, same scale | BT.601 luma weights; 2-D input passes through |
| `gaussian_blur` | double, any scale | double, same scale | kernel built from exp weights, `conv2(...,'same')`, zero-padded edges |
| `sobel_edges` | double `[0,1]` | mag `[0,1]`, orient radians | Sobel kernels hand-coded; mag normalized by 4 (full-contrast step → 1); `atan2(gy,gx)` |
| `otsu_threshold` | finite numeric, any scale | scalar in input scale | 256 bins over `[min,max]`, between-class variance max; ties → lowest bin |
| `binarize` | numeric + scalar threshold | logical | `img > threshold` |
| `bin_erode` / `bin_dilate` | logical or numeric 2-D | logical | 3x3 element via `conv2` true-neighbor counting (9 / >0); edges are background |
| `bin_open` / `bin_close` | logical or numeric 2-D | logical | `bin_dilate(bin_erode(x))` / `bin_erode(bin_dilate(x))` |
| `label_components` | logical or numeric 2-D | double labels + count | BFS flood fill, **4-connectivity** (diagonal-only touch = separate) |
| `run_pipeline` | — | struct of all stages | returns `scene, gray, blurred, edge_mag, edge_orient, threshold, edges_binary, opened, labels, count` |
| `generate_figures` (script) | — | `images/*.png` | renders 2 figures; PNGs exist only after it runs |

## Tests (tests/)

`checkcode`-clean, function-based, all synthetic and fast:

| File | Asserts |
|---|---|
| `test_grayscale` | constant RGB → constant luma; pure-channel images hit 0.2989/0.5870/0.1140 exactly; 2-D passthrough; bad shapes rejected |
| `test_sobel` | ideal vertical step: max magnitude exactly 1, high values confined to the two edge columns, orientation 0; horizontal step → orientation π/2; flat image → zero magnitude |
| `test_otsu` | bimodal image: threshold strictly between modes 0.2/0.8 and binarization puts exactly the high half in class 1; threshold within input value range; constant image returns its own value |
| `test_morphology` | erode of 5x5 all-true square → centered 3x3 (hand-checked); erode/dilate of 5x5 plus sign match hand-derived masks; opening removes a 1px speck but keeps a 4x4 blob exactly; closing fills a 1px hole in a 5x5 block |
| `test_label_components` | exactly 3 disconnected shapes → count 3 with raster-order ids; diagonally-touching pixels stay separate under 4-connectivity; empty image → count 0 |
| `test_pipeline` | end-to-end run finds the expected 3 objects; result struct has all 10 fields; sizes/types/ranges consistent (logical masks, labels double, magnitude in `[0,1]`) |

## Images

Referenced by this README and produced by `generate_figures` (run it first):

- `images/pipeline_stages.png` — the six stages above as a 2x3 panel
- `images/final_labels.png` — grayscale scene with each labeled object colorized, white outlines overlaid

> **Note:** every project in this portfolio defines its own `generate_figures`. Run it from within this project folder, or with only this project's root on the MATLAB path, to avoid same-name function shadowing between sibling projects.
