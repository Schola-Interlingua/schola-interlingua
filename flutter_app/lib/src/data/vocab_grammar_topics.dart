import 'grammar_lessons.dart';
import 'lesson_grammar_topics.dart';

/// Short notes tied to vocabulary units, reviewed against the attached UMI sources.
const vocabGrammarTopics = <String, List<LessonGrammarTopic>>{
  "basico1": [
    LessonGrammarTopic(
      "Le e un",
      [],
      [
        GrammarExample(
          "Un",
          "un puero",
          "un puera",
          "Le persona cambia; un resta identic.",
        ),
        GrammarExample(
          "Le",
          "le homine",
          "le femina",
          "Le es le mesme ante homine e femina.",
        ),
      ],
      explanation:
          "Le identifica un referente; un introduce un referente non ancora identificate. Le articulo non cambia pro genere. Ante un substantivo, usa un, non una.",
      source:
          "https://www.interlingua.com/grammatica/grammatica/articulo-indefinite/",
      sections: "§§17–21",
    ),
  ],
  "basico2": [
    LessonGrammarTopic(
      "Qui parla?",
      [],
      [
        GrammarExample(
          "Singular",
          "illa lege",
          "illas lege",
          "Le pronomine passa al plural, ma lege resta identic.",
        ),
        GrammarExample(
          "Nos",
          "io scribe",
          "nos scribe",
          "Nos include le parlator con altere personas.",
        ),
      ],
      explanation:
          "Io e nos include le parlator. Ille, illa e illo reprende un persona o cosa. In plural: illes, illas, illos. Le verbo non cambia con le persona.",
      source:
          "https://www.interlingua.com/grammatica/grammatica/pronomines-personal/",
      sections: "§§56–63",
    ),
  ],
  "adjectivos1": [
    LessonGrammarTopic(
      "Adjectivo o adverbio?",
      [],
      [
        GrammarExample(
          "Multe",
          "personas",
          "multe personas",
          "Multe indica le quantitate de personas.",
        ),
        GrammarExample(
          "Multo",
          "personas bon",
          "personas multo bon",
          "Multo indica le grado de bon.",
        ),
        GrammarExample(
          "Plural",
          "le puera es belle",
          "le pueras es belle",
          "Belle non recipe -s.",
        ),
      ],
      explanation:
          "Un adjectivo describe un nomine e non cambia in plural. Multo modifica un adjectivo o un action; multe describe un quantitate ante un nomine.",
      source: "https://www.interlingua.com/grammatica/grammatica/adverbios/",
      sections: "§47; adjectivos: §32",
    ),
  ],
  "plurales": [
    LessonGrammarTopic(
      "Formar le plural",
      [],
      [
        GrammarExample(
          "Vocal",
          "le catto",
          "le cattos",
          "Catto fini in vocal: adde -s.",
        ),
        GrammarExample(
          "Consonante",
          "le can",
          "le canes",
          "Can fini in consonante: adde -es.",
        ),
        GrammarExample(
          "Adjectivo",
          "le grande can",
          "le grande canes",
          "Solmente can cambia al plural; grande e le non cambia.",
        ),
      ],
      explanation:
          "Post un vocal, adde -s; post un consonante, adde -es. Un -c final deveni -ch ante -es. Le articulo le e le adjectivos resta invariable.",
      source: "https://www.interlingua.com/grammatica/grammatica/plurales/",
      sections: "§25; adjectivos: §32",
    ),
  ],
  "esser-haber": [
    LessonGrammarTopic(
      "Es, ha e il ha",
      [],
      [
        GrammarExample(
          "Es",
          "esser",
          "illa es actrice",
          "Es identifica le profession.",
        ),
        GrammarExample(
          "Ha",
          "haber",
          "nos ha duo libros",
          "Ha indica lo que nos possede.",
        ),
        GrammarExample(
          "Il ha",
          "duo libros existe hic",
          "il ha duo libros",
          "Il ha exprime existentia, anque in plural.",
        ),
      ],
      explanation:
          "Es describe o identifica; ha indica possession. Il ha annuncia le existentia de un cosa o de plure cosas. Es e ha non cambia con le persona.",
      source:
          "https://www.interlingua.com/grammatica/grammatica/tempore-presente/",
      sections: "§101; particulas: il ha",
    ),
  ],
  "adjectivos-possessive": [
    LessonGrammarTopic(
      "Ante le nomine",
      [],
      [
        GrammarExample(
          "Mi",
          "mi libro",
          "mi libros",
          "Mi resta mi quando il ha plure libros.",
        ),
        GrammarExample(
          "Lor",
          "su infantes",
          "lor infantes",
          "Su: un possessor. Lor: plure possessores; non depende del numero de infantes.",
        ),
      ],
      explanation:
          "Usa mi, tu, su, nostre, vostre e lor ante le nomine, normalmente sin articulo. Le possessivo indica le possessor e non cambia con le numero del cosas possedite.",
      source: "https://www.interlingua.com/grammatica/grammatica/possessivos/",
      sections: "§§64–65",
    ),
  ],
  "colores": [
    LessonGrammarTopic(
      "Le color non cambia",
      [],
      [
        GrammarExample(
          "Blanc",
          "le vestimento blanc",
          "le vestimentos blanc",
          "Vestimento recipe -s; blanc resta invariable.",
        ),
        GrammarExample(
          "Verde",
          "le tortuca verde",
          "le tortucas verde",
          "Verde describe ambe phrases sin cambiar.",
        ),
      ],
      explanation:
          "Usate como adjectivos, le colores non cambia pro genere o numero. Le nomine pote esser singular o plural sin cambiar le parola del color.",
      source: "https://www.interlingua.com/grammatica/grammatica/adjectivos/",
      sections: "§§32–33",
    ),
  ],
  "presente1": [
    LessonGrammarTopic(
      "Presente e infinitivo",
      [],
      [
        GrammarExample(
          "Presente",
          "comprar",
          "nos compra",
          "Remove -r; compra es le mesme pro omne personas.",
        ),
        GrammarExample(
          "Poter",
          "io parla interlingua",
          "io pote parlar interlingua",
          "Pote exprime capacitate; parlar conserva -r.",
        ),
        GrammarExample(
          "Deber",
          "io va",
          "io debe ir",
          "Post debe, usa le infinitivo ir.",
        ),
      ],
      explanation:
          "Pro le presente regular, remove solmente le -r del infinitivo. Post poter, deber, voler e soler, le secunde verbo resta in infinitivo, sin preposition.",
      source: "https://www.interlingua.com/grammatica/grammatica/infinitivo/",
      sections: "§88; presente: §99",
    ),
  ],
  "demonstrativos1": [
    LessonGrammarTopic(
      "Iste, ille, isto",
      [],
      [
        GrammarExample(
          "Ante le nomine",
          "iste libro",
          "iste libros",
          "Iste non recipe -s ante libros.",
        ),
        GrammarExample(
          "Neutre",
          "iste cosa",
          "isto",
          "Isto representa un cosa sin nominar lo.",
        ),
        GrammarExample(
          "Personas",
          "iste feminas",
          "istas",
          "Como pronomine feminin plural, iste deveni istas.",
        ),
      ],
      explanation:
          "Ante un nomine, iste indica proximitate e ille distantia; illos resta invariable. Sin le nomine, le pronomine pote variar: isto, illo, istes, illas, illos.",
      source:
          "https://www.interlingua.com/grammatica/grammatica/demonstrativos/",
      sections: "§§78–79",
    ),
  ],
  "conjunctiones": [
    LessonGrammarTopic(
      "Liga le ideas",
      [],
      [
        GrammarExample(
          "Contrasto",
          "io lege / illa dormi",
          "io lege, ma illa dormi",
          "Ma connecte le ideas per un contrasto.",
        ),
        GrammarExample(
          "Causa",
          "io bibe / io ha sete",
          "io bibe perque io ha sete",
          "Perque introduce le ration.",
        ),
        GrammarExample(
          "Condition",
          "illa bibe / io bibe",
          "si illa bibe, io bibe",
          "Si presenta le condition pro le secunde action.",
        ),
      ],
      explanation:
          "E adde; o presenta un alternativa; ma o sed marca un contrasto. Perque e proque introduce un causa. Si introduce un condition.",
      source:
          "https://www.interlingua.com/grammatica/grammatica/lista-de-particulas-grammatic/",
      sections: "§134 · particulas grammatic",
    ),
  ],
  "questiones": [
    LessonGrammarTopic(
      "Qual information manca?",
      [],
      [
        GrammarExample(
          "Loco",
          "le libro es hic",
          "ubi es le libro?",
          "Ubi substitue le loco que nos non cognosce.",
        ),
        GrammarExample(
          "Quantitate",
          "io ha tres libros",
          "quante libros ha tu?",
          "Quante se usa ante libros.",
        ),
        GrammarExample(
          "Precio",
          "illo costa dece euros",
          "quanto costa illo?",
          "Quanto modifica costa; non precede un nomine.",
        ),
      ],
      explanation:
          "Ubi demanda un loco; quando un tempore; qui un persona; que un cosa. Quante precede un nomine de quantitate; quanto pote modificar un verbo.",
      source:
          "https://www.interlingua.com/grammatica/grammatica/tabula-de-conjugation/",
      sections: "§116; particulas: quante, quanto",
    ),
  ],
  "verbos2": [
    LessonGrammarTopic(
      "Le presente in -i",
      [],
      [
        GrammarExample(
          "Dormir",
          "dormir",
          "io dormi",
          "Remove solmente -r; non cambia -i a -a.",
        ),
        GrammarExample(
          "Plural",
          "ille mori",
          "illes mori",
          "Mori resta identic con le subjecto plural.",
        ),
      ],
      explanation:
          "Un infinitivo in -ir perde solmente le -r: dormir → dormi, morir → mori. Le vocal i resta e le forma non cambia con le subjecto.",
      source:
          "https://www.interlingua.com/grammatica/grammatica/tempore-presente/",
      sections: "§99",
    ),
  ],
  "adjectivos2": [
    LessonGrammarTopic(
      "Position e accordo",
      [],
      [
        GrammarExample(
          "Position",
          "un longe viage",
          "un viage longe",
          "Ambe positiones es possibile; le signification basic resta le mesme.",
        ),
        GrammarExample(
          "Plural",
          "un persona gentil",
          "duo personas gentil",
          "Gentil non recipe -s.",
        ),
      ],
      explanation:
          "Le adjectivo pote preceder o sequer le nomine; post le nomine es le position plus frequente. Le adjectivo non cambia pro genere o numero.",
      source: "https://www.interlingua.com/grammatica/grammatica/adjectivos/",
      sections: "§§32–33",
    ),
  ],
  "prepositiones": [
    LessonGrammarTopic(
      "Relationes",
      [],
      [
        GrammarExample(
          "In",
          "le libro / le bursa",
          "le libro es in le bursa",
          "In situa le libro intra le bursa.",
        ),
        GrammarExample(
          "A + le",
          "io va a + le parco",
          "io va al parco",
          "A indica le destination; a + le deveni al.",
        ),
        GrammarExample(
          "De + le",
          "le libro de + le puero",
          "le libro del puero",
          "De exprime possession; de + le deveni del.",
        ),
      ],
      explanation:
          "Le preposition liga un nomine o un pronomine al resto del phrase. In situa; a pote indicar un destination; de pote indicar possession o origine. A + le e de + le se contrahe a al e del.",
      source:
          "https://www.interlingua.com/grammatica/grammatica/lista-de-particulas-grammatic/",
      sections: "§134; contractiones: §17",
    ),
  ],
  "numeros": [
    LessonGrammarTopic(
      "Combinar numeros",
      [],
      [
        GrammarExample(
          "21",
          "vinti + un",
          "vinti-un homines",
          "Vinti-un conta homines; anque vinti e un es possibile.",
        ),
        GrammarExample(
          "200",
          "duo × cento",
          "duo centos",
          "Cento functiona como substantivo e recipe -s.",
        ),
        GrammarExample(
          "232",
          "200 + 30 + 2",
          "duo centos trenta-duo",
          "Pone le valores plus grande ante le plus parve.",
        ),
      ],
      explanation:
          "Sub cento, liga deces e unes per un tracto de union o per e. Pro multiplos de cento, usa un multiplicator plus centos. Le numeral precede le nomine que illo conta.",
      source: "https://www.interlingua.com/grammatica/grammatica/cardinales/",
      sections: "§§118–122",
    ),
  ],
  "possessives2": [
    LessonGrammarTopic(
      "Sin repeter le nomine",
      [],
      [
        GrammarExample(
          "Un libro",
          "mi libro",
          "le mie",
          "Le mie substitue le nomine singular.",
        ),
        GrammarExample(
          "Plure libros",
          "mi libros",
          "le mies",
          "Le -s corresponde al plure libros.",
        ),
        GrammarExample(
          "Nostre",
          "nostre libros",
          "le nostres",
          "Ante libros: nostre. Sin libros: le nostres.",
        ),
      ],
      explanation:
          "Quando le nomine es omittite, usa le mie, le tue, le sue, le nostre, le vostre o le lore. Pro plure cosas, adde -s al forma pronominal.",
      source: "https://www.interlingua.com/grammatica/grammatica/possessivos/",
      sections: "§64",
    ),
  ],
  "verbos3": [
    LessonGrammarTopic(
      "Preposition e infinitivo",
      [],
      [
        GrammarExample(
          "A",
          "apprender + parlar",
          "apprender a parlar",
          "Apprender a es un construction con un objectivo.",
        ),
        GrammarExample(
          "Pro",
          "nos mangia / viver",
          "nos mangia pro viver",
          "Pro exprime le scopo del action.",
        ),
        GrammarExample(
          "Sin preposition",
          "io vole / dormir",
          "io vole dormir",
          "Post voler, nulle preposition precede le infinitivo.",
        ),
      ],
      explanation:
          "Le connexion depende del construction. A pote marcar un objectivo; pro un scopo; de es le preposition neutre. Post un verbo transitive, un infinitivo dependente pote apparer sin preposition.",
      source: "https://www.interlingua.com/grammatica/grammatica/infinitivo/",
      sections: "§§85–89",
    ),
  ],
  "datas-tempore": [
    LessonGrammarTopic(
      "Datas e horas",
      [],
      [
        GrammarExample(
          "Data",
          "12 / novembre",
          "le dece-duo de novembre",
          "Le die es un cardinal, non un ordinal.",
        ),
        GrammarExample(
          "Hora",
          "3:30",
          "il es tres e medie",
          "E medie adde un medie hora.",
        ),
        GrammarExample(
          "Evento",
          "le reunion / 3:00",
          "le reunion es a tres horas",
          "A introduce le hora del evento.",
        ),
      ],
      explanation:
          "In datas, le die se exprime per un cardinal; le prime es anque possibile pro le die 1. Pro le hora, usa il es; pro indicar le hora de un evento, usa a.",
      source:
          "https://www.interlingua.com/grammatica/grammatica/multiplicativos/",
      sections: "§§132–133",
    ),
  ],
  "verbos4": [
    LessonGrammarTopic(
      "Action reflexive",
      [],
      [
        GrammarExample(
          "Io",
          "levar se",
          "io me leva",
          "Me corresponde al subjecto io.",
        ),
        GrammarExample(
          "Nos",
          "levar se",
          "nos nos leva",
          "Le prime nos es subjecto; le secunde es reflexive.",
        ),
      ],
      explanation:
          "Quando le action concerne le subjecto mesme, usa me, te, se, nos, vos, se. Ante un verbo finite, le pronomine normalmente precede le verbo; con le infinitivo, illo pote sequer lo.",
      source: "https://www.interlingua.com/grammatica/grammatica/reflexivos/",
      sections: "§§66–70",
    ),
  ],
  "adverbios1": [
    LessonGrammarTopic(
      "Comparar un action",
      [],
      [
        GrammarExample(
          "Ben",
          "io scribe",
          "io scribe ben",
          "Ben describe le maniera de scriber.",
        ),
        GrammarExample(
          "Melio",
          "io scribe ben",
          "io scribe melio",
          "Melio introduce un comparation del maniera de scriber.",
        ),
      ],
      explanation:
          "Ben describe como un action se face. Melio es un comparative de ben; plus ben es anque possibile. Un adjectivo describe un nomine, un adverbio pote describer un verbo.",
      source: "https://www.interlingua.com/grammatica/grammatica/adverbios/",
      sections: "§§47, 49–50",
    ),
  ],
  "verbos5": [
    LessonGrammarTopic(
      "Pronomine e infinitivo",
      [],
      [
        GrammarExample(
          "Io",
          "laborar",
          "io vole laborar",
          "Le intention es vole; le action resta laborar.",
        ),
        GrammarExample(
          "Reflexive",
          "effortiar se",
          "io me effortia",
          "Me corresponde a io; le verbo non cambia pro persona.",
        ),
      ],
      explanation:
          "Post un verbo como voler, le action sequente es un infinitivo sin preposition. In un construction reflexive, le pronomine corresponde al subjecto e pote sequer le infinitivo.",
      source: "https://www.interlingua.com/grammatica/grammatica/infinitivo/",
      sections: "§88; reflexivos: §§66–70",
    ),
  ],
  "adverbios2": [
    LessonGrammarTopic(
      "Derivar con -mente",
      [],
      [
        GrammarExample(
          "Natural",
          "natural",
          "naturalmente",
          "Adde -mente al forma complete.",
        ),
        GrammarExample(
          "Simple",
          "simple",
          "simplemente",
          "Le -e final de simple resta ante -mente.",
        ),
        GrammarExample(
          "Exacte",
          "exacte",
          "exactemente",
          "Non remove -e: exacte + mente.",
        ),
      ],
      explanation:
          "Adde -mente al adjectivo complete, sin remover le -e final. Le adverbio indica como un action se face. Non omne adverbio es formate con -mente: ben e melio ha formas proprie.",
      source: "https://www.interlingua.com/grammatica/grammatica/adverbios/",
      sections: "§§45–47",
    ),
  ],
  "verbos6": [
    LessonGrammarTopic(
      "Le action e le persona",
      [],
      [
        GrammarExample(
          "Io",
          "rasar se",
          "io me rasa",
          "Io face le action e me indica le mesme persona.",
        ),
        GrammarExample(
          "Tu",
          "rasar se",
          "tu te rasa",
          "Te corresponde a tu; rasa non cambia.",
        ),
        GrammarExample(
          "Objecto",
          "illa manca a me",
          "illa me manca",
          "Me indica le persona qui senti le absentia de illa; non es un reflexivo de illa.",
        ),
      ],
      explanation:
          "In rasar se, le pronomine indica que le action concerne le subjecto mesme. Un pronomine objecto pote anque indicar un altere persona: illa me manca.",
      source: "https://www.interlingua.com/grammatica/grammatica/reflexivos/",
      sections: "§§66–70; personal: §§62–63",
    ),
  ],
  "negativos": [
    LessonGrammarTopic(
      "Non, nulle e nemo",
      [],
      [
        GrammarExample(
          "Non",
          "io vole illo",
          "io non vole illo",
          "Non nega vole.",
        ),
        GrammarExample(
          "Objecto",
          "io lo vole",
          "io non lo vole",
          "Ordine: subjecto, non, pronomine, verbo.",
        ),
        GrammarExample(
          "Nemo",
          "un persona es hic",
          "nemo es hic",
          "Nemo es le subjecto; illo significa nulle persona.",
        ),
      ],
      explanation:
          "Non precede le verbo que illo nega. Nulle precede un nomine; nemo significa nulle persona. Si un pronomine objecto precede le verbo, non se pone ante le pronomine.",
      source: "https://www.interlingua.com/grammatica/grammatica/adverbios/",
      sections: "§53; particulas: nulle, nemo",
    ),
  ],
  "adverbios3": [
    LessonGrammarTopic(
      "Como se face?",
      [],
      [
        GrammarExample(
          "Lente",
          "lente",
          "lentemente",
          "Le -e de lente resta; lentemente describe le velocitate del action.",
        ),
        GrammarExample(
          "Clar",
          "clar",
          "clarmente",
          "Clar non ha un -e final: adde directemente -mente.",
        ),
        GrammarExample(
          "Post -c",
          "automatic",
          "automaticamente",
          "Insere -a- inter -c e -mente.",
        ),
      ],
      explanation:
          "Le adverbio modifica un action o un grado. Pro formar lo, adde -mente al adjectivo complete. Post un -c final, insere -a- ante -mente.",
      source: "https://www.interlingua.com/grammatica/grammatica/adverbios/",
      sections: "§§45, 52",
    ),
  ],
};
