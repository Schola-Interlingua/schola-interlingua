/// Original teaching notes and exercises, checked against the UMI grammar.
/// Source sections are attached to each topic; these are not UMI quotations.
class GrammarExample {
  const GrammarExample(this.label, this.before, this.after, this.note);
  final String label;
  final String before;
  final String after;
  final String note;
}

class GrammarQuestion {
  const GrammarQuestion(
    this.prompt,
    this.options,
    this.answer,
    this.explanation,
  );
  final String prompt;
  final List<String> options;
  final int answer;
  final String explanation;
}

class GrammarLesson {
  const GrammarLesson({
    required this.id,
    required this.title,
    required this.summary,
    required this.rule,
    required this.caution,
    required this.examples,
    required this.questions,
    required this.source,
    required this.sections,
  });
  final String id;
  final String title;
  final String summary;
  final String rule;
  final String caution;
  final List<GrammarExample> examples;
  final List<GrammarQuestion> questions;
  final String source;
  final String sections;
}

const grammarLessons = <GrammarLesson>[
  GrammarLesson(
    id: 'articulos',
    title: 'Articulos',
    summary: 'Le o un? Identifica lo de que tu parla.',
    rule:
        'Usa le pro un referente identificate e un pro introducer un referente non ancora identificate. Le articulo non cambia con le genere del substantivo; le resta le anque in plural.',
    caution:
        'Ante un substantivo: un casa, non una casa. A + le e de + le se contrahe a al e del.',
    examples: [
      GrammarExample(
        'Identificar',
        'un jardin',
        'le jardin',
        'Prime mention: un jardin. Postea, quando nos sape qual: le jardin.',
      ),
      GrammarExample(
        'A + le',
        'a + le parco',
        'al parco',
        'Le duo parolas se combina.',
      ),
      GrammarExample(
        'De + le',
        'de + le museo',
        'del museo',
        'Le contraction conserva le signification.',
      ),
    ],
    questions: [
      GrammarQuestion(
        'Completa: Io visita ___ bibliotheca nove.',
        ['una', 'un', 'unos'],
        1,
        'Un non varia pro genere ante un substantivo.',
      ),
      GrammarQuestion(
        'Combina de + le: le porta ___ museo.',
        ['de le', 'de un', 'del'],
        2,
        'De + le se contrahe a del.',
      ),
    ],
    source:
        'https://www.interlingua.com/grammatica/grammatica/articulo-definite/',
    sections: '§§17–21; anque Articulo indefinite',
  ),
  GrammarLesson(
    id: 'plural',
    title: 'Singular e plural',
    summary: 'Un cosa, plure cosas: observa le termination.',
    rule:
        'Post un vocal, adde -s. Post un consonante, adde -es. Si le parola termina in -c, cambia c a ch ante -es.',
    caution:
        'Isto es le modello regular. Certe parolas de origine estranier conserva un plural proprie; consulta le dictionario in casos special.',
    examples: [
      GrammarExample(
        'Vocal + s',
        'libro',
        'libros',
        'Le vocal final resta; tu adde solmente s.',
      ),
      GrammarExample(
        'Consonante + es',
        'flor',
        'flores',
        'Post r, le plural recipe es.',
      ),
      GrammarExample(
        'C → ches',
        'roc',
        'roches',
        'Le h conserva le sono dur del c.',
      ),
    ],
    questions: [
      GrammarQuestion(
        'Qual es le plural regular de animal?',
        ['animals', 'animales', 'animali'],
        1,
        'Animal termina in consonante: adde -es.',
      ),
      GrammarQuestion(
        'Qual es le plural de roc?',
        ['rocs', 'roces', 'roches'],
        2,
        'Un c final deveni ch ante -es.',
      ),
    ],
    source: 'https://www.interlingua.com/grammatica/grammatica/plurales/',
    sections: '§25',
  ),
  GrammarLesson(
    id: 'adjectivos',
    title: 'Adjectivos',
    summary: 'Le substantivo cambia; le adjectivo resta.',
    rule:
        'Un adjectivo que describe un substantivo non cambia pro genere o numero. Su position normal es post le substantivo. Adjectivos breve pote anque preceder lo.',
    caution:
        'Grande e belle non recipe -s quando le substantivo deveni plural. Le uso de un adjectivo como substantivo es un altere caso.',
    examples: [
      GrammarExample(
        'Numero',
        'un jardin tranquille',
        'duo jardines tranquille',
        'Tranquille ha le mesme forma.',
      ),
      GrammarExample(
        'Genere natural',
        'un amico contente',
        'un amica contente',
        'Contente non cambia con amico o amica.',
      ),
      GrammarExample(
        'Position',
        'un libro bon',
        'un bon libro',
        'Bon es breve; ambe positiones es possibile.',
      ),
    ],
    questions: [
      GrammarQuestion(
        'Completa: tres casas ___.',
        ['blancas', 'blanco', 'blanc'],
        2,
        'Blanc es invariable: le adjectivo non concorda in genere o numero.',
      ),
      GrammarQuestion(
        'Qual phrase es correcte?',
        [
          'duo libros interessante',
          'duo libros interessantes',
          'duo libros interessanti',
        ],
        0,
        'Solmente libro prende le plural; interessante resta invariable.',
      ),
    ],
    source: 'https://www.interlingua.com/grammatica/grammatica/adjectivos/',
    sections: '§§31–33',
  ),
  GrammarLesson(
    id: 'presente',
    title: 'Le presente',
    summary: 'Retira un littera, conserva le vocal.',
    rule:
        'Pro le presente regular, retira le -r final del infinitivo. Le forma resultante servi pro io, tu, nos e le altere personas. Esser, haber e vader ha le formas breve es, ha e va.',
    caution:
        'Non usa -a pro tote le verbos: vider deveni vide e audir deveni audi.',
    examples: [
      GrammarExample(
        '-ar',
        'parlar − r',
        'io parla · nos parla',
        'Le persona cambia; le verbo non cambia.',
      ),
      GrammarExample(
        '-er',
        'vider − r',
        'tu vide · vos vide',
        'Le e del infinitivo es conservate.',
      ),
      GrammarExample(
        '-ir',
        'audir − r',
        'illa audi · illes audi',
        'Le i del infinitivo es conservate.',
      ),
    ],
    questions: [
      GrammarQuestion(
        'Completa con vider: Nos ___ le mar.',
        ['vide', 'vida', 'viden'],
        0,
        'Retira r de vider: vide, anque con nos.',
      ),
      GrammarQuestion(
        'Completa con audir: Tu ___ le musica.',
        ['aude', 'audi', 'audis'],
        1,
        'Audir minus r da audi; tu non require un termination additional.',
      ),
    ],
    source:
        'https://www.interlingua.com/grammatica/grammatica/tempore-presente/',
    sections: '§§99–101',
  ),
  GrammarLesson(
    id: 'tempores',
    title: 'Heri, hodie, deman',
    summary: 'Un linea del tempore pro le mesme action.',
    rule:
        'Pro le passato regular, usa le infinitivo sin -r e adde -va. Pro le futuro, conserva le infinitivo e adde -a. Pro le conditional, conserva le infinitivo e adde -ea.',
    caution:
        'In le futuro, le vocal final a es accentuate in pronunciation, sin adder un accento graphic. Va + infinitivo es anque un maniera de exprimer le futuro.',
    examples: [
      GrammarExample(
        'Heri',
        'visitar − r + va',
        'io visitava',
        'Un action situate in le passato.',
      ),
      GrammarExample(
        'Hodie',
        'visitar − r',
        'io visita',
        'Le presente: nulle termination personal.',
      ),
      GrammarExample(
        'Deman',
        'visitar + a',
        'io visitara',
        'Pronuncia le a final con accento.',
      ),
      GrammarExample(
        'Conditional',
        'visitar + ea',
        'io visitarea',
        'Un action conditional; le accento es sur e in -ea.',
      ),
    ],
    questions: [
      GrammarQuestion(
        'Completa in le passato: Heri io ___ le museo. (visitar)',
        ['visitara', 'visitava', 'visitar'],
        1,
        'Visitar minus r plus va produce visitava.',
      ),
      GrammarQuestion(
        'Qual forma exprime le futuro de leger?',
        ['legeva', 'legerea', 'legera'],
        2,
        'Le infinitivo leger recipe a: legera. Le r resta.',
      ),
    ],
    source:
        'https://www.interlingua.com/grammatica/grammatica/tempore-futur-e-conditional/',
    sections: '§§107–108; passato: §102',
  ),
  GrammarLesson(
    id: 'negation',
    title: 'Negation e objecto',
    summary: 'Vide ubi poner non, me, te e lo.',
    rule:
        'Non precede le verbo que illo nega. Quando un pronomine de objecto precede le verbo, non veni ante ille pronomine: io non lo comprende.',
    caution:
        'Io es un subjecto; me es un forma de objecto. In le tertie persona, distingue ille/illa/illo de le/la/lo.',
    examples: [
      GrammarExample(
        'Negar',
        'io comprende',
        'io non comprende',
        'Non se placia ante comprende.',
      ),
      GrammarExample(
        'Con objecto',
        'io lo comprende',
        'io non lo comprende',
        'Le ordine es subjecto → non → objecto → verbo.',
      ),
      GrammarExample(
        'Persona',
        'io te vide',
        'tu me vide',
        'Me e te indica le objecto; io e tu indica le subjecto.',
      ),
    ],
    questions: [
      GrammarQuestion(
        'Completa: Io non ___ comprende. (illo)',
        ['ille', 'lo', 'io'],
        1,
        'Lo es le forma de objecto correspondente a illo.',
      ),
      GrammarQuestion(
        'Qual es le ordine del modello negative?',
        [
          'Io lo comprende non.',
          'Io non lo comprende.',
          'Io lo non comprende.',
        ],
        1,
        'Non veni ante le pronomine de objecto que precede le verbo.',
      ),
    ],
    source: 'https://www.interlingua.com/grammatica/grammatica/adverbios/',
    sections: '§53; pronomines: §§62–63',
  ),
  GrammarLesson(
    id: 'adverbios',
    title: 'Como? Adverbios',
    summary: 'Del qualitate al maniera de ager.',
    rule:
        'Pro formar un adverbio regular, adde -mente al adjectivo complete. Post -c, insere a ante -mente: practic → practicamente.',
    caution:
        'Non remove le e de un adjectivo como lente. Il ha anque adverbios primari, como ben, que tu apprende como parolas.',
    examples: [
      GrammarExample(
        'Adde mente',
        'lente + mente',
        'lentemente',
        'Le e final del adjectivo resta.',
      ),
      GrammarExample(
        'Post c',
        'practic + a + mente',
        'practicamente',
        'Le c resta; un a se insere.',
      ),
      GrammarExample(
        'Forma proprie',
        'bon',
        'ben',
        'Ben es un adverbio primari, non le modello regular in -mente.',
      ),
    ],
    questions: [
      GrammarQuestion(
        'Forma le adverbio regular de natural.',
        ['naturalmente', 'naturalemente', 'naturalamente'],
        0,
        'Adde mente al adjectivo complete: natural + mente.',
      ),
      GrammarQuestion(
        'Forma le adverbio regular de practic.',
        ['practicmente', 'practimente', 'practicamente'],
        2,
        'Post c, insere a ante mente.',
      ),
    ],
    source: 'https://www.interlingua.com/grammatica/grammatica/adverbios/',
    sections: '§§44–47',
  ),
  GrammarLesson(
    id: 'comparation',
    title: 'Comparar',
    summary: 'Plus, minus e tanto… como.',
    rule:
        'Usa plus… que o minus… que pro comparar. Pro equalitate, usa tanto… como. Pro le superlativo relative, usa le plus o le minus.',
    caution:
        'Multo grande exprime un grado alte; illo non es le mesme que plus grande que un altere cosa.',
    examples: [
      GrammarExample(
        'Superioritate',
        'grande',
        'plus grande que',
        'Un jardin es plus grande que un altere.',
      ),
      GrammarExample(
        'Equalitate',
        'grande',
        'tanto grande como',
        'Le duo jardines ha le mesme grandor.',
      ),
      GrammarExample(
        'Superlativo',
        'grande',
        'le plus grande',
        'Le plus grande jardin de un gruppo.',
      ),
    ],
    questions: [
      GrammarQuestion(
        'Completa: Iste casa es plus grande ___ ille casa.',
        ['como', 'que', 'de'],
        1,
        'Post un comparativo con plus, usa que.',
      ),
      GrammarQuestion(
        'Completa: Iste libro es tanto interessante ___ ille libro.',
        ['que', 'de', 'como'],
        2,
        'Le comparation de equalitate usa tanto… como.',
      ),
    ],
    source:
        'https://www.interlingua.com/grammatica/grammatica/comparation-de-adjectivos/',
    sections: '§§34–36',
  ),
];
