# Single picker UI: physical-device investigation, 5 November 2026

This investigation covers the newly approved single picker UI. The October
measurements in [the earlier report](ios26-raster-performance.md) cover a different
design and are not a before/after comparison for this UI.

**Status:** no A8 optimization passed the timing and appearance gates. An iPhone
7 Plus prototype substantially reduced repeated raster work, but regressed first
opening. Its final-source comparison and partial-sheet quality matrix are pending.
These results do not establish that the current PR is free of jank.

## Protocol and source

The frozen baseline package fingerprint is
`c296122f4c0763c87e54b22f9576c1c7c83859d65a7a04130867b197047403f3`.
Its `lib/`, assets and pubspec match commit `37a7a41` byte for byte, excluding
`.DS_Store`. Later shader separation and guarded native Gaussian changes are
not covered by that baseline fingerprint or the prototype results below.

Runs use Flutter 3.47.5, profile mode and `benchmarkLive`: English, a fresh process,
one separately captured first opening, then three cycles of opening, dragging,
flinging down/up, native keyboard input, search, empty search, clear and close.
Semantics remain enabled. The caller's ordinary Material TextButton is included.
Keyboard phases use fixed waits rather than waiting for a blinking caret to
settle. Native screenshots in six light/dark rest, scrolled and keyboard states
follow the timing windows. Timing runs use the light theme; dark screenshots
provide appearance evidence only.

No warm-up, renderer override or driver-cache purge is used. Raw FrameTiming
samples, action windows, source/binary manifests and cleanup receipts remain in
the local experiment directories named below. FrameTiming measures engine wall
time, not GPU duration or presented FPS. First-opening sample counts are small;
the values reported as first-opening peaks are not stable cold-start percentiles.

## Galaxy A8

SM-A530F, Android 9/API 28, 60 Hz, DPR 3. The SDK selects Skia/OpenGL and reports
shader-filter support as false. Battery temperature was recorded, including a
cooled control; API 28 thermal-service information was unavailable. Battery
temperature alone does not establish the SoC thermal state.

All values below are raster milliseconds. Repeated phases report p95.

| Run | First-opening peak | Reopen | Drag | Fling down | Search | Close |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Initial baseline | 389.542 | 26.227 | 23.715 | 26.183 | 20.691 | 31.877 |
| Cooled baseline | 419.286 | 25.027 | 24.322 | 27.952 | 21.205 | 32.986 |
| Reverse-order baseline | 414.170 | 28.970 | 22.808 | 24.774 | 19.636 | 33.963 |
| H: control blend `src` | 391.865 | 31.807 | 27.536 | 25.193 | 19.492 | 33.820 |
| I: sheet clip without its saved surface | 423.438 | 39.006 | 45.651 | 41.808 | 27.321 | 41.659 |
| K: mesh shade | 435.747 | 24.682 | 24.433 | 25.366 | 20.808 | 36.789 |

H and K did not improve overall timing against the controls. I regressed timing
and changed appearance. Earlier clamp, redundant-fill and zero-radius interior
clip variants also failed to establish a repeatable overall win. None is adopted.
The separate Simulator experiment that exposed a rectangular background behind
partial-sheet corners was rejected before physical-device measurement.

A separate caller-only NoSplash diagnostic retained a 429.482 ms first-opening
peak versus 414.170 ms in its control. It does not support blaming the roughly
400 ms peak on the caller's InkSparkle effect.

A diagnostic Skia trace recorded 21 `driver_link_program` calls totalling
510.879 ms and 42 `driver_compile_shader` calls totalling 72.634 ms during first
opening. Tracing adds substantial overhead: these are diagnostic trace durations,
not ordinary-run timings, and nested scopes must not be added together. Warm
drag/fling traces recorded four internal save-layer operations per frame.
Recorded SKP bounds identify three bounded control backdrops rather than three
full-screen blur rectangles; recorded bounds do not prove GPU allocation sizes.
This evidence points to driver program linking at first opening and continuing
layer/draw work during scrolling, without assigning an exact cost to each widget.

## iPhone 7 Plus prototype

iPhone9,4, iOS 15.8.8, 60 Hz, DPR 3, SDK-default Impeller/Metal context with
shader-filter support. The table compares runs using the same recovered USB
launch transport; earlier LLDB launches are not mixed into this comparison.

| Run | First-opening peak | Reopen p95 | Drag p95 | Fling down p95 | Search p95 |
| --- | ---: | ---: | ---: | ---: | ---: |
| Baseline | 309.341 | 143.834 | 146.934 | 143.749 | 150.252 |
| F: bounded native Gaussian prototype | 336.916 | 44.308 | 37.240 | 37.146 | 41.042 |

F retains the isolated rounded sheet surface and bounds the native Gaussian
source halo inside it. Its fingerprint is
`bf7ba39674040a17eeaef0d12cd9cb4b6b3ce8cacc9fe08ba4ad9fda54c7e8de`.
A repeat produced a 336.082 ms first-opening peak; a following baseline returned
to 308.865 ms. Repeated raster work improved by approximately 75%, while first
opening worsened by approximately 27 ms. Warm raster remains above 16.67 ms;
keyboard UI p95 also rose from roughly 12–13 to 21–23 ms. This is not a complete
frame-pipeline fix.

All six captures preserve rows, flags, dock controls and the native keyboard
outside the header exactly. Corner silhouettes and close glyph masks also match.
The progressive header differs by at most 1/255 at rest, 9/255 when scrolled in
light mode and 8/255 in dark mode. The blur is not pixel-identical. A subsequent
control-bounds experiment changed controls by up to 45/255 and was rejected.

Xcode changed from 26.6 to 27.2 during the investigation. A later F control built
with Xcode 27.2 retained the warm gain, but its 355.830 ms first-opening peak is
not compared directly with an older-toolchain baseline. The final pair must use
identical toolchains, launch transport and exact final source. The 24-scene
partial/custom-radius/translucent quality matrix is prepared but has not run.

## Evidence and remaining gates

Local evidence root: `/private/tmp/country-picker-baseline-2026-11-05`.
The transport-recovery receipts, experimental aggregates and partial-sheet
harness are under `/private/tmp/country-picker-ddi-recovery-20261105`.
Successful physical runs report completion, no Flutter errors, exit code zero,
removal of only the temporary test bundle and release of the device lease.

Before claiming a shipped improvement: freeze the final package source, rerun
matched before/after sessions on both devices, complete the partial-sheet image
matrix, and report UI, raster and total-span distributions together. A8 first
opening and final-source 7 Plus first opening remain unresolved. Native Windows
3.47.5 rendering CI also remains a separate unresolved gate; minimum-SDK 3.44
success is not a substitute for it. Native exception logging identified an
access violation (`0xC0000005`) inside `d3dcompiler_47.dll` on both x64 and ARM64
while the progressive header is being prepared through Impeller/OpenGLES.
A Windows-only uniform-loop-bound experiment did not fix the access violation
and was removed. The next variant uses the original Gaussian sum without
indexed sample pairing; native verification is pending. The original non-Windows
generic and separable IPLR programs remain byte-identical, respectively
`0a186c8eef3efe08eff25e23079f0a4ba9c571a915c353f9a677b2a86889ca81` and
`5dad1c6171c7de66a76d462cd4ffaa099b921ad72e4ca18855d2b6be9e618db0`.
