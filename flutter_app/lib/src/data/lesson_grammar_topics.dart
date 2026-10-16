import 'grammar_lessons.dart';

/// Indices refer to the existing grammarBullets of each recorded lesson.
/// Keep the explanation in the lesson and explore its rule with local examples.
class LessonGrammarTopic {
  const LessonGrammarTopic(
    this.title,
    this.bulletIndices,
    this.examples, {
    this.explanation,
    this.source,
    this.sections,
  });
  final String title;
  final List<int> bulletIndices;
  final List<GrammarExample> examples;
  final String? explanation;
  final String? source;
  final String? sections;
}

const lessonGrammarTopics = <String, List<LessonGrammarTopic>>{
  'lection1': [
    LessonGrammarTopic(
      'Articulos',
      [0, 1],
      [
        GrammarExample(
          'Un',
          'un appartamento',
          'un amica',
          'Un resta un: le substantivo cambia.',
        ),
        GrammarExample(
          'Le',
          'le appartamento',
          'le appartamentos',
          'Le resta le, anque in plural.',
        ),
      ],
    ),
    LessonGrammarTopic(
      'Pronomines',
      [2],
      [
        GrammarExample(
          'Io',
          'Maria parla.',
          'Io parla.',
          'Maria parla de se mesme: illa usa io.',
        ),
        GrammarExample(
          'Illa',
          'Maria parla.',
          'Illa parla.',
          'Nos parla de Maria: nos usa illa.',
        ),
        GrammarExample(
          'Nos',
          'Maria e Ana parla.',
          'Nos parla.',
          'Maria parla pro le gruppo que include se mesme.',
        ),
      ],
    ),
    LessonGrammarTopic(
      'Esser',
      [3],
      [
        GrammarExample('Io', 'esser', 'io es', 'Pro io, le forma breve es es.'),
        GrammarExample(
          'Tu',
          'esser',
          'tu es',
          'Le persona cambia; es resta identic.',
        ),
        GrammarExample(
          'Nos',
          'esser',
          'nos es',
          'Anque in plural, nos pote usar es.',
        ),
      ],
    ),
    LessonGrammarTopic(
      'Infinitivo',
      [4],
      [
        GrammarExample(
          '-ar',
          'parl + ar',
          'parlar',
          'Le infinitivo termina in r.',
        ),
        GrammarExample(
          '-er',
          'comprend + er',
          'comprender',
          'Hic le termination es er.',
        ),
        GrammarExample('-ir', 'aud + ir', 'audir', 'Hic le termination es ir.'),
      ],
    ),
  ],
  'lection2': [
    LessonGrammarTopic(
      'Reflexivos',
      [0],
      [
        GrammarExample(
          'Io',
          'eveliar se',
          'io me evelia',
          'Con io, le pronomine reflexive es me.',
        ),
        GrammarExample('Tu', 'eveliar se', 'tu te evelia', 'Con tu, usa te.'),
        GrammarExample(
          'Ille',
          'eveliar se',
          'ille se evelia',
          'In le tertie persona, usa se.',
        ),
      ],
    ),
    LessonGrammarTopic(
      'Plural',
      [1],
      [
        GrammarExample(
          'Vocal',
          'libro + s',
          'libros',
          'Post un vocal, adde s.',
        ),
        GrammarExample(
          'Consonante',
          'flor + es',
          'flores',
          'Post un consonante, adde es.',
        ),
      ],
    ),
    LessonGrammarTopic(
      'Adjectivos',
      [2],
      [
        GrammarExample(
          'Un',
          'un libro',
          'un libro jalne',
          'Jalne describe le libro.',
        ),
        GrammarExample(
          'Duo',
          'duo libros',
          'duo libros jalne',
          'Libro prende s; jalne non cambia.',
        ),
      ],
    ),
  ],
  'lection3': [
    LessonGrammarTopic(
      'Articulos',
      [0],
      [
        GrammarExample(
          'Singular',
          'le lecto',
          'le lecto molle',
          'Le identifica le lecto.',
        ),
        GrammarExample(
          'Plural',
          'le cossinos',
          'le cossinos suave',
          'Le non cambia in plural.',
        ),
      ],
    ),
    LessonGrammarTopic(
      'Adjectivos',
      [1],
      [
        GrammarExample(
          'Un',
          'un sedia',
          'un sedia elegante',
          'Elegante describe un sedia.',
        ),
        GrammarExample(
          'Quatro',
          'quatro sedias',
          'quatro sedias elegante',
          'Solmente sedia cambia al plural.',
        ),
      ],
    ),
    LessonGrammarTopic(
      'Presente',
      [2],
      [
        GrammarExample(
          'Un',
          'le cossino',
          'le cossino es suave',
          'Le forma verbal es es.',
        ),
        GrammarExample(
          'Plure',
          'le cossinos',
          'le cossinos es suave',
          'Es servi anque pro le plural.',
        ),
      ],
    ),
  ],
  'lection4': [
    LessonGrammarTopic(
      'Hora',
      [0],
      [
        GrammarExample(
          '7:00',
          'a + septe horas',
          'a septe horas',
          'A introduce le hora del action.',
        ),
        GrammarExample(
          '8:30',
          'a + octo e medie',
          'a octo e medie',
          'E medie adde un medie hora.',
        ),
      ],
    ),
    LessonGrammarTopic(
      'Adverbios',
      [1],
      [
        GrammarExample(
          'Rapide',
          'rapide + mente',
          'rapidemente',
          'Adde mente al adjectivo complete.',
        ),
        GrammarExample(
          'Lente',
          'lente + mente',
          'lentemente',
          'Le e final resta.',
        ),
      ],
    ),
    LessonGrammarTopic(
      'Presente',
      [2],
      [
        GrammarExample(
          'Io',
          'leger − r',
          'io lege un libro',
          'Retira r: leger deveni lege.',
        ),
        GrammarExample(
          'Nos',
          'leger − r',
          'nos lege un libro',
          'Nos usa le mesme forma lege.',
        ),
      ],
    ),
  ],
  'lection5': [
    LessonGrammarTopic(
      'Con',
      [0],
      [
        GrammarExample(
          'Tomate',
          'pan + con + tomate',
          'pan con tomate',
          'Con introduce un ingrediente.',
        ),
        GrammarExample(
          'Caseo',
          'pizza + con + caseo',
          'pizza con caseo',
          'Le ingrediente cambia; con resta.',
        ),
      ],
    ),
    LessonGrammarTopic(
      'Preferer',
      [1],
      [
        GrammarExample(
          'Io',
          'preferer − r',
          'io prefere le aqua frigide',
          'Prefere es le presente de preferer.',
        ),
        GrammarExample(
          'Illa',
          'preferer − r',
          'illa prefere le pasta',
          'Con illa, prefere non cambia.',
        ),
      ],
    ),
  ],
  'lection6': [
    LessonGrammarTopic(
      'Loco',
      [0],
      [
        GrammarExample(
          'In',
          'le catto + in',
          'le catto es in le casa',
          'In indica le interior.',
        ),
        GrammarExample(
          'Sub',
          'le catto + sub',
          'le catto es sub le tabula',
          'Sub indica un position inferior.',
        ),
        GrammarExample(
          'Detra',
          'le catto + detra',
          'le catto es detra le casa',
          'Detra indica le parte posterior.',
        ),
      ],
    ),
    LessonGrammarTopic(
      'Le plus',
      [1],
      [
        GrammarExample(
          'Grande',
          'grande',
          'le plus grande citate',
          'Le plus indica le grado maximal in un gruppo.',
        ),
        GrammarExample(
          'Famose',
          'famose',
          'le plus famose museo',
          'Le mesme construction servi con famose.',
        ),
      ],
    ),
    LessonGrammarTopic(
      'Adjectivos',
      [2],
      [
        GrammarExample(
          'Un',
          'un museo',
          'un museo famose',
          'Famose describe le museo.',
        ),
        GrammarExample(
          'Plure',
          'multe museos',
          'multe museos famose',
          'Famose non recipe s.',
        ),
      ],
    ),
  ],
  'lection7': [
    LessonGrammarTopic(
      'Stationes',
      [0],
      [
        GrammarExample(
          'Estate',
          'in + le estate',
          'in le estate',
          'In introduce le station del anno.',
        ),
        GrammarExample(
          'Hiberno',
          'in + le hiberno',
          'in le hiberno',
          'Le station cambia; in resta.',
        ),
      ],
    ),
    LessonGrammarTopic(
      'Comparar',
      [1],
      [
        GrammarExample(
          'Plus',
          'calide',
          'plus calide que le hiberno',
          'Plus… que indica superioritate.',
        ),
        GrammarExample(
          'Minus',
          'frigide',
          'minus frigide que le hiberno',
          'Minus… que indica inferioritate.',
        ),
      ],
    ),
    LessonGrammarTopic(
      'Frequentia',
      [2],
      [
        GrammarExample(
          'Sempre',
          'io visita le parco',
          'io visita sempre le parco',
          'Sempre indica un frequentia constante.',
        ),
        GrammarExample(
          'A vices',
          'io visita le parco',
          'io visita le parco a vices',
          'A vices indica que le action non occurre sempre.',
        ),
      ],
    ),
  ],
  'lection8': [
    LessonGrammarTopic(
      'Numeros',
      [0],
      [
        GrammarExample(
          '20',
          '20',
          'vinti',
          'Le cifra e le parola representa le mesme numero.',
        ),
        GrammarExample(
          '35',
          '35',
          'trenta-cinque',
          'Le numeral non cambia pro genere.',
        ),
      ],
    ),
    LessonGrammarTopic(
      'Quantitate',
      [1],
      [
        GrammarExample(
          '10%',
          'un disconto + de + 10 per cento',
          'un disconto de 10 per cento',
          'De introduce le quantitate del disconto.',
        ),
        GrammarExample(
          '20%',
          'un disconto + de + 20 per cento',
          'un disconto de 20 per cento',
          'Le quantitate cambia; de resta.',
        ),
      ],
    ),
    LessonGrammarTopic(
      'Vole + infinitivo',
      [2],
      [
        GrammarExample(
          'Comprar',
          'io vole + comprar',
          'io vole comprar',
          'Post vole, comprar resta in infinitivo.',
        ),
        GrammarExample(
          'Pagar',
          'ille vole + pagar',
          'ille vole pagar',
          'Le prime verbo es conjugate; le secunde resta in infinitivo.',
        ),
      ],
    ),
    LessonGrammarTopic(
      'Digital',
      [3],
      [
        GrammarExample(
          'Un',
          'un systema',
          'un systema digital',
          'Digital es un adjectivo invariable.',
        ),
        GrammarExample(
          'Duo',
          'duo systemas',
          'duo systemas digital',
          'Solmente systema recipe le s del plural.',
        ),
      ],
    ),
  ],
  'lection9': [
    LessonGrammarTopic(
      'Futuro',
      [0],
      [
        GrammarExample(
          'Viagiar',
          'io va + viagiar',
          'io va viagiar in traino',
          'Va precede le infinitivo viagiar.',
        ),
        GrammarExample(
          'Partir',
          'nos va + partir',
          'nos va partir',
          'Va non cambia con nos; partir resta in infinitivo.',
        ),
      ],
    ),
    LessonGrammarTopic(
      'Durante',
      [1],
      [
        GrammarExample(
          'Le viage',
          'leger + durante + le viage',
          'io lege durante le viage',
          'Le lectura occurre in le mesme periodo que le viage.',
        ),
        GrammarExample(
          'Le vespere',
          'leger + durante + le vespere',
          'io lege durante le vespere',
          'Durante introduce le periodo del action.',
        ),
      ],
    ),
  ],
  'lection10': [
    LessonGrammarTopic(
      'Infinitivos',
      [0],
      [
        GrammarExample(
          'Leger',
          'io ama + leger',
          'io ama leger',
          'Leger es le action que io ama.',
        ),
        GrammarExample(
          'Jocar',
          'io ama + jocar',
          'io ama jocar',
          'Le infinitivo pote nominar un activitate.',
        ),
      ],
    ),
    LessonGrammarTopic(
      'Enumeration',
      [1],
      [
        GrammarExample(
          'Duo',
          'leger + jocar',
          'leger e jocar',
          'E uni le duo elementos.',
        ),
        GrammarExample(
          'Tres',
          'leger + jocar + programmar',
          'leger, jocar e programmar',
          'Usa un virgula inter le prime elementos e e ante le ultime.',
        ),
      ],
    ),
    LessonGrammarTopic(
      'Compania',
      [2],
      [
        GrammarExample(
          'Amicos',
          'io joca + con + mi amicos',
          'io joca con mi amicos',
          'Con indica le compania.',
        ),
        GrammarExample(
          'Ille',
          'io discute + con + ille',
          'io discute con ille',
          'Post con, le tertie persona conserva ille.',
        ),
      ],
    ),
    LessonGrammarTopic(
      'Quando',
      [3],
      [
        GrammarExample(
          'Tempore',
          'quando + io ha tempore',
          'io lege quando io ha tempore',
          'Quando uni le action al momento in que illo occurre.',
        ),
        GrammarExample(
          'A casa',
          'quando + io es a casa',
          'io lege quando io es a casa',
          'Le parte con quando indica le circumstantia temporal.',
        ),
      ],
    ),
  ],
};
