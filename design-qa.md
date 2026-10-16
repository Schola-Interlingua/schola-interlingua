# Course path design QA

final result: passed

## Scope and references

Adapt the user-provided Duolingo screenshot to Schola's existing Flutter course. The requested surfaces are a compact winding path, circular topic controls and level headers labelled Nivello. This is a structural adaptation, preserving Schola's dark blue palette, typography, icons and existing course data. Chests, rewards and locked lessons are intentionally excluded.

The original reference is attached to the conversation. Before/after runtime captures are in `flutter_app/build/browser-qa/` (local build artifacts):

- `course-before-path.png`: original large cards.
- `course-path-desktop.png`: final course at the normal browser viewport, approximately 719 × 1005.
- `course-comparison.png`: browser-rendered side-by-side comparison.
- `course-path-mobile.png`: temporary narrow viewport capture. The browser override requested 390 × 844 but reported an actual DOM viewport of 582 × 1260, with white screenshot padding. This capture is not evidence of a true 390px browser layout. Exact narrow sizes are covered by Flutter widget tests below. The viewport override was reset.

## Visual review

1. Layout: removed nested level/section cards and large tile grid. One centered path, capped at 480px, with small circular controls.
2. Hierarchy: each of six levels has a Nivello banner; existing category labels appear as slim dividers.
3. Typography: original topic titles retained below each circle, up to three lines; full titles remain available to accessibility and tooltips.
4. Color and icons: existing Schola theme and Material topic icons retained. Completed topics show checks; upcoming topics stay accessible.
5. Rhythm and density: circles follow a continuous horizontal wave through each level. At the normal viewport five complete topics are visible instead of the two large cards in the original capture. Deck access is one compact row.

An initial row height caused overflow on long titles. Increased to 116px and reran the full suite successfully. Final rendered comparison shows legible labels and no visible overlap with adjacent nodes.

## Verification

- `flutter test --no-pub`: 37 tests passed.
- `flutter analyze --no-pub`: no issues.
- `flutter build web --release --no-pub`: passed.
- New widget tests cover every course item at 320px in light and dark themes, compact circle sizes and absence of layout exceptions.
- Route tests at 390 × 844 cover grammar, recorded lessons, vocabulary, readings and the last-level topic; completion accessibility label verified.
- In-app browser: clicked Articulos, Lection 1, Basico1 and Decks de vocabulario from the path. Correct content opened and course navigation returned successfully.
- Lection 1 audio playback advanced from 0:00 to 0:07 of 0:21.
- Browser warning/error log check returned no entries.
- Final local course tab remains open. No merge, push or deployment performed.

Native iOS and Android builds were not run; the changed course widget is shared by those targets and web.

## Level summary follow-up

Each Nivello header now opens a compact dialog with three learning goals specific to that level, based on its bundled grammar, vocabulary, recordings and readings. The header uses a book icon to indicate the overview. Continuar dismisses it without changing the course position.

Validation: 38 tests passed, analyzer clean and release web build passed. A new test opens and closes all six summaries at 320px. Browser QA opened Nivello 1 by clicking its header, verified its three goals visually and dismissed it with Continuar. No warning/error log entries. Screenshot: `flutter_app/build/browser-qa/level-summary.png`. Local only; no merge or push.

## Final course action follow-up

Removed the course-wide completion button at the user's request. Per-lesson completion controls are unchanged. Browser QA confirmed the course now ends after Technologia, with no manual whole-course completion action. Screenshot: `flutter_app/build/browser-qa/course-end.png`. The three course path tests passed; analyzer and release web build passed on this final code.

Merge and push to main authorized by the user after local review.

## Guided learning sessions (local branch)

Implemented on `codex/guided-learning-sessions`; not merged or pushed.

- Course lesson/vocabulary nodes now open `/session/:slug`. Existing `/lesson/:slug` pages remain complete reference views, with vocabulary tables, classic review, quizzes and all grammar preserved.
- A short session shows one activity at a time: original text/audio or selected vocabulary, one existing interactive grammar topic, and up to six existing cloze/dictation exercises. Both modes alternate when available.
- Home and course have Continue. Activity index, draft answer, exercise run IDs and the full session plan persist in local preferences, separately for each lesson. Attempt/aid history reconstructs exercise state after reload. Runtime page storage preserves the course scroll position on return.
- Errors and help create a fresh retry after two other exercises when possible. At most one extra retry per exercise per session prevents endless loops. Unresolved items remain eligible in later sessions; up to two due reviews from previously practiced sources can join a new session.
- Independent correct answers schedule review after 1, 3, then 7 days, based on consecutive clean recalls. A later mistake resets that interval. Normal audio replay is not penalized. Existing vocabulary SRS data is preserved.
- At the end of the session the existing lesson completion mechanism updates the course circle. Continue then suggests the first unfinished lesson/vocabulary session. Reference material and standalone grammar/readings remain freely accessible.

Validation on final source:

- `flutter analyze --no-pub`: no issues.
- `flutter test --no-pub`: 42 tests passed. New tests cover due selection, spaced intervals, delayed/capped retries, multi-lesson persistence, draft restoration, Continue routing and a full guided session with simulated audio. Existing reference, grammar and SRS tests pass.
- `flutter build web --release --no-pub`: passed (existing optional flutter_tts Wasm dry-run warnings remain; JS release succeeded).
- Browser at approximately 616 × 1005: completed Lection 1 end to end. Recorded audio advanced to 0:08 / 0:21. Submitted an incorrect cloze answer, paused, returned through Home Continue and reloaded the page: the answer and activity were retained. Corrected it, completed other exercises, and verified the fresh delayed retry was empty and then accepted a clean answer.
- Browser dictation audio played successfully. Reveal was recorded and its dictation returned for a fresh independent answer. A due exercise from an earlier source appeared as review. Finished the session and verified Lection 1 completed and Continue suggested Lection 2.
- Opened Basico1 from the path: vocabulary came from the existing JSON. Opened its full reference view and returned. Pausing restored the course position near Basico1. No browser warning/error entries at final check.
- Screenshot evidence (local ignored build artifacts): `guided-session-retry.png`, `guided-session-complete.png`, `guided-course-continue.png` under `flutter_app/build/browser-qa/`.
- Narrow layouts are covered at 320/390px in widget tests. Native iOS/Android builds were not run; the new code uses the same shared Flutter widgets and local storage APIs.

The old local server had stopped. Restarted it bound to 127.0.0.1:8765. The browser initially rejected a stale tab URL; testing resumed after the user reopened the running local page. Added temporary cache-busting query strings to generated build files only so the preview loaded the new JavaScript; tracked web bootstrap files are unchanged.

## Parts within a single course circle

Same local branch, no merge or push. Lesson and vocabulary nodes remain one circle per topic. A segmented outer ring and a compact completed/total counter show part progress. Existing standalone grammar/reading nodes remain single activities.

Parts now partition the bundled content deterministically: up to four existing exercises per part, all vocabulary terms assigned to an introduction, and each interactive grammar topic included in a part. Required exercises are not dropped by the adaptive review schedule. A due review from another source can be added; delayed retries remain capped. Part counts depend on actual content, not a fixed three-part template.

Each part has its own saved cursor and draft. Completing a part updates the ring once; the lesson check is awarded only after all parts finish. Clicking the circle opens the saved or next pending part. The Partes dialog allows revisiting a completed part while preserving another part's pending draft. Prior unpartitioned sessions with work in progress remain available as review; untouched starts switch to fixed parts. Existing legacy lesson-completion flags remain honored.

Final validation:

- 46 tests passed; analyzer clean; release web build passed. New tests cover full exercise/word/grammar coverage across the course, four-exercise bounds, idempotent part credit, reload persistence, completing all parts before marking a lesson complete, and preserving a pending draft while revisiting another part at 390px. Existing course layout tests include 320px/light/dark.
- Browser: completed Basico1 part 1 with the cloze and all three real dictation audios. The same circle became 1/7 with one green arc, while the topic stayed unfinished. Clicking it opened part 2; Continue also pointed to part 2/7.
- Browser: Partes displayed a check for part 1. Reopened part 1, returned to saved part 2, and paused. Reload confirmed the ring remained 1/7 and Continue still pointed to part 2/7. Warning/error log check returned no entries.
- Screenshots: `flutter_app/build/browser-qa/topic-parts-progress.png` and `topic-parts-menu.png` (ignored local artifacts). No native iOS/Android build was run.
