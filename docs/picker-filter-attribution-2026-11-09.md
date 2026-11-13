# First-opening filter attribution and A8 close tint trials

Runtime baseline `4fc727e` on Flutter 3.47.5. All release-candidate timing runs use fresh processes and the stock engine. Diagnostic ablations change the picture and are analyzed separately.

## Galaxy A8

| Metric in ms | Current picker | Tint composed into blur | Tint through existing clip |
| --- | ---: | ---: | ---: |
| First-open raster peak | 429.717 | 356.016 | 357.191 |
| First-open total span peak | 598.148 | 510.580 | 520.895 |
| Reopen raster p95 | 26.227 | 28.286 | 31.726 |
| Drag raster p95 | 23.735 | 22.969 | 25.006 |
| Fling down raster p95 | 27.751 | 26.069 | 27.761 |
| Keyboard raster p95 | 24.101 | 24.767 | 25.821 |
| Close raster p95 | 35.444 | 35.675 | 41.476 |

Starting battery temperature was 25.5 °C for baseline, 25.0 °C for composed tint and 25.9 °C for clipped tint. Charge was 100% and USB power was on in all three. The engine, compiler, fixture and driver hashes matched. Each run completed and cleaned up the temporary app. The first peaks improved in these pairs, but the two candidates fail the combined raster and appearance requirements.

Composed tint changes the pixels inside the close controls by up to 4/255. Clipped tint changes 303–706 pixels per screenshot along control edges, also up to 4/255. Rows and flags are pixel-identical in all six states. The clipped tint regresses drag, reopen and close. The composed tint passed all 6,425 unit and widget tests.

[Frame statistics and run fingerprints](performance-data/picker-2026-11-06/nov09-filter-attribution.json).

## iPhone 7 Plus

The exact stock trace and the control with Dart scene markers recorded the same order and two long scopes. In the marked run, frame 11 passed five separable contributions, numbered 0 through 4. Within `SurfaceFrame::Encode`, the seven `saveLayer` scopes took 0.152, 74.391, 0.784, 0.880, 0.920, 0.501 and 27.062 ms. Total encode took 186.465 ms.

With the header filters disabled, five scopes disappear. The two remaining scopes take 0.182 and 37.840 ms, and encode takes 83.579 ms. With the stock control blurs disabled, the last scope disappears. The remaining scopes take 0.166, 79.810, 0.791, 0.739, 0.887 and 0.391 ms. This attributes the two peaks to the first progressive-header backdrop and the close button painted after the header, respectively. A timeline RPC overlaps the no-controls frame, so that trace is used for scope count and order. These scopes measure wall time around filter work. They do not identify an individual Metal pipeline or measure GPU execution time.

In the exact stock trace, both `FragmentProgram::initFromAsset` spans completed over 170 ms before the slow raster frame. The synchronous Dart asset-loading spans are separate from the observed raster cost.

In a fourth run, the first contribution copied the source instead of computing the original contribution. It used the same shader program, backdrop key and scene order. The first header scope still took 79.122 ms. The five passes share a backdrop key. On its first use, Impeller calls `FlipBackdrop` and stores the input texture for the following passes. The same scope renders the runtime effect. The identity trial rules out the original contribution arithmetic as the primary cost of this frame. Stock instrumentation does not time the texture capture, render-target setup and pipeline creation separately. [Pinned Impeller canvas implementation](https://github.com/flutter/flutter/blob/af7e796e161ae0bb1ff0758c71a7105418bd9ded/engine/src/flutter/impeller/display_list/canvas.cc#L1780-L1848).

[Ordered scope durations, scene markers and raw trace hashes](performance-data/picker-2026-11-06/nov09-filter-attribution.json).

### Specialized first contribution

The candidate compiled the original first contribution formula into a smaller shader program. It retained the other passes and the shared backdrop. The matched control and candidate started at 31.9 and 32.2 °C, both with 100% charge, USB power and charging inactive. The earlier candidate run had a stale temperature reading and remains exploratory.

| Metric in ms | Current picker | Specialized first contribution |
| --- | ---: | ---: |
| First-open raster peak | 199.657 | 232.840 |
| First-open total span peak | 371.349 | 462.970 |
| First-open action window | 721.507 | 871.092 |
| Drag raster p95 | 141.484 | 138.404 |
| Keyboard raster p95 | 140.021 | 150.943 |

All six native screenshot pairs matched below the system status bar. The 6,425 unit and widget tests passed and the analyzer reported no issues. The candidate regressed first opening and was excluded. Both matched runs used fresh processes without warmup and restored the installed-app inventory. [Phase statistics and run fingerprints](performance-data/picker-2026-11-06/nov09-filter-attribution.json).
