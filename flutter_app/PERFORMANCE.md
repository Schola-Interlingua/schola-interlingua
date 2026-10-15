# Performance changes — 2026-10-15

The Flutter source is shared by the native app and web build.

- Home vocabulary search now builds a language-specific normalized index only when needed. Empty input does no catalog work; repeated queries reuse the previous result. Vocabulary arrival and language changes invalidate the index. Only the eight visible results are returned.
- Matching, Spanish fallback, deduplication and ranking are compared against the previous algorithm across all 13 supported languages and an unknown-language fallback.
- Lesson, reading and appendix screens retain their loading future across rebuilds and replace it when the route slug changes. This avoids reparsing content and resetting the loading UI on theme/layout rebuilds.

## Local algorithm benchmark

From `flutter_app`, run `dart run tool/benchmark_vocab_search.dart`.

One local Dart VM run using the bundled 1,504 vocabulary entries and 700 mixed queries measured:

| Work | Time |
| --- | ---: |
| Index construction (once per language) | 10.35 ms |
| Previous algorithm | 11,064.86 ms |
| Indexed queries | 96.06 ms |

This is roughly 115x faster for the measured search workload after warmup. It is not an end-to-end app, browser, device or startup benchmark. Times vary by machine and runtime.

## Verification

Run `flutter test`, `flutter analyze`, and `flutter build web --release`.
The release JavaScript web build succeeds. Flutter's optional Wasm dry run reports existing JS interop incompatibilities in `flutter_tts`; this change does not enable Wasm. Native device profiling and store builds were not performed. The generated web build remains in `flutter_app/build/web`; it has not been copied into `public/` or deployed.
