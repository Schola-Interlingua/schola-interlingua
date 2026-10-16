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
  GrammarLesson(
    id: "pronomines",
    title: "Qui face le action?",
    summary: "Le subjecto indica qui age.",
    rule:
        "Io, tu, ille, illa, illo; nos, vos, illes. Le verbo resta le mesme quando le persona cambia.",
    caution: "Vos pote indicar plure personas o un adresse formal.",
    examples: [
      GrammarExample(
        "Io → nos",
        "io studia",
        "nos studia",
        "Nos include le parlator e altere personas; studia non cambia.",
      ),
      GrammarExample(
        "Illa → illes",
        "illa parla",
        "illes parla",
        "Le subjecto cambia al plural, ma le verbo resta parla.",
      ),
    ],
    questions: [
      GrammarQuestion(
        "Completa pro un gruppo que include te: ___ studia.",
        ["Nos", "Illa", "Io"],
        0,
        "Nos indica le parlator con altere personas.",
      ),
      GrammarQuestion(
        "Cambia io a illes: io lege.",
        ["illes leges", "illes lege", "illes leger"],
        1,
        "Le verbo non recipe un termination personal.",
      ),
    ],
    source:
        "https://www.interlingua.com/grammatica/grammatica/pronomines-personal/",
    sections: "§§56–63",
  ),
  GrammarLesson(
    id: "possessivos",
    title: "De qui es isto?",
    summary: "Distingue le possessor del cosa possedite.",
    rule:
        "Ante un substantivo, usa mi, tu, su, nostre, vostre, lor. Quando le substantivo es omittite, usa le mie, le tue, le sue, le nostre, le vostre, le lore; adde -s si le cosas es plural.",
    caution:
        "Su pote referer a ille o illa. De ille o de illa pote clarificar le possessor.",
    examples: [
      GrammarExample(
        "Ante le nomine",
        "le libro de me",
        "mi libro",
        "Mi precede libro sin articulo.",
      ),
      GrammarExample(
        "Sin le nomine",
        "mi libros",
        "le mies",
        "Le nomine es omittite; mie recipe s pro plure libros.",
      ),
    ],
    questions: [
      GrammarQuestion(
        "Completa: Nos ama ___ familia.",
        ["nostre", "nostres", "nos"],
        0,
        "Nostre es invariable ante familia.",
      ),
      GrammarQuestion(
        "Substitue mi libros sin repeter libros.",
        ["le mi", "le mies", "mi"],
        1,
        "Como pronomine plural, usa le mies.",
      ),
    ],
    source: "https://www.interlingua.com/grammatica/grammatica/possessivos/",
    sections: "§§64–65",
  ),
  GrammarLesson(
    id: "questiones",
    title: "Facer questiones",
    summary: "Cambia un affirmation in un question.",
    rule:
        "Tu pote inverter verbo e subjecto, usar intonation, o poner an al initio. Ubi demanda un loco; quando demanda un tempore; qui demanda un persona.",
    caution: "Non adde un auxiliar equivalente al anglese do.",
    examples: [
      GrammarExample(
        "Inversion",
        "vos parla interlingua",
        "Parla vos interlingua?",
        "Le verbo passa ante le subjecto.",
      ),
      GrammarExample(
        "An",
        "vos parla interlingua",
        "An vos parla interlingua?",
        "An marca le question sin cambiar le ordine interne.",
      ),
      GrammarExample(
        "Loco",
        "le curso es hic",
        "Ubi es le curso?",
        "Ubi substitue le information de loco.",
      ),
    ],
    questions: [
      GrammarQuestion(
        "Demanda le loco: ___ es le bibliotheca?",
        ["Quando", "Ubi", "Qui"],
        1,
        "Ubi demanda ubi un cosa se trova.",
      ),
      GrammarQuestion(
        "Qual question conserva le ordine del affirmation?",
        ["An tu lege?", "Lege an tu?", "Tu an lege?"],
        0,
        "An se pone al initio.",
      ),
    ],
    source:
        "https://www.interlingua.com/grammatica/grammatica/tabula-de-conjugation/",
    sections: "§116",
  ),
  GrammarLesson(
    id: "infinitivo",
    title: "Combinar duo verbos",
    summary: "Un intention plus un action.",
    rule:
        "Post voler, poter e deber, le secunde verbo es un infinitivo sin preposition: vole leger, pote venir, debe partir. Post un preposition, un action pote anque esser exprimite per un infinitivo.",
    caution: "Non conjuga le secunde verbo: io vole leger, non io vole lege.",
    examples: [
      GrammarExample(
        "Voler",
        "io lege",
        "io vole leger",
        "Vole exprime le intention; leger nomina le action.",
      ),
      GrammarExample(
        "Poter",
        "nos veni",
        "nos pote venir",
        "Pote indica possibilitate. Venir conserva su -r.",
      ),
      GrammarExample(
        "Sin",
        "io parla",
        "sin parlar",
        "Post sin, usa le infinitivo pro nominar un action.",
      ),
    ],
    questions: [
      GrammarQuestion(
        "Completa: Tu pote ___ hic.",
        ["studia", "studiar", "studiava"],
        1,
        "Poter es sequite per le infinitivo sin preposition.",
      ),
      GrammarQuestion(
        "Completa: Illa parti sin ___.",
        ["mangia", "mangiava", "mangiar"],
        2,
        "Post sin, le action es exprimite per un infinitivo.",
      ),
    ],
    source: "https://www.interlingua.com/grammatica/grammatica/infinitivo/",
    sections: "§§81, 83, 88",
  ),
  GrammarLesson(
    id: "demonstrativos",
    title: "Iste o ille?",
    summary: "Monstra proximitate o distantia.",
    rule:
        "Ante un nomine, iste indica proximitate e ille distantia. Iste e ille non cambia con le numero del nomine. Como pronomines, illos pote variar: isto, illo, istes, illos.",
    caution: "Isto es un forma pronominal neutre; ante libro usa iste libro.",
    examples: [
      GrammarExample(
        "Proxime",
        "le libro hic",
        "iste libro",
        "Iste presenta le libro como proxime.",
      ),
      GrammarExample(
        "Distante",
        "le libros illac",
        "ille libros",
        "Ante le nomine plural, ille resta invariable.",
      ),
      GrammarExample(
        "Sin nomine",
        "iste cosa",
        "isto",
        "Isto pote representar un cosa sin nominar lo.",
      ),
    ],
    questions: [
      GrammarQuestion(
        "Indica plure libros proxime: ___ libros.",
        ["istes", "iste", "isto"],
        1,
        "Le demonstrativo adjectival es invariable.",
      ),
      GrammarQuestion(
        "Completa sin un nomine: Que es ___?",
        ["iste libro", "isto", "istes libros"],
        1,
        "Isto es un pronomine neutre pro un cosa.",
      ),
    ],
    source: "https://www.interlingua.com/grammatica/grammatica/demonstrativos/",
    sections: "§§78–79",
  ),
  GrammarLesson(
    id: "conjunctiones",
    title: "Connecter ideas",
    summary: "Adde, oppone o explica.",
    rule:
        "E adde information; o presenta un alternativa; sed introduce un contrasto; proque introduce un causa. Selige le connexion secundo le relation inter le ideas.",
    caution:
        "Proque explica un causa; pro + infinitivo exprime sovente un scopo.",
    examples: [
      GrammarExample(
        "Addition",
        "io lege / io scribe",
        "io lege e io scribe",
        "E reuni duo actiones.",
      ),
      GrammarExample(
        "Contrasto",
        "io vole partir / io resta",
        "io vole partir, sed io resta",
        "Sed monstra le contrasto inter intention e action.",
      ),
      GrammarExample(
        "Causa",
        "io resta / io es fatigate",
        "io resta proque io es fatigate",
        "Proque introduce le ration de restar.",
      ),
    ],
    questions: [
      GrammarQuestion(
        "Exprime un alternativa: the ___ caffe.",
        ["e", "o", "proque"],
        1,
        "O presenta un selection inter duo possibilitates.",
      ),
      GrammarQuestion(
        "Exprime le causa: Io studia ___ io vole apprender.",
        ["sed", "o", "proque"],
        2,
        "Proque introduce le ration de studiar.",
      ),
    ],
    source:
        "https://www.interlingua.com/grammatica/grammatica/particulas-grammatic/",
    sections: "§134; Lista de particulas grammatic",
  ),
  GrammarLesson(
    id: "perfecte",
    title: "Actiones ja completate",
    summary: "Construe le participio e combina lo con haber.",
    rule:
        "Le participio regular cambia -ar a -ate, -er a -ite e -ir a -ite. Usa ha + participio pro le presente perfecte e habeva + participio pro le passato perfecte.",
    caution:
        "Ha studiate pote anque exprimer un action passate como studiava; non impone le restrictiones del anglese.",
    examples: [
      GrammarExample(
        "Haber + -ar",
        "studiar → studiate",
        "io ha studiate",
        "Ha es le auxiliar; studiate es le participio.",
      ),
      GrammarExample(
        "Haber + -er",
        "vider → vidite",
        "nos ha vidite le film",
        "Le participio regular de vider es vidite.",
      ),
      GrammarExample(
        "Anterioritate",
        "io ha mangiate",
        "io habeva mangiate ante le reunion",
        "Habeva situa le action ante un altere momento passate.",
      ),
    ],
    questions: [
      GrammarQuestion(
        "Completa: Nos ha ___ le musica. (audir)",
        ["audiva", "audite", "audir"],
        1,
        "Audir forma audite; ha audite es un tempore composite.",
      ),
      GrammarQuestion(
        "Un action ante un altere momento passate: io ___ studiate.",
        ["habeva", "essera", "es"],
        0,
        "Habeva + participio forma le passato perfecte.",
      ),
    ],
    source:
        "https://www.interlingua.com/grammatica/grammatica/tempore-passate/",
    sections: "§§105–106; participio: §95",
  ),
  GrammarLesson(
    id: "imperativo",
    title: "Invitar a agir",
    summary: "Un instruction breve e directe.",
    rule:
        "Le imperativo ha le forma del presente e generalmente omitte le subjecto: parla!, lege!, audi! Pro un invitation con nos, usa que nos + verbo.",
    caution: "Le imperativo non require un termination special pro vos.",
    examples: [
      GrammarExample(
        "Instruction",
        "tu lege le texto",
        "Lege le texto!",
        "Le verbo resta lege; le subjecto es generalmente omittite.",
      ),
      GrammarExample(
        "Invitation",
        "nos studia",
        "Que nos studia!",
        "Que nos introduce un invitation collective.",
      ),
    ],
    questions: [
      GrammarQuestion(
        "Da un instruction con parlar.",
        ["Parlar!", "Parlava!", "Parla!"],
        2,
        "Le imperativo coincide con le presente.",
      ),
      GrammarQuestion(
        "Invita le gruppo a leger.",
        ["Que nos lege!", "Que nos leger!", "Nos leges!"],
        0,
        "Que nos + verbo exprime le invitation collective.",
      ),
    ],
    source: "https://www.interlingua.com/grammatica/grammatica/imperativo/",
    sections: "§§110–111",
  ),
  GrammarLesson(
    id: "relativos",
    title: "Unir phrases con que",
    summary: "Describe un persona o un cosa sin recommenciar.",
    rule:
        "Que introduce un proposition relative. Qui pote referer a personas como subjecto o post un preposition. Cuje exprime possession. Le pronomine relative non es omittite.",
    caution:
        "Qui non substitue que como objecto directe: le persona que io vide.",
    examples: [
      GrammarExample(
        "Cosa",
        "io lege un libro / le libro es breve",
        "io lege un libro que es breve",
        "Que reprende libro como subjecto de es.",
      ),
      GrammarExample(
        "Persona",
        "un amico / ille parla interlingua",
        "un amico qui parla interlingua",
        "Qui reprende un persona como subjecto.",
      ),
      GrammarExample(
        "Possession",
        "un autor / su libro es famose",
        "un autor cuje libro es famose",
        "Cuje liga le autor al libro que le pertine.",
      ),
    ],
    questions: [
      GrammarQuestion(
        "Completa: Le libro ___ io lege es nove.",
        ["qui", "que", "cuje"],
        1,
        "Que es le objecto de lege in le proposition relative.",
      ),
      GrammarQuestion(
        "Exprime possession: un studente ___ matre es docente.",
        ["cuje", "que", "qui"],
        0,
        "Cuje introduce le relation de possession.",
      ),
    ],
    source: "https://www.interlingua.com/grammatica/grammatica/relativos/",
    sections: "§§74–77",
  ),
  GrammarLesson(
    id: "passivo",
    title: "Cambiar le puncto de vista",
    summary: "Mitte le cosa que recipe le action al centro.",
    rule:
        "Le passivo usa esser + participio passate. Le objecto del phrase active deveni le subjecto. Per pote introducer qui face le action. Cambia esser pro exprimer le tempore.",
    caution: "Non confunde ha create (action active) con es create (passivo).",
    examples: [
      GrammarExample(
        "Presente",
        "le studentes prepara le projecto",
        "le projecto es preparate per le studentes",
        "Le projecto deveni le subjecto; es + preparate forma le passivo.",
      ),
      GrammarExample(
        "Passato",
        "le studentes preparava le projecto",
        "le projecto esseva preparate per le studentes",
        "Esseva cambia le tempore del passivo al passato.",
      ),
      GrammarExample(
        "Futuro",
        "le studentes preparara le projecto",
        "le projecto essera preparate per le studentes",
        "Essera situa le action passive in le futuro.",
      ),
    ],
    questions: [
      GrammarQuestion(
        "Completa le passivo: Le texto ___ traducite per Ana.",
        ["ha", "es", "habeva"],
        1,
        "Esser + participio forma le passivo.",
      ),
      GrammarQuestion(
        "Selige le passivo in le passato.",
        ["es preparate", "ha preparate", "esseva preparate"],
        2,
        "Esseva es le passato de esser.",
      ),
    ],
    source: "https://www.interlingua.com/grammatica/grammatica/passivo/",
    sections: "§§112–114",
  ),
];
