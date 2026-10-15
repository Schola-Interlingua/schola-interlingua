# Grammar content review — 2026-10-15

This is a focused review of the grammar reference and a new beginner workshop. It is not a full audit of every reading, vocabulary translation, lesson recording or exercise in the course.

## Official references

The source is the grammar published by the Union Mundial pro Interlingua, translated by Selahattin Kayalar (2005), hosted on interlingua.com. New notes, examples and quizzes are original Schola teaching material; they are not copied chapters or an official UMI course.

| Topic / correction | Reference |
| --- | --- |
| Definite article; `a + le → al`, `de + le → del` | [Articulo definite, §17](https://www.interlingua.com/grammatica/grammatica/articulo-definite/) |
| `un` before nouns; no gender agreement | [Articulo indefinite, §19](https://www.interlingua.com/grammatica/grammatica/articulo-indefinite/) |
| Plurals after vowels/consonants, `roc → roches`; borrowed-word exceptions | [Plurales, §25](https://www.interlingua.com/grammatica/grammatica/plurales/) |
| Adjectives with nouns remain invariable; normal and alternative positions | [Adjectivos, §§32–33](https://www.interlingua.com/grammatica/grammatica/adjectivos/) |
| Present retains the infinitive vowel: `parla / vide / audi`; short `es / ha / va` | [Tempore presente, §§99–101](https://www.interlingua.com/grammatica/grammatica/tempore-presente/) |
| Past: remove final `r`, add `va` | [Tempore passate, §102](https://www.interlingua.com/grammatica/grammatica/tempore-passate/) |
| Future and conditional: add `a / ea` to the complete infinitive; stress without written accent | [Tempore futur e conditional, §§107–108](https://www.interlingua.com/grammatica/grammatica/tempore-futur-e-conditional/) |
| Regular participles; `-iente` for `audir`, with specified `-er` exceptions | [Participio presente, §93](https://www.interlingua.com/grammatica/grammatica/participio-presente/), [Participio passate, §§95–98](https://www.interlingua.com/grammatica/grammatica/participio-passate/) |
| Object forms and forms after prepositions | [Pronomines personal, §§62–63](https://www.interlingua.com/grammatica/grammatica/pronomines-personal/) |
| `non` before a preverbal object pronoun; regular adverb formation and inserted `a` after `c` | [Adverbios, §§45–47, 53](https://www.interlingua.com/grammatica/grammatica/adverbios/) |
| Comparative, equality and relative superlative | [Comparation de adjectivos, §§34–36](https://www.interlingua.com/grammatica/grammatica/comparation-de-adjectivos/) |
| Distinguish invariable demonstrative adjectives from pronoun forms | [Demonstrativos, §§78–79](https://www.interlingua.com/grammatica/grammatica/demonstrativos/) |

## Implemented

- Eight topics with short Interlingua explanations, 25 selectable visual examples and 16 multiple-choice questions. Wrong answers receive a rule explanation and permit retry; correct answers unlock the next question. Progress is explicitly for the current session and survives topic switches while the workshop remains mounted. Reset affects only that topic. It is not written to vocabulary SRS or remote study progress.
- Course entry and lesson grammar links open the existing `/appendix/grammatica` route. Other appendices retain their original view. The corrected 14-section reference remains available in an expandable section.
- The active `assets/data/content.json` reference removes the misleading universal `-a` present rule, explains tense formation from the appropriate base, clarifies participles/adverbs/pronouns, and adds contractions and the `-c` plural. Matching bundled legacy notes were updated where applicable.
- Lesson 3 now has three grammar notes tied to its existing text. Recorded passages and audio files were not rewritten.
- The earlier header-logo adjustment is recorded in a separate commit; it is unrelated to this content change.

## Checks

Automated coverage walks every topic, example, wrong answer, correct answer, completion and reset; revisiting topics must preserve progress without double counting. Layout checks cover 390×844 light and 320×640 dark. Asset-loading coverage checks that the effective reference contains `vider → vide` and `audir → audi`, and that lesson 3's notes load.

The new content shares the Flutter code used by web, iOS and Android. Native-device verification and publication are not part of this local change.

Final validation: all 23 tests passed; `flutter analyze --no-pub` reported no issues; `flutter build web --release --no-pub` succeeded (existing flutter_tts Wasm dry-run warnings remain). Integrated-browser checks covered the course entry, switching topics/examples, wrong/correct answers, advancing questions, opening/closing the reference, and a narrow 389×843 CSS viewport. The corrected conjugation reference was visually confirmed after bypassing a stale local browser cache; temporary cache and viewport overrides were restored. The final captured console log contained no warnings/errors. Evidence: `build/browser-qa/grammar-explanation-practice.png` and `build/browser-qa/grammar-mobile-practice.png`. At validation time, the local browser remained on the workshop; nothing had been merged, pushed or published.
