# Visual polish — 2026-10-15

Local branch: `codex/visual-polish`.

- Keep the blue identity while replacing glowing background orbs and blurred cards with quiet backgrounds, opaque surfaces and subtle borders/shadows.
- Use smaller headings, consistent corner radii and responsive default card padding (20 px below 600 px; 28 px otherwise). Explicit screen padding is preserved.
- Simplify the header and reserve room for the existing chat launcher.
- Center the bottom navigation with a maximum width of 620 px. Remove borders/backgrounds from inactive destinations and retain a clear blue selected state.
- Improve dark-theme primary button contrast and light-theme course tile contrast.
- Keep local Material surfaces for Ink rendering so opaque cards do not cover course tiles or interaction effects.

Validation: 19 existing tests pass; Flutter analysis reports no issues. The release JavaScript web build succeeds with the previously known flutter_tts Wasm dry-run warning. Browser review includes light/dark themes, search and navigation, and actual CSS viewports of 390×844 and 1440×900. Native device visual verification was not performed. No deployment or push.
