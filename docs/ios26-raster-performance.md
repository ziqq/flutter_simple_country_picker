# iOS 26 picker raster performance

Measured on 16 and 21 October 2026 on the same physical Samsung Galaxy A8
(SM-A530F), Android 9, ARM64, Flutter 3.47.5 / Dart 3.13.4, profile mode,
Skia/OpenGL. The baseline already includes country-row virtualization.

Before: `d5d2a30eb2b063267a89bc96efde84d1082cc346`. After:
`320836b714f16ad0c15a9085510d6b1972aa056d`.

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

No warm-up or new public API is included in `2c3acca`. Adding an explicit
opt-in API requires a separate decision about preparation time and app
integration. The baseline/candidate tables above include no hidden warm-up.
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
