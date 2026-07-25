# Reader inline translation QA

## Reference

- Source: user-provided mobile screenshot with `Le homine parla`.
- Target behavior: the pasted text stays in one editable field; every recognized word is highlighted in that same text; tapping a highlighted word opens its translation and favorite action.
- Removed elements: the floating `Texto in Interlingua` label, the separate translation-language row, and the duplicated interactive reading preview.

## Verification

- Web preview: `Le homine parla` renders directly inside the editable field with all three words using the same blue dotted underline and no floating label.
- Automated widget coverage confirms `homine → hombre`, `parla → hablar / to speak`, inline highlighting for all three words, unknown-word behavior, language selection, translation popup, favorite toggle, and clear action.
- Vocabulary normalization now preserves Interlingua accented forms, preventing an empty conjugated entry such as `parlarà` from overwriting the `parlar` infinitive.
- `flutter analyze`: passed.
- Deck detail on iPhone 17 Pro: the compact header exposes `Quiz rapide` without overflow; the quiz shows the deck name, card count, prompt, and answer choices.
- `flutter test`: 13 tests passed, including shared lesson/deck SRS progress.
- `flutter build web`: passed.
- Browser console: no errors or warnings after the reader interaction.
- Mobile runtime: no Flutter exceptions during the reader interaction.

## Visual comparison

- Layout and behavior match the latest reference intent: there is one clean text surface without a floating label, duplicated text, or `Traduction in Español` row.
- `Le`, `homine`, and `parla` share the app's established blue dotted underline, and their translation popup keeps the established favorite control.
- No high- or medium-severity visual mismatches remain.

final result: passed
