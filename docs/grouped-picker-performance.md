# Grouped picker performance

Measured on 14 and 16 October 2026 with Flutter 3.47.5 / Dart 3.13.4 in profile
mode on a physical Samsung Galaxy A8 (SM-A530F), Android 9, ARM64.
The benchmark uses the public `showCountryPicker` API.

The subsequent flag raster-cache comparison, native screenshots, first-opening
limits and completed full-latency check are documented in
[iOS 26 picker raster performance](ios26-raster-performance.md).

## Virtualized grouped list — 16 October 2026

Before: `a3db0ca7031edb8d85df86e4fa2d11f22edbe1a4`. After:
`35a917471b126b94b9422f626e010031af6184a6`. Measured again on the same physical
Galaxy A8, pinned Flutter 3.47.5, profile mode. Both sides use the same six
style/locale scenarios, one warm-up and three measured cycles, with
`BENCHMARK_SEMANTICS=false` explicitly set. These values are a new comparison;
they are separate from the 14 October measurements below.

The grouped paths now use one lazy delegate for all section headers and rows.
The pinned header uses actual child offsets from that list and is pushed out
by the next header. Variable row heights, existing country/flag widgets,
section padding/rounding and 26/36 px header heights are retained. The grouping
algorithm itself is unchanged.

All table cells show **before → after**. Mounted rows include World Wide and
use `skipOffstage:false`; visible rows stay at 11 classic / 8 ios26.

| Scenario | Mounted rows | UI p90, ms | UI maximum, ms | Raster p90, ms |
| --- | ---: | ---: | ---: | ---: |
| classic / en | 39 → 15 | 24.674 → 17.832 | 195.069 → 99.073 | 13.433 → 15.095 |
| classic / tr | 38 → 15 | 22.736 → 23.632 | 165.693 → 80.484 | 14.957 → 15.907 |
| classic / ru | 41 → 15 | 25.783 → 23.601 | 173.412 → 74.747 | 19.403 → 17.679 |
| ios26 / en | 35 → 11 | 19.874 → 10.981 | 189.894 → 62.938 | 16.194 → 15.953 |
| ios26 / tr | 34 → 11 | 17.950 → 10.460 | 188.387 → 88.408 | 15.731 → 16.353 |
| ios26 / ru | 37 → 11 | 14.660 → 9.542 | 191.416 → 55.787 | 16.424 → 16.486 |

Phase UI maxima across the three Russian-locale cycles:

| Style | Open, ms | Clear search, ms | Scroll down, ms | Scroll up, ms |
| --- | ---: | ---: | ---: | ---: |
| classic | 138.064 → 70.591 | 173.412 → 74.747 | 148.462 → 70.319 | 65.782 → 63.020 |
| ios26 | 155.012 → 55.787 | 191.416 → 54.763 | 53.731 → 34.726 | 77.790 → 11.933 |

The fix substantially reduces mounted offscreen rows and the observed UI
spikes during opening and full-list restoration. Frames above 16 ms remain.
Whole-run improvement is not uniform: classic/tr UI p90 increases from
22.736 to 23.632 ms in this batch.
In particular, ios26 raster p90 remains near the frame budget; this change
does not establish a raster improvement. Flag rendering remains a separate
cost and is unchanged by this patch.

Exact full-run and phase values, frame counts and >16 ms counts for every
locale are in the CSV linked below.

Compared 48 before/after widget captures from the same phone at matching
verified scroll offsets: both styles × light/dark/RTL with text scale 1.8 ×
initial/pinned/handoff/next/reverse/search/empty/clear. 37/48 are pixel-exact;
the others differ by at most one channel value (out of 255) on antialiased
edges. Header positions, text, flags, spacing and rounded section geometry
match. The comparisons are at the same 720 × 1450 capture size. The harness
retries scrollOffsetCorrection until the requested offset is actually reached,
and asserts it before capturing, so estimated offscreen extents do not create
a false visual mismatch.

The generated host omits the consumer `cupertino_icons` dependency, so its
search/close glyphs use a fallback font on both revisions. These captures
verify country-list layout and sticky headers. The example declares that
dependency; its icon-font rendering is outside this comparison.

The new virtualization checks fail with the old library and pass with the fix.
Regression tests also check sticky push-out, reverse scrolling, header semantics,
hit testing, empty/restored search and selecting the last country. `make ci`
passes 6,210 tests, with 100% line coverage after the existing localization
filter and narrow ignores for unreachable lifecycle paths. Publish dry-run
reports zero warnings.

This is one before/after batch with three cycles per scenario on one device.
It establishes the reduction in unnecessary row construction and the observed
UI spikes here, not universal device/FPS results. An interrupted run was
discarded. Raw reports, source hashes, exact harnesses, 48 paired images and
CI output are saved locally in `reports/picker-virtualization-2026-10-16/`.
The CSV is versioned as
[grouped-picker-virtualization-frame-timings.csv](grouped-picker-virtualization-frame-timings.csv).

## Scenario

Both picker styles run with English, Turkish and Russian localizations.
The sheet is expanded, grouping/search/phone codes are enabled, World Wide
is enabled and `RU`, `US`, `FR` are favorites. The 241-country dataset gives
245 entries including the leading World Wide option and repeated favorites.

Each scenario warms up by opening/closing once, then measures three cycles:
open, fling down and back, search for `a` (`р` in Russian), search with no
results, clear the search, close. Search uses the actual search controller
without measuring the native keyboard. Assertions check visible country
buttons, removal of empty groups and restoration after clearing search.

Frame measurements use Flutter's `watchPerformance` and
`FrameTimingSummarizer`. UI/build and raster times are separate. Counts
above 16 ms use the SDK's fixed budget; they are not a measurement of FPS
or of frames dropped by the display.

## Whole-picker frames before the fallback fix

Source: `5523a6b271955ad45fbadcb9c8c450e466dff30d`. Removing Claude commit
trailers produced `13218a1934b91e357b9cee312a3c2d129f27b9ee` with the same tree.

| Scenario | Frames | UI p90, ms | Raster p90, ms | UI >16 ms | Raster >16 ms |
| --- | ---: | ---: | ---: | ---: | ---: |
| classic / en | 400 | 18.335 | 11.576 | 44 | 20 |
| classic / tr | 395 | 20.674 | 12.903 | 45 | 17 |
| classic / ru | 390 | 18.856 | 12.973 | 44 | 25 |
| ios26 / en | 379 | 11.734 | 17.319 | 32 | 43 |
| ios26 / tr | 386 | 11.108 | 15.746 | 28 | 35 |
| ios26 / ru | 380 | 11.467 | 17.678 | 32 | 49 |

These include opening/closing animations, scrolling and search rebuilds.
They do not isolate grouping. The baseline Turkish run omitted Croatia
because its translation is missing and `nameLocalized` remained empty.
The approved fallback fix fills the original name before sorting/grouping.
Three regression tests establish that the old implementation loses the
country in both styles and sorts it before translated names.

Exact frame summary values are in
[grouped-picker-frame-timings.csv](grouped-picker-frame-timings.csv).

## Whole-picker frames after the fallback fix

Source: `0bcc4bb466b73b26504177375d41cde4f4357696`, without the temporary
Stopwatch. The same six scenarios passed. The picker now retains Croatia
in Turkish; sorting/grouping use the original name when a translation is absent.

| Scenario | Frames | UI p90, ms | Raster p90, ms | UI >16 ms | Raster >16 ms |
| --- | ---: | ---: | ---: | ---: | ---: |
| classic / en | 399 | 18.585 | 10.845 | 44 | 7 |
| classic / tr | 398 | 14.902 | 12.543 | 39 | 22 |
| classic / ru | 388 | 19.977 | 13.675 | 46 | 28 |
| ios26 / en | 383 | 13.333 | 16.369 | 32 | 43 |
| ios26 / tr | 380 | 13.673 | 16.594 | 34 | 43 |
| ios26 / ru | 380 | 11.837 | 15.933 | 30 | 38 |

Both runs use the same device and fixture, but represent one sample each.
The Turkish data also changed by restoring the missing country. Differences
are not evidence of a performance improvement: these fixes correct review
style and missing-translation behavior. Budget overruns occur in both runs.

## Grouping implementation

Compared with `tetradka_app/packages/ui/lib/src/widgets/grouped_sliver_list.dart`:

- Both implementations make one pass into an insertion-ordered map and
  merge equal keys even when their entries are not adjacent.
- Both cache by list identity and construct rows lazily through a sliver
  list builder.
- The picker additionally keeps World Wide and favorites in a leading
  section without a letter header. Favorites also appear in the main list
  when phone codes are enabled.
- Paging support from the reference widget is unnecessary for the bundled
  241-country list. No extra list copy/sort was added to the grouping method.

The grouping algorithm is O(n) time and O(n) storage for country references.
The controller's localization/sorting and widget painting are separate costs.

## Isolated grouping after the fallback fix

A separate profile run added a temporary `Stopwatch` around the actual
`_buildGroups` method, stopped it before logging, and counted output entries
outside the timed region. No copy of the algorithm was benchmarked. The
production code matches `0bcc4bb466b73b26504177375d41cde4f4357696`; only the
temporary probe differed. The source was restored byte-for-byte afterwards.
Frame results from this instrumented run are excluded from comparisons.

| Scenario | Full-list calls | Median, ms | Maximum, ms |
| --- | ---: | ---: | ---: |
| classic / en | 7 | 0.377 | 0.526 |
| classic / tr | 7 | 0.485 | 0.563 |
| classic / ru | 7 | 0.737 | 1.329 |
| ios26 / en | 7 | 0.357 | 1.366 |
| ios26 / tr | 7 | 0.518 | 2.243 |
| ios26 / ru | 7 | 0.921 | 1.010 |

The seven full-list calls per scenario include the warm-up, three opens and
three search resets. All 42 full-list calls preserved 245/245 entries,
including Croatia in Turkish. All partial/empty queries also preserved
their input counts. The 78 individual samples, including search results,
are in [grouped-picker-grouping-samples.csv](grouped-picker-grouping-samples.csv).

These are wall-clock durations from one device and a small sample, not
statistical evidence of a speedup. Grouping alone did not exceed 2.243 ms
in this run; the whole-picker frame results cannot be attributed to it.
The frame budget overruns remain a limitation on this older device.

## Reproduction

The benchmark sources are
`example/integration_test/grouped_picker_performance_test.dart` and
`example/test_driver/grouped_picker_performance_driver.dart`. They require
the Flutter SDK's `integration_test` development dependency, already present
in the example.

From a configured example native host:

```bash
COUNTRY_PICKER_BENCH_OUTPUT=build/grouped-picker-performance.json \
  mise exec -- flutter drive --profile --no-dds \
  --driver=test_driver/grouped_picker_performance_driver.dart \
  --target=integration_test/grouped_picker_performance_test.dart \
  --dart-define=BENCHMARK_SEMANTICS=false \
  --dart-define=BENCHMARK_REVISION="$(git rev-parse HEAD)" \
  -d DEVICE_ID
```

For these measurements, a fresh temporary Android host was generated with
`mise exec -- flutter create --platforms=android,macos`, depended on this
checkout by path, and received the two benchmark files. Copying the repository
`mise.toml` / `mise.lock` and trusting that copied configuration ensured
Flutter 3.47.5 was used. No example platform files were changed.

A second host on Apple M1 Max / macOS 26.6.2 built successfully, but its run
stalled inside the integration test and produced no report. It is excluded
from the results. These measurements do not establish iOS, Windows, desktop
or cross-device performance.
