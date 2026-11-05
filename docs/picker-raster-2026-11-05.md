# Single picker UI: physical-device investigation, 5 November 2026

This investigation covers the newly approved single picker UI. The October
measurements in [the earlier report](ios26-raster-performance.md) cover a different
design and are not a before/after comparison for this UI.

**Status:** the UI/corner correction and Windows rendering fix are in the PR.
The performance candidates below are **not shipped**. F1 improves 7 Plus timing
but fails the partial-header image gate. F2 keeps the original partial-sheet
renderer; its physical validation is waiting for the higher-priority S5 device
experiment to release 7 Plus. A8 shows no first-opening gain and an adverse
scrolling sample. These results do not establish that the PR is free of jank.

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

### Latest matched 7 Plus comparison

Both variants use Xcode 27.2/27B52, the same Runner and Flutter engine, matched
compiler/linker binaries, the unchanged profile fixture/driver and recovered USB
launch transport. The execution order is **before, after, after, before**.
The before fingerprint remains `c296122f…`; the after fingerprint is
`da4ddec6775c6aa683e9de57775b29dbaa100e55bc63dacc756af077911d2ff7`:
the guarded bounded native Gaussian path plus separate shader programs. The
earlier F-only first-opening regression above is not substituted for this pair.

| Raster, ms | Before 1 | After 1 | After 2 | Before 2 |
| --- | ---: | ---: | ---: | ---: |
| First-opening peak | 306.387 | 202.720 | 197.526 | 237.182 |
| Reopen p95 | 142.676 | 44.545 | 43.774 | 144.568 |
| Drag p95 | 146.659 | 37.541 | 37.084 | 144.471 |
| Fling down p95 | 142.903 | 37.841 | 37.131 | 143.106 |
| Fling up p95 | 143.145 | 37.973 | 37.388 | 146.557 |
| Keyboard p95 | 150.388 | 45.013 | 44.005 | 149.156 |
| Search p95 | 151.784 | 42.639 | 41.542 | 152.855 |
| Close p95 | 141.900 | 53.463 | 53.906 | 145.683 |

The first-opening populations contain 8, 8, 10 and 8 frames. Both after peaks
are below both controls, but the controls vary substantially: do not describe
306→203 ms alone as a stable universal percentage. No shader warm-up is used.
Warm scrolling raster p95 falls by approximately 74%; it still exceeds 16.67 ms.

Keyboard windows total approximately three seconds per run. Their sample counts
are 40, 72, 74 and 37. UI p50 changes from 6.712/6.437 to 12.221/9.872 ms and UI
p95 from 14.376/13.556 to 23.812/25.027 ms. Queue p95 falls from about 135 to
34–35 ms and total-span p95 from 202.055/219.850 to 86.728/86.179 ms.
Different sample populations do not isolate the cause of the increased UI time;
the raw increase remains reported rather than being called fixed.

All four runs complete with no Flutter errors and successful own-bundle/lease
cleanup. Full-height captures preserve rows, flags, dock controls and the native
keyboard exactly; header differences retain the earlier F limits. The separate
24-scene-per-side matrix preserves geometry, corner silhouettes and close glyph
masks, but partial header differences reach 31/255. F1 is therefore not adopted.
Five keyboard captures also differ at the blinking insertion caret; those raw
pixels remain in the evidence rather than being silently excluded.

F2 fingerprint `56ba3e2b39e978e924a3fae75645d10a6b0d742599276e5e01665460b2a9f0c8`
limits the native fast path to isolated full-height sheets. It passes 6,244 unit/
widget tests and 11 native Simulator tests. A new quality-only fixture uses the
SDK's deterministic cursor and records its exact rectangle on both sides.
Its 48 physical captures and exact-source timing verification are pending; F2
remains outside the committed package implementation.

### A8 final-candidate regression check

Fresh before/F2 profile builds use identical actual Maven engine libraries,
compiler binaries, harness and external dependencies. Six light/dark rest,
scrolled and keyboard images match exactly. Both runs finish without Flutter
errors and release their own test bundle and lease.

| Raster p95, ms | Before | F2 candidate |
| --- | ---: | ---: |
| First-opening peak | 404.876 | 405.826 |
| Reopen | 27.411 | 27.594 |
| Drag | 25.296 | 27.873 |
| Fling down | 28.395 | 46.209 |
| Fling up | 21.860 | 41.356 |

The adverse first repetition is retained in the aggregate. Later repetitions
return near the earlier warm range; that does not erase the adverse sample.
Its cause is not established. Shader-filter support is false in both runs, so
the candidate native Gaussian path is inactive. This fact does not override the
observed performance result. The reverse control stopped before installation because A8 disappeared from ADB; no reverse timing data exists.

Before battery temperature is 25.3→25.8°C, after 25.8→26.4°C; brightness,
low-power setting, OS and USB level match. An earlier after attempt failed the
temperature preflight before installation or timing and is excluded. Battery
temperature does not establish the unavailable SoC thermal state.

The [detailed summary](performance-data/picker-2026-11-05/7plus-summary.json)
contains UI, raster, queue and total-span n/p50/p95/max for every phase and the
exact action windows. The [manifest](performance-data/picker-2026-11-05/manifest.json)
links all four raw FrameTiming JSON files and their hashes. These report files
are tracked for review and excluded from the published package by `.pubignore`.

Local evidence root: `/private/tmp/country-picker-baseline-2026-11-05`.
The transport-recovery receipts, experimental aggregates and partial-sheet
harness are under `/private/tmp/country-picker-ddi-recovery-20261105`.
Successful physical runs report completion, no Flutter errors, exit code zero,
removal of only the temporary test bundle and release of the device lease.

Before adopting a performance candidate: complete the F2 partial-sheet image
matrix, qualify its exact source and investigate the adverse samples. A8 first
opening and warm raster remain unresolved. Native exception
logging identified an
access violation (`0xC0000005`) inside `d3dcompiler_47.dll` on both x64 and ARM64
while the progressive header is being prepared through Impeller/OpenGLES.
A Windows-only uniform-loop-bound experiment did not fix the access violation
and was removed. The original Gaussian sum without indexed sample pairing stops
the compiler crash. Correcting Windows backdrop texture orientation also restores
the country row, which otherwise sampled blank background. Light, dark and
ancestor-opacity native cases pass on Windows x64 and ARM64 with Flutter 3.47.5;
the Flutter 3.44.0 minimum-SDK job also passes in
[run 42029537763](https://github.com/ziqq/flutter_simple_country_picker/actions/runs/42029537763).
Temporary native exception instrumentation is removed from the workflow after
the diagnosis. Final CI still needs to verify that clean configuration and the
additional stripe-order assertion. The original non-Windows
generic and separable IPLR programs remain byte-identical, respectively
`0a186c8eef3efe08eff25e23079f0a4ba9c571a915c353f9a677b2a86889ca81` and
`5dad1c6171c7de66a76d462cd4ffaa099b921ad72e4ca18855d2b6be9e618db0`.

Candidate patches are retained as review evidence: [F1](performance-data/picker-2026-11-05/f1-candidate.patch) applies to `7d569d8`; [F2](performance-data/picker-2026-11-05/f2-candidate.patch) applies to the runtime code at `5829015`/`0102193`. They are not active package code. F2 runtime SHA is `4d93d93824366578ea4b05d2938fab056fae50fd3802f9b20d67613a88e72997`; its physical quality and adverse-sample gates remain open.
