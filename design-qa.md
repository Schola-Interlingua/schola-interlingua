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
