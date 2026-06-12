import 'package:flutter/material.dart';

import '../models/course_models.dart';

const List<CourseLevel> courseLevels = <CourseLevel>[
  CourseLevel(
    slug: 'nivel-1',
    title: 'Nivello 1',
    sections: <CourseSection>[
      CourseSection(
        title: 'Lectiones',
        kind: LevelSectionKind.lectiones,
        items: <CourseItemRef>[
          CourseItemRef(
            slug: 'lection1',
            title: 'Lection 1',
            kind: CourseItemKind.lesson,
            icon: Icons.school_rounded,
          ),
          CourseItemRef(
            slug: 'lection2',
            title: 'Lection 2',
            kind: CourseItemKind.lesson,
            icon: Icons.school_rounded,
          ),
          CourseItemRef(
            slug: 'lection3',
            title: 'Lection 3',
            kind: CourseItemKind.lesson,
            icon: Icons.school_rounded,
          ),
          CourseItemRef(
            slug: 'lection4',
            title: 'Lection 4',
            kind: CourseItemKind.lesson,
            icon: Icons.school_rounded,
          ),
          CourseItemRef(
            slug: 'lection5',
            title: 'Lection 5',
            kind: CourseItemKind.lesson,
            icon: Icons.school_rounded,
          ),
        ],
      ),
      CourseSection(
        title: 'Vocabulario',
        kind: LevelSectionKind.vocabulario,
        items: <CourseItemRef>[
          CourseItemRef(
            slug: 'basico1',
            title: 'Basico1',
            kind: CourseItemKind.vocabulary,
            icon: Icons.menu_book_rounded,
          ),
        ],
      ),
      CourseSection(
        title: 'Lege',
        kind: LevelSectionKind.lege,
        items: <CourseItemRef>[
          CourseItemRef(
            slug: 'mi-familia',
            title: 'Mi familia',
            kind: CourseItemKind.reading,
            icon: Icons.auto_stories_rounded,
          ),
          CourseItemRef(
            slug: 'un-die-in-scola',
            title: 'Un die in scola',
            kind: CourseItemKind.reading,
            icon: Icons.auto_stories_rounded,
          ),
        ],
      ),
    ],
  ),
  CourseLevel(
    slug: 'nivel-2',
    title: 'Nivello 2',
    sections: <CourseSection>[
      CourseSection(
        title: 'Lectiones',
        kind: LevelSectionKind.lectiones,
        items: <CourseItemRef>[
          CourseItemRef(
            slug: 'lection6',
            title: 'Lection 6',
            kind: CourseItemKind.lesson,
            icon: Icons.school_rounded,
          ),
          CourseItemRef(
            slug: 'lection7',
            title: 'Lection 7',
            kind: CourseItemKind.lesson,
            icon: Icons.school_rounded,
          ),
          CourseItemRef(
            slug: 'lection8',
            title: 'Lection 8',
            kind: CourseItemKind.lesson,
            icon: Icons.school_rounded,
          ),
          CourseItemRef(
            slug: 'lection9',
            title: 'Lection 9',
            kind: CourseItemKind.lesson,
            icon: Icons.school_rounded,
          ),
          CourseItemRef(
            slug: 'lection10',
            title: 'Lection 10',
            kind: CourseItemKind.lesson,
            icon: Icons.school_rounded,
          ),
        ],
      ),
      CourseSection(
        title: 'Vocabulario',
        kind: LevelSectionKind.vocabulario,
        items: <CourseItemRef>[
          CourseItemRef(
            slug: 'basico2',
            title: 'Basico2',
            kind: CourseItemKind.vocabulary,
            icon: Icons.menu_book_rounded,
          ),
        ],
      ),
      CourseSection(
        title: 'Lege',
        kind: LevelSectionKind.lege,
        items: <CourseItemRef>[
          CourseItemRef(
            slug: 'un-visita-al-mercato',
            title: 'Un visita al mercato',
            kind: CourseItemKind.reading,
            icon: Icons.auto_stories_rounded,
          ),
          CourseItemRef(
            slug: 'un-excursion-al-parco',
            title: 'Un excursion al parco',
            kind: CourseItemKind.reading,
            icon: Icons.auto_stories_rounded,
          ),
        ],
      ),
    ],
  ),
  CourseLevel(
    slug: 'nivel-3',
    title: 'Nivello 3',
    sections: <CourseSection>[
      CourseSection(
        title: 'Vocabulario',
        kind: LevelSectionKind.vocabulario,
        items: <CourseItemRef>[
          CourseItemRef(
            slug: 'phrases-quotidian',
            title: 'Phrases Quotidian',
            kind: CourseItemKind.vocabulary,
            icon: Icons.chat_bubble_outline_rounded,
          ),
          CourseItemRef(
            slug: 'alimentos',
            title: 'Alimentos',
            kind: CourseItemKind.vocabulary,
            icon: Icons.restaurant_rounded,
          ),
          CourseItemRef(
            slug: 'animales',
            title: 'Animales',
            kind: CourseItemKind.vocabulary,
            icon: Icons.pets_rounded,
          ),
          CourseItemRef(
            slug: 'adjectivos1',
            title: 'Adjectivos 1',
            kind: CourseItemKind.vocabulary,
            icon: Icons.format_size_rounded,
          ),
          CourseItemRef(
            slug: 'plurales',
            title: 'Plurales',
            kind: CourseItemKind.vocabulary,
            icon: Icons.copy_all_rounded,
          ),
          CourseItemRef(
            slug: 'esser-haber',
            title: 'Esser Haber',
            kind: CourseItemKind.vocabulary,
            icon: Icons.checklist_rounded,
          ),
          CourseItemRef(
            slug: 'vestimentos',
            title: 'Vestimentos',
            kind: CourseItemKind.vocabulary,
            icon: Icons.checkroom_rounded,
          ),
          CourseItemRef(
            slug: 'adjectivos-possessive',
            title: 'Adjectivos Possessive',
            kind: CourseItemKind.vocabulary,
            icon: Icons.favorite_outline_rounded,
          ),
          CourseItemRef(
            slug: 'colores',
            title: 'Colores',
            kind: CourseItemKind.vocabulary,
            icon: Icons.palette_outlined,
          ),
        ],
      ),
      CourseSection(
        title: 'Lege',
        kind: LevelSectionKind.lege,
        items: <CourseItemRef>[
          CourseItemRef(
            slug: 'le-casa-de-libros',
            title: 'Le casa de libros',
            kind: CourseItemKind.reading,
            icon: Icons.auto_stories_rounded,
          ),
          CourseItemRef(
            slug: 'un-viage-in-tren',
            title: 'Un viage in tren',
            kind: CourseItemKind.reading,
            icon: Icons.auto_stories_rounded,
          ),
        ],
      ),
    ],
  ),
  CourseLevel(
    slug: 'nivel-4',
    title: 'Nivello 4',
    sections: <CourseSection>[
      CourseSection(
        title: 'Vocabulario',
        kind: LevelSectionKind.vocabulario,
        items: <CourseItemRef>[
          CourseItemRef(
            slug: 'presente1',
            title: 'Presente 1',
            kind: CourseItemKind.vocabulary,
            icon: Icons.schedule_rounded,
          ),
          CourseItemRef(
            slug: 'demonstrativos1',
            title: 'Demonstrativos 1',
            kind: CourseItemKind.vocabulary,
            icon: Icons.ads_click_rounded,
          ),
          CourseItemRef(
            slug: 'conjunctiones',
            title: 'Conjunctiones',
            kind: CourseItemKind.vocabulary,
            icon: Icons.account_tree_outlined,
          ),
          CourseItemRef(
            slug: 'questiones',
            title: 'Questiones',
            kind: CourseItemKind.vocabulary,
            icon: Icons.help_outline_rounded,
          ),
          CourseItemRef(
            slug: 'verbos2',
            title: 'Verbos 2',
            kind: CourseItemKind.vocabulary,
            icon: Icons.directions_run_rounded,
          ),
          CourseItemRef(
            slug: 'adjectivos2',
            title: 'Adjectivos 2',
            kind: CourseItemKind.vocabulary,
            icon: Icons.format_size_rounded,
          ),
          CourseItemRef(
            slug: 'prepositiones',
            title: 'Prepositiones',
            kind: CourseItemKind.vocabulary,
            icon: Icons.alt_route_rounded,
          ),
          CourseItemRef(
            slug: 'numeros',
            title: 'Numeros',
            kind: CourseItemKind.vocabulary,
            icon: Icons.pin_rounded,
          ),
          CourseItemRef(
            slug: 'familia',
            title: 'Familia',
            kind: CourseItemKind.vocabulary,
            icon: Icons.group_outlined,
          ),
        ],
      ),
      CourseSection(
        title: 'Lege',
        kind: LevelSectionKind.lege,
        items: <CourseItemRef>[
          CourseItemRef(
            slug: 'le-inventores',
            title: 'Le inventores',
            kind: CourseItemKind.reading,
            icon: Icons.auto_stories_rounded,
          ),
          CourseItemRef(
            slug: 'le-linguas-del-mundo',
            title: 'Le linguas del mundo',
            kind: CourseItemKind.reading,
            icon: Icons.auto_stories_rounded,
          ),
        ],
      ),
    ],
  ),
  CourseLevel(
    slug: 'nivel-5',
    title: 'Nivello 5',
    sections: <CourseSection>[
      CourseSection(
        title: 'Vocabulario',
        kind: LevelSectionKind.vocabulario,
        items: <CourseItemRef>[
          CourseItemRef(
            slug: 'possessives2',
            title: 'Possessives 2',
            kind: CourseItemKind.vocabulary,
            icon: Icons.favorite_outline_rounded,
          ),
          CourseItemRef(
            slug: 'verbos3',
            title: 'Verbos 3',
            kind: CourseItemKind.vocabulary,
            icon: Icons.directions_run_rounded,
          ),
          CourseItemRef(
            slug: 'datas-tempore',
            title: 'Datas Tempore',
            kind: CourseItemKind.vocabulary,
            icon: Icons.calendar_month_rounded,
          ),
          CourseItemRef(
            slug: 'verbos4',
            title: 'Verbos 4',
            kind: CourseItemKind.vocabulary,
            icon: Icons.directions_run_rounded,
          ),
          CourseItemRef(
            slug: 'adverbios1',
            title: 'Adverbios 1',
            kind: CourseItemKind.vocabulary,
            icon: Icons.rocket_launch_outlined,
          ),
        ],
      ),
      CourseSection(
        title: 'Lege',
        kind: LevelSectionKind.lege,
        items: <CourseItemRef>[
          CourseItemRef(
            slug: 'proque-interlingua-es-utile',
            title: 'Proque Interlingua es utile',
            kind: CourseItemKind.reading,
            icon: Icons.auto_stories_rounded,
          ),
          CourseItemRef(
            slug: 'un-futuro-interlingual',
            title: 'Un futuro interlingual',
            kind: CourseItemKind.reading,
            icon: Icons.auto_stories_rounded,
          ),
        ],
      ),
    ],
  ),
  CourseLevel(
    slug: 'nivel-6',
    title: 'Nivello 6',
    sections: <CourseSection>[
      CourseSection(
        title: 'Vocabulario',
        kind: LevelSectionKind.vocabulario,
        items: <CourseItemRef>[
          CourseItemRef(
            slug: 'verbos5',
            title: 'Verbos 5',
            kind: CourseItemKind.vocabulary,
            icon: Icons.directions_run_rounded,
          ),
          CourseItemRef(
            slug: 'adverbios2',
            title: 'Adverbios 2',
            kind: CourseItemKind.vocabulary,
            icon: Icons.rocket_launch_outlined,
          ),
          CourseItemRef(
            slug: 'occupationes',
            title: 'Occupationes',
            kind: CourseItemKind.vocabulary,
            icon: Icons.work_outline_rounded,
          ),
          CourseItemRef(
            slug: 'verbos6',
            title: 'Verbos 6',
            kind: CourseItemKind.vocabulary,
            icon: Icons.directions_run_rounded,
          ),
          CourseItemRef(
            slug: 'negativos',
            title: 'Negativos',
            kind: CourseItemKind.vocabulary,
            icon: Icons.block_rounded,
          ),
          CourseItemRef(
            slug: 'adverbios3',
            title: 'Adverbios 3',
            kind: CourseItemKind.vocabulary,
            icon: Icons.rocket_launch_outlined,
          ),
          CourseItemRef(
            slug: 'prender-casa',
            title: 'Prender Casa',
            kind: CourseItemKind.vocabulary,
            icon: Icons.home_outlined,
          ),
          CourseItemRef(
            slug: 'technologia',
            title: 'Technologia',
            kind: CourseItemKind.vocabulary,
            icon: Icons.memory_rounded,
          ),
        ],
      ),
    ],
  ),
];
