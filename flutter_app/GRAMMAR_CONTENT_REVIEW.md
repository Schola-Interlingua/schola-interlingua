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

## Lesson integration refinement — 2026-10-15

Following the user's feedback, grammar now lives inside each of the ten recorded lessons, directly after the reading and before vocabulary/review practice. One compact `Grammatica` card shows the lesson's own notes, grouped into visible topic chips. Selecting an example changes the model phrase and a short explanation; there are no added grammar quizzes, session counters or workshop-navigation buttons in these cards. All existing `grammarBullets` remain covered exactly once. The larger appendix workshop remains an optional reference, and its extra prominent course-entry button was removed.

The new local examples are in `lib/src/data/lesson_grammar_topics.dart`. Reflexive forms and placement were checked against [UMI §§66–70](https://www.interlingua.com/grammatica/grammatica/reflexivos/); infinitive forms and dependent infinitives against [UMI §§81, 83, 87–88](https://www.interlingua.com/grammatica/grammatica/infinitivo/). Other examples illustrate the already reviewed lesson notes. This integration does not rewrite recorded passages or their audio.

Automated validation: all 25 tests passed and Flutter analysis reported no issues. New coverage loads the actual lesson assets, checks that every existing grammar bullet is retained, exercises every topic/example in all ten lessons at 390 px, and verifies selection/reset behavior at 320 px in dark mode.

The release web build succeeded. Browser verification confirmed the inline card appears before vocabulary/review, switching `Esser` from `Io` to `Nos` updates the phrase and explanation, and the compact view fits a measured 324×703 CSS viewport without horizontal overflow. No captured browser warnings/errors. Temporary viewport and cache overrides were restored. Screenshot: `build/browser-qa/lesson-inline-grammar.png`. Changes remain local, without merge/push.

## Grammar across all six levels — 2026-10-16

The course now exposes a dedicated Grammatica section at the beginning of every level, with three individually accessible topics per level. The curriculum is a teaching sequence chosen by Schola, not an official UMI level classification. Existing recorded-lesson explanations remain intact. The original `/appendix/grammatica` compendium URL remains available.

| Level | Topics |
| --- | --- |
| 1 | Articles, plurals, present |
| 2 | Adjectives, comparison, personal pronouns |
| 3 | Possessives, questions, infinitive combinations |
| 4 | Demonstratives, conjunctions, adverbs |
| 5 | Past/future/conditional, perfect tenses, imperative |
| 6 | Negation/object pronouns, relatives, passive |

Ten new original explanations add selectable transformations and two feedback exercises each. Each course destination opens only its selected topic, without the large workshop selector or global session counter. Practice is session-only and does not modify vocabulary SRS. The curriculum maps each of the 18 topics exactly once.

Sources consulted on 2026-10-16:
- [Personal pronouns §§56–63](https://www.interlingua.com/grammatica/grammatica/pronomines-personal/)
- [Possessives §§64–65](https://www.interlingua.com/grammatica/grammatica/possessivos/)
- [Questions §116](https://www.interlingua.com/grammatica/grammatica/tabula-de-conjugation/)
- [Infinitives §§81, 83, 88](https://www.interlingua.com/grammatica/grammatica/infinitivo/)
- [Demonstratives §§78–79](https://www.interlingua.com/grammatica/grammatica/demonstrativos/)
- [Grammatical particles §134](https://www.interlingua.com/grammatica/grammatica/particulas-grammatic/)
- [Perfect tenses §§105–106](https://www.interlingua.com/grammatica/grammatica/tempore-passate/) and [past participles §95](https://www.interlingua.com/grammatica/grammatica/participio-passate/)
- [Imperative §§110–111](https://www.interlingua.com/grammatica/grammatica/imperativo/)
- [Relatives §§74–77](https://www.interlingua.com/grammatica/grammatica/relativos/)
- [Passive §§112–114](https://www.interlingua.com/grammatica/grammatica/passivo/)

Validation: 27 Flutter tests pass, including all 18 course grammar destinations and state reset at 320 px, every workshop example and exercise at 390 px, and existing lesson grammar/navigation/search/audio-service coverage. Flutter analysis reports no issues. No native device test is implied by widget validation. Work remains local pending separate merge/push authorization.

Release web build succeeded (existing optional Wasm dry-run warnings in flutter_tts). Browser QA on the rebuilt local app confirmed all six grammar sections, navigation from the course into the level-6 passive topic, switching the example to past tense, correct-answer feedback, and returning to the course. Captured console has no warnings/errors. Screenshot: `build/browser-qa/grammar-level-six.png`.

## Short grammar within vocabulary lessons — 2026-10-16

Reviewed the terms in all 33 course vocabulary units. Added one compact, unit-specific grammar card to 25 units, directly before existing vocabulary practice. Each note has 2–3 selectable examples, a short explanation (maximum 65 words), a changing result/reason, and a link to the official source. No extra grammar quiz or session counter is inserted into vocabulary lessons. Existing audio, vocabulary, quiz/SRS and completion behavior are unchanged.

| Units | Teaching focus |
| --- | --- |
| basico1, basico2 | Articles and personal pronouns |
| adjectivos1, adjectivos2, colores | Invariable adjectives, position, multe versus multo |
| plurales | Vowel/consonant plurals and unchanged adjectives |
| esser-haber | Identity, possession and existential il ha |
| adjectivos-possessive, possessives2 | Possessives before nouns versus standalone singular/plural forms |
| presente1, verbos2 | Present endings and modal + infinitive |
| demonstrativos1 | Adjectival versus pronominal demonstratives |
| conjunctiones, questiones | Logical connectors and interrogative words |
| prepositiones | Location, destination, possession, al/del contractions |
| numeros | Compound cardinals and multiplication of cento |
| verbos3 | Infinitive constructions with a/pro and no preposition |
| datas-tempore | Cardinal dates and telling/scheduling time |
| verbos4, verbos5, verbos6 | Reflexives, pronoun placement, infinitive combinations |
| adverbios1, adverbios2, adverbios3 | Ben/melio, derivation in -mente and -amente |
| negativos | Non before the verb/object pronoun; nulle and nemo |

The eight predominantly lexical units (phrases-quotidian, alimentos, animales, vestimentos, familia, occupationes, prender-casa, technologia) retain their focused vocabulary practice without a forced grammar note.

New source checks supplement the sources above:
- [Plurals §25](https://www.interlingua.com/grammatica/grammatica/plurales/)
- [Cardinals §§118–123](https://www.interlingua.com/grammatica/grammatica/cardinales/), [ordinals §125](https://www.interlingua.com/grammatica/grammatica/ordinales/) and [dates/time §§132–133](https://www.interlingua.com/grammatica/grammatica/multiplicativos/)
- [Adjectives §§31–33](https://www.interlingua.com/grammatica/grammatica/adjectivos/)
- [Adverbs §§43–53](https://www.interlingua.com/grammatica/grammatica/adverbios/)
- [Reflexives §§66–73](https://www.interlingua.com/grammatica/grammatica/reflexivos/)
- [List of grammatical particles §134](https://www.interlingua.com/grammatica/grammatica/lista-de-particulas-grammatic/)
- [Indefinite article §§19–21](https://www.interlingua.com/grammatica/grammatica/articulo-indefinite/)

Validation: 29 tests pass; new integration coverage opens all 25 vocabulary units at 320 px, checks placement before practice, exercises every example, verifies reset between units and absence in a lexical unit. Existing recorded-lesson and six-level grammar checks still pass. Flutter analysis reports no issues. Changes remain local on codex/grammar-all-levels, without merge/push.

Release web compilation succeeded, with the same optional flutter_tts Wasm dry-run warnings as before. Browser verification on the rebuilt local web app covered Plurales → Adjectivo, Possessives 2 → Plure libros, Prepositiones → De + le, and Numeros → 232, including returns through Studiar. Grammar results and notes changed correctly, vocabulary practice remained below, and captured console contained no warnings/errors. Screenshot: `build/browser-qa/vocab-plural-grammar.png`. No iOS/Android device build was performed.
