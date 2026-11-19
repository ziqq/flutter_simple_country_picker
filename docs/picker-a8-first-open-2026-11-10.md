# Galaxy A8 first-opening CPU and raster attribution

Measured on a physical Samsung Galaxy A8 (SM-A530F, Android 9) with Flutter 3.47.5 in profile mode and Skia/OpenGL. The picker runtime in PR #16 was `4fc727e`. Each run started a fresh process without warming shaders or clearing driver caches. The original opening action and its assertions were retained. The diagnostic fixture stopped after the first opening and the timing callback drain.

## UI thread

The original untraced run measured **119.393 ms UI and 415.580 ms raster** in frame 11. A fresh run with Dart markers reproduced the spike in frame 12 at **104.996 ms UI and 374.977 ms raster**. These are separate captures. The marker durations below describe the new frame and its preceding work.

| Scope | Wall time | Position relative to frame 12 |
| --- | ---: | --- |
| Built-in localization delegate load | 0.016 ms | App startup |
| Provider construction and country mapping | 1.909 ms | Frame 11 |
| Await of the provider's in-memory list | 57.210 ms elapsed | Spans part of frame 11 and resumes after its UI work |
| Filtering and favorites | 2.720 ms | Before frame 12 |
| Name localization and sort-key creation | 2.605 ms | Before frame 12 |
| Sort comparisons and list sort | 0.469 ms | Before frame 12 |
| Projection from sorted records to countries | 0.174 ms | Before frame 12 |
| Grouping by initial and building sliver entries | 0.652 ms | Before frame 12 |
| Lazy entry builder, 15 calls | 0.245 ms | Inside frame 12 layout |
| Country row widget build, 14 calls | 7.901 ms | Inside frame 12 layout |

The provider creates its list synchronously. Its getter returns the existing list in a Future. The await began during frame 11 and resumed 14.053 ms after the UI phase of that frame had finished. The 57.210 ms interval includes scheduling and other work on the thread. The measured synchronous country mapping is 1.909 ms.

Frame 12 spent **99.930 ms** in Flutter's `LAYOUT` scope, including **41.318 ms** in 20 nested framework `BUILD` scopes. Two young-generation collection scopes totaling **14.408 ms** overlap those builds. The per-row marker measures the row widget's own build. Descendant mounting and render-object layout also occur within the framework scopes. These measurements overlap. Outside layout, frame 12 recorded 3.652 ms of paint and 1.414 ms of other UI time.

The stock package also reproduced the UI peak without the custom Dart markers. Frame 14 spent 124.033 ms on the UI thread, with 118.350 ms within layout.

## Raster thread

The stock and no-blur traces used the same fixture and driver. Their battery temperatures before installation were 24.2 and 24.4 °C, with 100% charge and USB power. The no-blur variant disables the search and both close-button backdrop filters for diagnosis and changes their appearance.

| Diagnostic | Frame | Raster | Encode | GL compile | GL link | Linked programs |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Stock picker, peak | 14 | 376.320 ms | 359.954 ms | 46.103 ms | 244.700 ms | 14 |
| Three backdrop blurs disabled, peak | 25 | 273.573 ms | 258.220 ms | 30.091 ms | 167.196 ms | 9 |
| Same no-blur picker, caller splash disabled, peak | 8 | 333.296 ms | 317.084 ms | 35.855 ms | 215.635 ms | 11 |

The compile and link scopes in each row are disjoint and fall within the corresponding `Rasterizer::DoDraw` frame. In frame 25 they account for **197.287 ms**, or **72.1%** of raster wall time. The largest remaining link takes 55.184 ms under `FillRRectOp`. Other link scopes occur under `FillRectOp`, `AtlasTextOp`, `CircleOp`, `EllipseOp` and `TextureOp`. These are native draw-operation families. The stock engine trace contains no program key or direct mapping from a draw operation to a widget. The timings measure wall time on the raster thread rather than individual GPU pass durations.

The preceding frame of the no-blur run took 190.052 ms raster, including a 144.596 ms `FillRectOp` link. The follow-up kept the same no-blur picker and changed only the launch fixture's `TextButton` to `NoSplash`. Its battery started at 24.9 °C with 100% charge and USB power. Its corresponding first frame took 7.514 ms raster and recorded no GL compile or link scopes. The later picker frame still took 333.296 ms. This separates the caller button's cold paint from the picker scene's remaining cold cost.

All four diagnostic runs completed with no Flutter errors, removed the temporary app and released the device. The results localize the raster residual to cold Skia/OpenGL program compilation and linking. The diagnostic changes do not qualify as an appearance-preserving fix.

[Frame timings, scope breakdowns and capture fingerprints](performance-data/picker-2026-11-06/nov10-a8-first-open-attribution.json).
