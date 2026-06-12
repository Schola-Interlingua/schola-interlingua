import '../models/content_models.dart';

const Map<String, ReadingContent> readingContent = <String, ReadingContent>{
  'mi-familia': ReadingContent(
    slug: 'mi-familia',
    title: 'Mi familia',
    imageAsset: 'assets/images/lectura-mi-familia.png',
    paragraphs: <String>[
      'Mi familia es parve, ma multo unite. Nos habita in un casa in le suburbios de un citate tranquille. In mi familia, il ha quatro personas: mi patre, mi matre, mi soror minor e io.',
      'Mi patre labora como medico in un hospital local. Ille es un homine intelligente e dedicate, qui ama su profession e cuida ben su pacientes. Cata die, ille reveni tarde del labor, ma il trova sempre tempore pro parlar con nos e narrar historias amusante.',
      'Mi matre es un femina ben organisate e creative. Illa es un inseniatora in un schola primari. Illa ama inseniar le infantes e sempre ha ideas nove pro facer le lectiones interessante. In le casa, illa prepara delicat repas e decora le ambiente con flores e colores vivide.',
      'Mi soror ha dece annos. Illa es curiose, energic e multo loquace. Illa ama leger libros de aventuras, jocar con su amicas, e scriber historias imaginari. Illa vole devenir scriptrice in le futuro. Quando nos ha tempore libere, nos joca inseme o guarda filmes.',
      'Io es le primogenite. Io ha dece-septe annos e studia in le liceo. Mi materias favorite es historia e linguas. Io ha un interesse special in Interlingua, proque es un lingua que nos uni con multe culturas e es facile a apprender.',
    ],
  ),
};

const Map<String, AppendixContent> appendixContent = <String, AppendixContent>{
  'grammatica': AppendixContent(
    slug: 'grammatica',
    title: 'Grammatica de Interlingua',
    sections: <AppendixSection>[
      AppendixSection(
        title: '1. Verbo',
        paragraphs: <String>[
          'Il ha tres typos de verbos in Interlingua: illos que termina in -ar, -er e -ir. Le conjugation es regular e non varia secundo le persona o le numero.',
          'Le verbos auxiliar como esser, haber e vader ha formas breve: es, ha, va. Illes se usa pro formar tempores composite o expressiones impersonal.',
        ],
        bullets: <String>[
          '-r (infinitive): parlar, vider, audir',
          '-a (presente): io parla, tu parla, nos parla',
          '-va (imperfecte): io parlava, tu parlava',
          '-ra (futuro): io parlara, tu parlara',
          '-te (participio passate): parlate, vidite, audite',
        ],
      ),
      AppendixSection(
        title: '2. Grados de adjectivos e adverbios',
        paragraphs: <String>[
          'On forma le comparativo e le superlativo anteponente plus o le plus al adjectivo o adverbio: plus grande, le plus grande, plus rapidemente.',
        ],
        bullets: <String>[
          '-issime: bellissime',
          '-issimo: fortissimo',
          'multo: multo rapide',
        ],
      ),
      AppendixSection(
        title: '3. Pronomines personal',
        paragraphs: <String>[
          'Le pronomines personal include subjecto, objecto, possessive e formas independente.',
        ],
        bullets: <String>[
          'Subjecto: io, tu, ille, illa, illo, on, nos, vos, illes',
          'Objecto: me, te, le, la, lo, se, nos, vos, les, las, los',
          'Possessive: mi, tu, su, nostre, vostre, lor',
        ],
      ),
      AppendixSection(
        title: '4. Articulos e substantivos',
        paragraphs: <String>[
          'Il ha articulos definite e indefinite: un e le. Le plural se forma con -s post vocal e -es post consonante.',
        ],
      ),
    ],
  ),
  'numeros': AppendixContent(
    slug: 'numeros',
    title: 'Numeros',
    sections: <AppendixSection>[
      AppendixSection(
        title: 'Cardinales',
        paragraphs: <String>[
          'un, duo, tres, quatro, cinque, sex, septe, octo, novem, dece',
        ],
      ),
    ],
  ),
  'contos': AppendixContent(
    slug: 'contos',
    title: 'Contos legite',
    sections: <AppendixSection>[
      AppendixSection(
        title: 'Collection',
        paragraphs: <String>[
          'Iste pagina servira pro reunir contos e altere materiales de lectura migrate al nove frontend.',
        ],
      ),
    ],
  ),
};

const Map<String, VocabMeaning> vocabMeanings = <String, VocabMeaning>{
  'familia': VocabMeaning(
    term: 'familia',
    meanings: <String, String>{
      'es': 'familia',
      'en': 'family',
      'it': 'famiglia',
      'pt': 'família',
    },
  ),
  'patre': VocabMeaning(
    term: 'patre',
    meanings: <String, String>{
      'es': 'padre',
      'en': 'father',
      'it': 'padre',
      'pt': 'pai',
    },
  ),
  'matre': VocabMeaning(
    term: 'matre',
    meanings: <String, String>{
      'es': 'madre',
      'en': 'mother',
      'it': 'madre',
      'pt': 'mãe',
    },
  ),
  'soror': VocabMeaning(
    term: 'soror',
    meanings: <String, String>{
      'es': 'hermana',
      'en': 'sister',
      'it': 'sorella',
      'pt': 'irmã',
    },
  ),
  'casa': VocabMeaning(
    term: 'casa',
    meanings: <String, String>{
      'es': 'casa',
      'en': 'house',
      'it': 'casa',
      'pt': 'casa',
    },
  ),
  'citate': VocabMeaning(
    term: 'citate',
    meanings: <String, String>{
      'es': 'ciudad',
      'en': 'city',
      'it': 'città',
      'pt': 'cidade',
    },
  ),
  'medico': VocabMeaning(
    term: 'medico',
    meanings: <String, String>{
      'es': 'médico',
      'en': 'doctor',
      'it': 'medico',
      'pt': 'médico',
    },
  ),
  'hospital': VocabMeaning(
    term: 'hospital',
    meanings: <String, String>{
      'es': 'hospital',
      'en': 'hospital',
      'it': 'ospedale',
      'pt': 'hospital',
    },
  ),
  'homine': VocabMeaning(
    term: 'homine',
    meanings: <String, String>{
      'es': 'hombre',
      'en': 'man',
      'it': 'uomo',
      'pt': 'homem',
    },
  ),
  'schola': VocabMeaning(
    term: 'schola',
    meanings: <String, String>{
      'es': 'escuela',
      'en': 'school',
      'it': 'scuola',
      'pt': 'escola',
    },
  ),
  'infantes': VocabMeaning(
    term: 'infantes',
    meanings: <String, String>{
      'es': 'niños',
      'en': 'children',
      'it': 'bambini',
      'pt': 'crianças',
    },
  ),
  'libros': VocabMeaning(
    term: 'libros',
    meanings: <String, String>{
      'es': 'libros',
      'en': 'books',
      'it': 'libri',
      'pt': 'livros',
    },
  ),
  'historia': VocabMeaning(
    term: 'historia',
    meanings: <String, String>{
      'es': 'historia',
      'en': 'history',
      'it': 'storia',
      'pt': 'história',
    },
  ),
  'linguas': VocabMeaning(
    term: 'linguas',
    meanings: <String, String>{
      'es': 'idiomas',
      'en': 'languages',
      'it': 'lingue',
      'pt': 'línguas',
    },
  ),
  'interlingua': VocabMeaning(
    term: 'interlingua',
    meanings: <String, String>{
      'es': 'interlingua',
      'en': 'Interlingua',
      'it': 'Interlingua',
      'pt': 'Interlíngua',
    },
  ),
  'gratia': VocabMeaning(
    term: 'gratia',
    meanings: <String, String>{
      'es': 'gracia',
      'en': 'grace',
      'it': 'grazia',
      'pt': 'graça',
    },
  ),
};
