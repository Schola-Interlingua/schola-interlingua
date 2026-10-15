# Local browser QA — 2026-10-15

Tested the release build in `build/web`, served only on `127.0.0.1:8765`, primarily in the Codex integrated browser. No deployment or publication was performed.

## Verified through UI interactions

- Search for `parlar` returned Spanish translations; switching to English returned `to speak` and the related phrases. A nonexistent query displayed the empty state; clearing restored the home screen.
- Navigation between home, course, lessons 1 and 2, the `Mi familia` reading, grammar appendix, vocabulary practice, decks, deck quiz, games and settings worked.
- Browser back/forward and a reload of the grammar deep link restored content.
- Reading word translation opened a popup with `la familia`; clicking outside dismissed a popup.
- Lessons 1 and 2 loaded durations of 21 and 29 seconds. Play advanced the displayed position; pause held the position; resume continued. Seeking lesson 1 to 10 seconds and playing advanced to 15 seconds. Returning to lesson 1 loaded the correct content and reset its player.
- Vocabulary quiz correct answers highlighted green and advanced. Audio requests for `un_puera.wav`, `belle.wav` (deck review), and `tasca.wav` (game chip padding) returned HTTP 200. Clicking the underlined game word itself opens its translation; the surrounding chip triggers pronunciation.
- Dragging across `multo` highlighted the word and increased the word-search counter from 0 to 1.
- Light/dark themes and Spanish/English switching worked. Original Spanish/dark preferences were restored.
- Visual review covered the default integrated-browser width (748 px) and a narrow override (actual CSS width 485 px, height 1050 px). Search results, empty state, deck detail and bottom navigation fit the narrow view. The viewport override was reset.
- Browser console inspection returned no captured warnings or errors during the final checks.

## Limits and retained state

Audio verification used playback progress, UI state, successful asset responses and console inspection. Speaker output was not independently heard or recorded. This is a representative regression pass, not an exhaustive test of every lesson, sound file, device or authenticated synchronization flow. No accounts were signed into and no external chat messages were sent. Guest quiz/review actions created local test study state in this localhost browser session.

The local server and integrated-browser tab were intentionally left available for inspection, with lesson 1 stopped at its end. Evidence screenshots are in `build/browser-qa/lesson-audio.png` and `build/browser-qa/wordsearch.png` (local build artifacts, not published).
