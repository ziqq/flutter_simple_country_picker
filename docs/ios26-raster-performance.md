# iOS 26 picker raster performance

Measured on 16 and 21 October 2026 on the same physical Samsung Galaxy A8
(SM-A530F), Android 9, ARM64, Flutter 3.47.5 / Dart 3.13.4, profile mode,
Skia/OpenGL. The baseline already includes country-row virtualization.

Before: `d5d2a30eb2b063267a89bc96efde84d1082cc346`. After:
`320836b714f16ad0c15a9085510d6b1972aa056d`.

> Measurement update, 22 October: the measurements below used the test
> binding's default `fadePointers` policy. They describe that driven test,
> rather than a freely scheduled animation. The [benchmarkLive follow-up](#live-frame-protocol-follow-up--22-october-2026)
> records natural frame scheduling separately; values from the two protocols
> must not be compared directly.

## Cause and change

The circular iOS 26 flags repeatedly rasterized enlarged native color-emoji
text. Giving each flag a repaint boundary and a complex-picture cache hint
did not reliably reduce raster p90: en/tr/ru changed from
16.206/16.021/16.856 ms to 17.068/15.994/16.948 ms in the exploratory batch.
The engine's picture-cache hint alone was insufficient on this device.

The private flag renderer now reuses an image recorded from the actual
existing flag subtree through Flutter's shared `ImageCache`. On the measured
GPU backend, `Picture.toImageSync` produces a GPU-resident image. It retains
the original system/package font, resolved text style, emoji, scale and
40 logical-pixel box. The existing circular clip and selection badge stay
outside the image, so changing the selected country does not bake a stale
badge into the flag. Classic flags and phone-input rendering are unchanged.

The cache key includes the resolved paragraph, direction, text scale, locale,
size, pixel density and system-font revision. Loading fonts invalidates old
keys, including when no picker is mounted. Flutter's ordinary cache limits,
LRU eviction and memory-pressure handling apply. Disabled/undersized caches
and selectable/composited text use the original renderer. Images are not
bundled assets and introduce no new package, font or license.

Preparing every missing image together worsened first-opening spikes in an
intermediate prototype. The final renderer paints the original text on the
first frame and prepares at most two missing images in each later frame;
remaining flags keep showing their original text. This work remains in the
measured frame sequence. The change does not prewarm outside the benchmark.

Flutter API references: [ImageCache](https://api.flutter.dev/flutter/painting/ImageCache-class.html),
[Picture.toImageSync](https://api.flutter.dev/flutter/dart-ui/Picture/toImageSync.html),
[setIsComplexHint](https://api.flutter.dev/flutter/rendering/PaintingContext/setIsComplexHint.html).

## Controlled comparison with native captures — 16 October

Each revision ran in a newly launched process with the identical benchmark:
English, Turkish and Russian, one separately measured first opening followed
by three cycles of open, fling down/up, search, empty search, clear and close.
Semantics were explicitly disabled on both sides. The fixture uses the public
`showCountryPicker` API, grouping, World Wide and `RU`/`US`/`FR` favorites.

All cells show **before → after**. The following three-cycle values exclude
the separately measured first opening. Raster >16 ms counts use the SDK's
fixed budget; these are not FPS or display-dropped-frame counts.

| Locale | Frames | UI p90, ms | Raster p90, ms | Raster p99, ms | Raster >16 ms | Raster maximum, ms |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| en | 393 → 396 | 10.964 → 11.255 | 16.711 → 12.054 | 48.767 → 39.036 | 45 → 15 | 100.880 → 125.450 |
| tr | 391 → 393 | 10.357 → 11.667 | 15.908 → 12.345 | 38.565 → 27.362 | 38 → 10 | 53.973 → 51.642 |
| ru | 386 → 391 | 14.235 → 15.590 | 16.534 → 12.709 | 44.383 → 36.725 | 41 → 10 | 95.584 → 51.235 |

Across these cycles, raster overruns fell from 124/1,170 to 35/1,180 frames
(10.60% → 2.97%; 71.8% fewer overruns). Raster p90 decreased by 22–28%.
UI p90 increased by 0.291–1.355 ms. The en maximum increased; the patch does
not eliminate every heavy frame.

First-opening results are retained separately rather than hidden by warm-up:

| Locale | Frames | UI maximum, ms | Raster maximum, ms | Raster >16 ms |
| --- | ---: | ---: | ---: | ---: |
| en | 5 → 5 | 47.682 → 48.654 | 160.333 → 162.181 | 3 → 3 |
| tr | 5 → 6 | 67.203 → 39.385 | 30.229 → 49.444 | 2 → 2 |
| ru | 5 → 5 | 67.054 → 48.257 | 29.949 → 48.057 | 2 → 2 |

Only en is the first picker in the process. The tr/ru rows open new locale
fixtures after preceding scenarios; the system/driver glyph and shader
caches were not reset. The first process opening remains about 160 ms in
raster, and tr/ru first-opening raster maxima worsened in this batch.

## Full frame latency check — 21 October

The deferred comparison is complete. Both sides were rerun together rather
than pairing a new candidate run with the incomplete 16 October baseline.
Before: `d5d2a30eb2b063267a89bc96efde84d1082cc346`. After:
`117d0c17fdc772ae41400a759f96054c84984a00`, whose library sources are identical
to implementation commit `320836b`. No additional renderer changes were made.

The temporary native host was regenerated with the same pinned SDK and the
saved manifest, icon dependency/lock and exact Dart benchmark/driver. Both
sides use this one restored host, changing the package dependency path and
revision label. The three-cycle protocol and separately measured first
opening are unchanged. Both processes completed all scenarios. Battery
temperatures were 24.4 °C before, 24.8 °C between and 25.1 °C after the runs;
charge stayed at 100%. Android API 28 uses the legacy OpenGL fallback with
this default configuration; see [Flutter's renderer availability](https://docs.flutter.dev/perf/impeller#android).

`FrameTiming.totalSpan` measures vsync start through raster finish; it does
not measure input-to-display latency. The queue field measures the interval
between UI build completion and raster start. Both are collected in the
committed benchmark. Per-phase frame counts and UI/raster p90 values were
cross-checked against the SDK summaries before calculating total/queue values.
See [FrameTiming.totalSpan](https://api.flutter.dev/flutter/dart-ui/FrameTiming/totalSpan.html)
and [FramePhase](https://api.flutter.dev/flutter/dart-ui/FramePhase.html).

All cells show **before → after**; the first opening is excluded from these
three-cycle results, as in the earlier comparison.

| Locale | Frames | UI p90, ms | Raster p90, ms | Total p50, ms | Total p90, ms | Queue p90, ms |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| en | 387 → 393 | 9.961 → 11.305 | 17.187 → 12.805 | 11.786 → 13.111 | 39.732 → 23.912 | 1.045 → 0.866 |
| tr | 391 → 391 | 10.663 → 11.912 | 16.214 → 13.078 | 13.083 → 13.036 | 30.715 → 25.879 | 0.963 → 0.870 |
| ru | 383 → 389 | 12.135 → 11.052 | 17.405 → 13.721 | 12.978 → 13.996 | 39.627 → 22.345 | 1.037 → 0.905 |

Total p90 decreased in all three locales, by 16–44%, and queue p90 also
decreased. This supports a real tail-latency improvement in these scenarios;
the raster reduction was not offset by greater queue waiting. It does not
establish an improvement to every frame: total median increased for en/ru,
and UI p90 increased for en/tr.

| Locale | Raster >16 ms | Total >16 ms | Raster maximum, ms | Total maximum, ms |
| --- | ---: | ---: | ---: | ---: |
| en | 53 → 12 | 135 → 144 | 128.494 → 79.270 | 134.221 → 135.098 |
| tr | 42 → 11 | 148 → 148 | 52.725 → 56.951 | 98.433 → 102.764 |
| ru | 51 → 19 | 156 → 143 | 52.666 → 101.925 | 108.007 → 108.720 |

Raster overruns fell from 146/1,161 to 42/1,173 frames (12.58% → 3.58%,
71.2% fewer overruns). Total-span overruns barely changed: 439 → 435
(37.81% → 37.08%). Queue intervals above 16 ms fell from 18 to one.
Total maxima did not improve; the Russian raster maximum increased and
occurred during opening. The English maximum occurred while scrolling down.
These are single-batch observations, not proof of a universal FPS increase.

First opening remains a separate limitation:

| Locale | Frames | Raster maximum, ms | Total maximum, ms |
| --- | ---: | ---: | ---: |
| en | 5 → 5 | 175.999 → 174.612 | 236.008 → 239.710 |
| tr | 6 → 7 | 32.504 → 69.466 | 99.504 → 129.022 |
| ru | 5 → 7 | 31.040 → 50.466 | 96.786 → 101.677 |

Only en is first in the process. The first-frame original-text path is kept,
and preparing missing images adds work on subsequent frames. The experiment
does not isolate all startup/font/shader costs, and does not establish a
cold-opening improvement. New-locale raster maxima and all three first-open
total maxima worsened in this batch. All first-open samples are retained.

The cache again held 25 / 49 / 77 images, with the same byte totals below and
zero pending/live entries. Exact per-phase p50/p90/p99/max/count values are in
[ios26-raster-latency-frame-timings.csv](ios26-raster-latency-frame-timings.csv).
Raw reports, toolchain/source hashes, the restored host configuration and
calculation script are saved in `reports/ios26-raster-2026-10-21/`.

## Memory and appearance

The image cache is empty after every baseline scenario. After the changed
scenarios it contains 25 / 49 / 77 flag images, occupying 1,440,000 /
2,822,400 / 4,435,200 bytes respectively (1.37 / 2.69 / 4.23 MiB).
These counts accumulate across the three locales. Live and pending image
counts are zero after each scenario. They describe the shared ImageCache
accounting, not total process/GPU memory, peak allocation or the font atlas.

After all timed scenarios, the same Android PixelCopy harness captured 54
matched native screenshots per revision at 1080 × 2175: both picker styles ×
light/dark/RTL with text scale 1.8 × initial/pinned/handoff/next/reverse/
search/empty/clear/selected-FR. Scroll offsets are asserted equal before
capture. Native view capture includes the actual cached images drawn by the
engine; it does not replace them with a RenderRepaintBoundary snapshot.

30/54 pairs are pixel-exact, including all 27 classic captures. The other
24 pairs differ only inside the iOS 26 flag image column. Native flag artwork,
colors, circular bounds, scale, badge and surrounding geometry are retained.
Bitmap sampling changes antialiased pixels at fractional scroll positions
(maximum channel difference 40/255), so these pairs are not bit-identical.
Text, controls, sticky headers and selection badges outside the images are
pixel-exact. The temporary host includes `cupertino_icons` on both revisions;
its search/close/check controls render their actual icons.

## Validation and reproduction

`make ci` passes 6,219 tests, 100% line coverage after the repository's existing
localization filter and narrow unreachable-path ignores, Pana 160/160 and
publish dry-run with zero warnings. Nine new widget regressions cover reuse,
preparation budget, selection/remounting, scale/RTL/density, font changes,
disabled/limited caching, memory pressure and selectable text. The reuse
regression fails against the unchanged baseline (expected three cached
images, received zero) and passes with the implementation.

The production cache's sole coverage ignore retains the original-text
fallback if a consumer supplies a custom ImageCache that declines or delays
this private synchronous loader. Normal cache, disabled cache, byte/count
limits, eviction and memory pressure paths are exercised.

Use `example/integration_test/grouped_picker_performance_test.dart` and
`example/test_driver/grouped_picker_performance_driver.dart` in a configured
Android example host:

```bash
COUNTRY_PICKER_BENCH_OUTPUT=build/ios26-raster-performance.json \
  mise exec -- flutter drive --profile --no-dds \
  --driver=test_driver/grouped_picker_performance_driver.dart \
  --target=integration_test/grouped_picker_performance_test.dart \
  --dart-define=BENCHMARK_SEMANTICS=false \
  --dart-define=BENCHMARK_STYLE=ios26 \
  --dart-define=BENCHMARK_REVISION="$(git rev-parse HEAD)" \
  -d DEVICE_ID
```

Both measurements use the same generated Android host, pinned SDK, manifest,
icon font and driver, changing only the package dependency path. These are
new comparisons, separate from the earlier virtualization fixture, which
omitted `cupertino_icons`. Do not compare their absolute values as one A/B.

Exact 16 October phase values, frame counts, maxima and overruns are versioned
in [ios26-raster-frame-timings.csv](ios26-raster-frame-timings.csv). Source hashes,
raw reports, exact harnesses, native PNGs/diffs, red/green tests and local CI
output are saved in `reports/ios26-raster-2026-10-16/` (excluded from publishing).
These results establish this A8 behavior, not iOS/Windows or cross-device
performance, and do not establish that all frames meet 16 ms.

## Cold-opening diagnosis and data preparation — 21–22 October 2026

This follow-up compares the current cache implementation, baseline
`1861f58705674920dca1d82c88358d57cf2c3482`, with
`2c3accac555db78d29cee6f16f9e043b155bf8c7`. It uses the same Galaxy A8,
pinned Flutter 3.47.5 and Skia/OpenGL. Two baseline processes and one final
candidate process ran the same three-locale, three-cycle protocol. No
shader warm-up runs before these timed scenarios. The renderer, flags,
clipping, sticky list and public API are unchanged by this follow-up.

### What causes the remaining spikes

A separate `--trace-skia` diagnosis attributes 142.258 ms of a 193.670 ms
raster frame to shader compilation. A FillRRect program alone took 63.047 ms,
including 55.193 ms in driver linking. The first downward and upward flings
also compiled additional clip/text/texture programs; repeated phases normally
had no shader compilation. A button-only control still cost 80.278 ms with
no picker, while opening the picker directly retained its own cold spike.
The caller's ink effect and the picker's shader costs are separate.

These instrumented traces diagnose the cause; the following performance
tables come from runs without tracing. Extra flag layers, eager snapshots,
preclipped images, alternate rounded paths, and row-theme/Material changes
were tested and excluded because they did not consistently improve cold
opening and subsequent peaks. Requesting Impeller still selected Skia on
this API 28 device. No renderer override is shipped.

### Accepted data-path change

Localized names used to be folded and lowercased inside every sort
comparison. The controller now computes a comparison key once per country,
then compares the original spelling on equal keys. The untranslated-name
fallback and display order stay the same. Regression checks compare the
result with `CountryUtil.compareNames` in all bundled locales and exercise
case/diacritic ties. No coverage exclusions were added.

A separate A8 controller benchmark performs 31 loads per locale, including
World Wide and three favorites (245 returned entries). The timer covers
`getCountries`; it excludes provider construction and loading the localization
delegate. The first sample is retained separately; the table is the median
of the remaining 30 samples. This measures data preparation, not a frame or
input-to-display latency.

| Locale | Preparation before, ms | Preparation after, ms |
| --- | ---: | ---: |
| en | 2.526 | 1.950 |
| tr | 6.168 | 1.351 |
| ru | 5.685 | 1.250 |

### Full-frame comparison

Cells show **baseline run 1 / baseline run 2 → final candidate**. The two
baseline runs expose the measurement spread. Main-cycle values exclude the
separately retained first opening. Counts over 16 ms use the fixed diagnostic
budget; they are not display FPS or dropped-frame measurements.

| Locale | UI p90, ms | Raster p90, ms | Total p90, ms | Total p99, ms |
| --- | ---: | ---: | ---: | ---: |
| en | 10.735 / 10.961 → 10.449 | 14.082 / 13.127 → 13.059 | 25.549 / 25.283 → 23.265 | 89.861 / 78.505 → 76.994 |
| tr | 13.937 / 10.545 → 10.613 | 13.993 / 12.551 → 12.782 | 25.349 / 21.242 → 21.280 | 78.813 / 86.715 → 75.945 |
| ru | 14.440 / 13.484 → 11.735 | 13.662 / 13.447 → 13.551 | 27.696 / 27.205 → 24.803 | 81.521 / 79.321 → 81.529 |

| Locale | First-open UI maximum, ms | Raster maximum, ms | Total maximum, ms | Complete open action, ms |
| --- | ---: | ---: | ---: | ---: |
| en | 40.557 / 47.899 → 37.556 | 193.091 / 161.123 → 160.443 | 234.524 / 209.989 → 198.697 | 637.060 / 675.897 → 668.543 |
| tr | 52.292 / 41.898 → 74.782 | 47.402 / 49.540 → 58.942 | 101.148 / 92.306 → 135.217 | 676.215 / 750.264 → 667.606 |
| ru | 45.059 / 64.094 → 74.400 | 47.163 / 60.890 → 57.966 | 93.609 / 126.195 → 133.725 | 678.445 / 766.779 → 671.809 |

Only en opens the first picker in each process; tr/ru create new locale
fixtures after previous scenarios. The complete action includes the test's
`pumpAndSettle` polling and is not physical touch-to-display latency.
`FrameTiming.totalSpan` ends at raster completion, before display presentation.

**The cold shader problem and all remaining heavy frames are not fixed.**
The final first-process raster maximum is 160.443 ms against baseline
161.123–193.091 ms. Localized first-opening UI maxima still worsen in this
batch. Main-cycle maxima and the full per-phase values are retained in
[ios26-cold-opening-frame-summary.csv](ios26-cold-opening-frame-summary.csv).
The accepted change reduces data preparation work; these measurements do
not establish a reliable end-to-end cold-opening improvement.

### Explicit warm-up experiment

A separate temporary-host prototype explicitly prepares drawing programs
before opening. With tracing enabled, first-opening raster maximum changed
from 193.670 to 80.720 ms and total maximum from 237.993 to 115.490 ms.
The preparation itself took **406.307 ms before the action**. It shifts work
to preparation; it does not remove that work or prove faster startup. First
scrolling still had an approximately 79 ms raster frame. An expanded warm-up
cost 724.627 ms and did not consistently remove later compilation peaks.

No warm-up or new public API is included in `2c3acca`. On 22 October the
maintainer explicitly rejected a new API and preliminary warm-up. Both
remain excluded from the continuation. The baseline/candidate tables above
include no hidden warm-up.
The mechanism follows Flutter's
[ShaderWarmUp](https://api.flutter.dev/flutter/painting/ShaderWarmUp-class.html)
contract. The tests of extra layers and paths also follow the measurement
trade-off described in PlugFox's
[canvas rendering guide](https://plugfox.dev/high-performance-canvas-rendering/).

### Visual and validation evidence

Android PixelCopy compares 60 states: both styles, light/dark/RTL at text
scale 1.8, initial/held-RU/pinned/handoff/next/reverse/search/empty/clear/
selected-FR. The 54 static states are pixel-exact. Of six held-press states,
five are exact; the RTL iOS 26 pair differs at 104 of 2,349,000 pixels by at
most 1/255 per channel. All scroll offsets match. Presses advance through
30 actual frames before capture so the initial ink/fade animations finish.
Baseline static captures and settled-press captures are separate runs of
the same unchanged baseline sources. Earlier transient press captures are
excluded from this comparison. The interrupted final capture produced no
report and was replaced by a completed retry on the same A8.

`make ci` passed on `2c3acca`: 6,221 tests, 100% filtered line coverage
(2,275/2,275), publish dry-run with zero warnings and Pana 160/160. The 61
tracked library files match the measured candidate snapshot; only the
controller differs from the baseline. Full action durations were added to
the existing benchmark. Raw JSON, shader traces, exact temporary-host
harnesses, source hashes, native PNGs and logs are in
`reports/ios26-cold-raster-2026-10-21/`, excluded from publication. These results
establish behavior on this A8, not performance on other devices or backends.


## Live-frame protocol follow-up — 22 October 2026

The benchmark now explicitly uses Flutter's `benchmarkLive` frame policy.
The previous default, `fadePointers`, can skip animation frames that a test
does not pump. For example, the first control in this batch records five
first-opening frames with the old protocol and seventeen with the live one.
This changes the workload, so the old and new percentile figures must not be
compared directly. The cache implementation has not been remeasured against
its pre-cache revision under this new protocol.

`benchmarkLive` continuously services frames in this binding, including during
idle waits. It is a controlled device benchmark, not a measurement of idle
app behavior, display FPS or physical touch-to-display latency. SDK
`watchPerformance` summaries include capture/flush intervals, while named
phases contain the actions themselves. These windows have different frame
counts and are retained separately in
[ios26-live-frame-summary.csv](ios26-live-frame-summary.csv): `sdk_main`
contains SDK UI/raster samples; `named_phases` and individual phases retain
full `FrameTiming.totalSpan` and raster-queue timings for their action windows.
A missing total in an SDK-summary row is unavailable data, not zero latency.

The final harness also exports every collected `FrameTiming`, with frame
numbers and build/raster timestamps, the boundaries of each action, and the
frame policy/protocol version. Frames outside named phases remain inspectable.
No behavior assertion or gesture was removed. First opening is still timed
separately from the repeated cycles, with no picker shader/flag warm-up.

All runs use the same physical A8 `5200fe1d4f1d95b7`, pinned Flutter 3.47.5,
profile Skia/OpenGL, DPR 3, semantics disabled, the same en/tr/ru fixtures and
three repeated interaction cycles. Only en opens the first picker in each
process; tr/ru follow earlier fixtures. No OS/driver cache reset is claimed.
All 61 tracked library files in the final temporary package match `b14873f`.
The public API, renderer, native flags and sticky-list implementation remain
unchanged by this continuation.

### Untraced first-opening controls and rejected candidates

The following rows use protocol 2. Cells are maxima inside the first en open
action; action duration includes settling/polling and is not presentation time.
The final-harness row changes recording metadata, not package rendering.

| Run | UI max, ms | Raster max, ms | Total max, ms | Complete action, ms |
| --- | ---: | ---: | ---: | ---: |
| Control 1 | 44.628 | 153.435 | 246.747 | 682.521 |
| Control 2 | 51.331 | 152.211 | 260.890 | 682.786 |
| Control 3 | 50.479 | 158.115 | 260.259 | 683.289 |
| Final harness, unchanged renderer | 42.122 | 157.762 | 261.456 | 691.676 |
| Rejected uniform AA clips | 41.733 | 183.419 | 271.709 | 678.112 |
| Rejected single-edge AA clips | 41.481 | 194.626 | 284.885 | 731.475 |

The equivalent-looking AA candidate matched all 60 native PixelCopy captures
exactly, but did not improve cold opening. Extending the rectangular AA clip
to constrain only the flat edge also failed the latency gate. Neither is
shipped. Earlier hard-edge and preclipped-image prototypes changed pixels
(up to 7/255 at section edges and 40/255 at flag edges respectively) and were
excluded. A sheet repaint boundary also failed to improve the old-protocol
control. The complete experiment CSV and sources remain in the evidence folder.

### Final unchanged-renderer live-cycle measurements

These are SDK `watchPerformance` summaries for the final harness. They include
its capture intervals; the linked CSV retains action-window total latency and
the corresponding per-phase values separately.

| Locale | SDK frames | UI p90, ms | Raster p90, ms | Raster maximum, ms |
| --- | ---: | ---: | ---: | ---: |
| en | 742 | 8.801 | 15.787 | 52.954 |
| tr | 766 | 8.645 | 15.982 | 95.168 |
| ru | 764 | 9.368 | 15.725 | 44.964 |

**No renderer optimization is accepted in this follow-up. Heavy first opening
and all remaining raster peaks are still unresolved.** Improvements in an
isolated phase did not justify a cold-opening regression or changed pixels.
The only shipped code change here corrects and completes the benchmark.

### Complete live-frame shader diagnosis

A separate instrumented run uses `--trace-skia --endless-trace-buffer` and
captures only the first opening. Its trace covers the full action. The worst
raster frame is 189.072 ms; `shader_compile` spans overlap 149.852 ms of that
frame, or 79.26%. The FillRRect program takes 61.419 ms, including 53.328 ms
in driver linking. A separate FillRect compilation takes 79.899 ms.
These diagnostic timings include tracing overhead and are not substituted
for the untraced controls above.

An earlier live trace with the default ring buffer lost the beginning of
the action; its empty shader list cannot prove an absence of shader work.
It is retained as an incomplete diagnostic and excluded from attribution.
No warm-up or new public API was added; the maintainer explicitly excluded
both. Source hashes, exact host harnesses, raw JSON, native comparison PNGs,
complete/incomplete traces and command logs are retained in
`reports/ios26-no-warmup-2026-10-22/`, excluded from package publication.

## GPU compiler follow-up — 22 October 2026

**First-opening jank and all remaining raster peaks are not fixed.** No library
optimization from this batch is accepted or shipped. The production library
remains byte-for-byte identical to `a090295`; all 61 tracked library files are
retained in the evidence manifest. The shipped change fixes first-opening
measurement completeness and updates these results and the CHANGELOG.

Shaders are GPU programs. In these traces, names such as `FillRRectOp`,
`AtlasTextOp`, `CircularRRectOp` and `TextureOp` identify Skia drawing operations,
not shader files supplied by this package. Preparing a program for a new drawing
configuration can also happen during a later interaction, including dismissal.

### Complete control trace: the later peaks also compile programs

A control with the original library uses the same physical A8, Flutter 3.47.5,
profile Skia/OpenGL, semantics disabled and no picker warm-up. The diagnostic
fixture uses Turkish, opens and interacts with the picker, then repeats opening,
scrolling and closing. `--trace-skia --endless-trace-buffer` retains the entire
start/end interval of every recorded action. All nine intervals were checked
against the earliest/latest trace events. These instrumented numbers include
tracing overhead and are kept separate from untraced comparisons.

| Action | Worst raster, ms | Shader compilation in that frame, ms | Share |
| --- | ---: | ---: | ---: |
| First open | 190.486 | 153.022 | 80.33% |
| First scroll down | 49.946 | 30.587 | 61.24% |
| First scroll up | 40.358 | 28.305 | 70.13% |
| Search | 31.255 | 21.712 | 69.47% |
| Close | 91.380 | 75.234 | 82.33% |
| Repeated open | 35.005 | 19.836 | 56.67% |
| Repeated scroll | 19.840 | 0.000 | 0.00% |
| Repeated close | 21.215 | 0.000 | 0.00% |

The 91.380 ms dismissal frame contains a 75.234 ms `FillRRectOp` program
compilation. The worst first-opening frame contains 153.022 ms of compilation
out of 190.486 ms. An additional 78.586 ms `FillRectOp` compilation occurs during
the launch-button interaction in a separate frame. Limiting image snapshots
cannot remove these program compilations by itself.

A separate path-background prototype retains the original clips but replaces
the background fill with explicit conics. It adds a 33.003 ms `AAConvexPathOp`
compilation without removing the 60.839 ms `FillRRectOp` compilation. Its traced
first-opening raster reaches 224.893 ms. It is rejected; the control trace above
comes from the unchanged renderer, not this prototype.

### Untraced experiments on the same A8

All rows below retain the original native flag glyphs. Cells are observed maxima
in the first en open action; UI/raster/queue/total maxima can belong to different
frames. Complete action time includes test settling/polling and is not physical
presentation latency. Only en is the first picker in a process; tr/ru follow it.
No OS/driver cache reset is claimed.

| Run | Protocol | UI max, ms | Raster max, ms | Queue max, ms | Total max, ms | Action, ms |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Control 1 | 2 | 43.734 | 192.765 | 163.067 | 291.485 | 690.604 |
| Control 2 | 2 | 34.686 | 183.719 | 152.048 | 280.413 | 691.369 |
| Split background + uniform row clips | 2 | 36.070 | 165.331 | 143.374 | 252.520 | 676.051 |
| Split background, original rows | 2 | 36.774 | 163.167 | 137.313 | 257.919 | 685.448 |
| Rounded background repaint | 2 | 34.658 | 208.090 | 189.934 | 299.299 | 682.593 |
| One snapshot per UI frame | 2 | 42.101 | 153.885 | 138.115 | 258.408 | 686.660 |
| One snapshot, repeat | 2 | 34.646 | 181.765 | 165.533 | 275.607 | 680.060 |
| One asynchronous GPU conversion | 2 | 35.939 | 182.102 | 181.117 | 274.424 | 684.907 |
| Protocol 3 control, original renderer | 3 | 38.140 | 189.302 | 161.048 | 284.410 | 678.590 |
| Protocol 3 guarded background proposal | 3 | 32.900 | 160.919 | 134.547 | 257.352 | 675.331 |

The one-image result did not reproduce: its repeat returned to 181.765 ms,
and a later raster peak reached 94.933 ms. The asynchronous conversion prototype
also leaves a later peak of 92.317 ms. Neither is accepted. Repainting the rounded
background regresses cold raster latency to 208.090 ms and still changes corner
pixels. None of these is substituted for a solved rendering problem.

The guarded background proposal reduces first-opening raster from 189.302 to
160.919 ms (15.0%) and maximum total span from 284.410 to 257.352 ms (9.5%) in the
protocol 3 pair. The complete open action changes by less than 1%. Repeated-cycle
SDK raster maxima are en/tr/ru 45.861/100.340/44.769 ms for the control and
67.179/39.791/49.226 ms for the proposal. These are one pair of runs; the proposal
does not establish elimination of all later peaks. It remains unapplied pending
a decision on its corner antialiasing difference and further validation.

### Native appearance and the unapplied proposal

Four native PixelCopy captures compare the actual modal route, light/dark and
partial/full height, including several flags, search/close controls and a selected
badge. The initial split-background candidate changes 132–266 pixels per
1080×2175 image, confined to the antialiased upper corners (maximum channel delta
15/255). All other pixels, including flags, countries and controls, match.
The guarded prototype reproduces the same four pixel comparisons.
The rounded-background repaint attempt also differs at those corners and does
not meet the performance gate.

The guarded proposal keeps the original row clips, flags, selection badge and
sticky-list implementation. It is limited to Android with an opaque iOS 26
background, the stock search header, sufficient inset/size and no custom
`surfaceBuilder`; other configurations keep the original rounded shell.
It is stored as `guarded-split-unapplied.patch` under the excluded evidence
folder and is not part of the package or this PR's library diff.

### Protocol 3: drain the first-opening timing batch

Protocol 2 could remove its first-opening callback before the final batch arrived.
For example, the second control exported only eleven first-opening samples.
Protocol 3 waits 1100 ms after the action before removing the callback, as the
main-cycle recorder already does. The action start/end boundaries remain inside
`open()` and exclude that wait. The report records `first_open_timing_flush_ms`;
raw samples outside the action remain available. This wait performs no synthetic
picker rendering or pre-opening preparation.

The protocol 3 control retains first-opening frames up to 2.374/2.645/5.153 ms
before the end of the en/tr/ru action windows. Its raw timing callbacks also
include preparation/flush frames, which must not be treated as action frames.
SDK first-opening summaries include the added flush interval; the named action
window does not. The interval before the repeated cycles also changes, so SDK
percentiles from protocols 2 and 3 must not be compared as an identical workload.
Protocol 2 first-opening rows describe the observed subset, not a guaranteed
complete action-window percentile population.

[ios26-compiler-frame-summary.csv](ios26-compiler-frame-summary.csv) retains
observed action-window UI/raster/queue/total p90/max values, complete action
durations and protocol/flush metadata. `named_phases` combines the three measured
interaction cycles, excluding idle/flush intervals. SDK summaries remain in the
raw JSON and are not mixed into those CSV rows. Percentiles use the sorted
sample at `ceil((count - 1) * .9)`.

Raw JSON, complete control/prototype traces, source snapshots, source hashes,
commands, logs, modal PNG comparisons and the unapplied proposal are retained
in `reports/ios26-compiler-2026-10-22/`, excluded from publication. No shader
warm-up or supported public API change is included.

## Opaque Android sheet background — 22–23 October 2026

The accepted implementation paints the opaque iOS 26 modal background once.
This path is used with the stock search header.
It draws a uniform rounded rectangle whose lower corners start below the
sheet, with a separate rectangular clip for the content. The original row
clips, native emoji renderer, image-cache budget, selection badges and sticky
list are retained. The stock header's inset keeps its content inside the upper
corners. Custom surfaces, translucent backgrounds, small padding, oversized
icons and insufficient space retain the original rounded shell. Other platforms
also retain the original shell.

The Android shell keeps the same widget ancestry when its layout/theme changes,
preserving the search and scroll state. Its content widgets are reused across
draggable-height changes. No preliminary shader preparation, delayed loading or
supported public API change is introduced.
The background uses `CustomPaint` with a color-based `shouldRepaint`;
[Plugfox's canvas rendering guide](https://plugfox.dev/high-performance-canvas-rendering/)
discusses the repaint and layer trade-offs behind this approach.

### Controlled device measurements

Two control/candidate pairs ran on the same physical Galaxy A8 SM-A530F,
Android 9/API 28, DPR 3, Flutter 3.47.5/Dart 3.13.4, profile Skia/OpenGL and
semantics disabled. Protocol 4 retains protocol 3's first-opening timing drain
and adds a 150 ms held-and-cancelled country-row press to each repeated cycle.
The caller, three locales, three cycles and other actions are unchanged.
The second pair reuses the exact APKs in fresh processes. No OS/driver cache
reset is claimed. Only en is the first picker in a process; tr and ru follow it.

Cells below are maxima within the first en opening action, in milliseconds.
UI, raster, queue and total maxima can belong to different frames. Action time
includes animation/test settling; total span ends at raster finish and does not
measure physical presentation latency.

| Run | UI | Raster | Queue | Total | Complete action |
| --- | ---: | ---: | ---: | ---: | ---: |
| Control 1 | 53.086 | 157.830 | 142.885 | 264.369 | 685.040 |
| Single background 1 | 41.338 | 136.190 | 120.915 | 240.667 | 690.811 |
| Control 2 | 42.836 | 155.693 | 153.144 | 257.109 | 685.802 |
| Single background 2 | 39.144 | 144.416 | 124.280 | 244.489 | 685.249 |

The average of these two observed raster maxima decreases from 156.762 to
140.303 ms (10.5%); the average maximum total span decreases from 260.739 to
242.578 ms (7.0%). Complete opening time remains about 685–691 ms. These two
pairs establish an improvement on this A8; they do not establish a universal
cross-device gain or a 16.7 ms cold-frame budget.

In the en repeated cycles, closing raster maxima are 94.372/26.051 ms for
the controls and 11.534/12.523 ms with the single background. First row-press
spikes remain: en press maxima are 77.851/80.286 ms versus 77.024/77.188 ms.
Cold scroll/search work also remains. Per-locale, per-action frame counts,
percentiles, maxima, budget overruns and complete action times are recorded in
[ios26-sheet-background-frame-summary.csv](ios26-sheet-background-frame-summary.csv).
The CSV uses named action windows; it does not mix their percentiles with SDK
watch windows or earlier protocol versions. The setup close between the first
opening and repeated-cycle windows is outside these windows.

### Edge quality and native pixels

Four modal PixelCopy comparisons exercise light/dark themes at full height
and the partial detent (including a fractional physical top of 808.05 px).
The single-fill drawing primitive is compared with the unchanged renderer
and an 8×/16× supersampled reference of the intended 38 logical-pixel radius.
The 8×/16× reference difference is below 0.00187 coverage. Errors below are
absolute RGB-channel differences on the boundary band, on a 0–255 scale.
The reference uses component-wise source-over composition against the captured
background in screenshot RGB space.

| State | Mean error before → after | Maximum error before → after | Improved pixels | Worsened pixels | Changes outside boundary |
| --- | ---: | ---: | ---: | ---: | ---: |
| Light, partial | 2.827 → 0.221 | 26.171 → 2.863 | 1244 | 0 | 0 |
| Light, full | 2.867 → 0.176 | 25.873 → 2.698 | 385 | 0 | 0 |
| Dark, partial | 0.657 → 0.162 | 6.556 → 0.953 | 1230 | 0 | 0 |
| Dark, full | 0.658 → 0.060 | 6.583 → 0.861 | 366 | 0 | 0 |

Flags, rows, controls and selection badges match outside the improved boundary.
The stable-shell implementation was then measured in the two pairs above.
A final combined screenshot rerun of that implementation and an optional
pressed-state comparison could not finish after the A8 disconnected from ADB.
Those final captures remain pending; the earlier four primitive comparisons
must not be presented as that unfinished rerun.

### Diagnosis and excluded changes

A separate stock-widget fragment trace isolates the shell: its 167.603 ms
raster frame overlaps 148.627 ms of shader compilation, including two
`FillRRectOp` programs of 84.423 and 54.565 ms. This is a diagnostic trace,
not a performance comparison with the untraced table above. The fragments
run sequentially, so a later fragment can reuse programs compiled by an earlier
one. It confirms substantial shell cost even without country data or flags.

An inset-content prototype reduced first raster to 122.984 ms, but changed
flag pixels by 1–3/255 and worsened some section edges. It is excluded.
Alternative path/circle search borders, section paints and rounded paths
either regress first opening or fail the appearance gate. A visibility check
for offscreen flag preparation gives 136.508 ms against 136.190/144.416 ms
for the accepted background, without a demonstrated additional gain; it is
also excluded. The production flag-cache implementation remains unchanged.

An isolated press experiment replaces only the default Android `InkSparkle`
in iOS 26 country rows with `NoSplash`, retaining the gray highlight and custom
splash factories. Its first en/tr row presses are 6.900/15.723 ms versus
77.024/88.678 ms with the unchanged effect. First opening and 40–58 ms later
peaks remain. This experiment removes transient white sparkles and therefore
changes pressed appearance; it remains outside the implementation pending
visual review and explicit approval. No caller-button effect is changed.

The accepted background passes the existing 6,221 tests and analysis, with
100% filtered line coverage (2309/2309). Unit/widget tests and coverage
exclusions are unchanged. Exact fixture sources, source/APK hashes, logs,
raw frames, native PNGs, quality calculations and rejected prototypes are
retained under `reports/ios26-edge-quality-2026-10-22/`, excluded from publishing.
