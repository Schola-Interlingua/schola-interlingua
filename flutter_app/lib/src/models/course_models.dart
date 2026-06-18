import 'package:flutter/material.dart';

enum CourseItemKind { lesson, reading, appendix, vocabulary }

enum LevelSectionKind { lectiones, vocabulario, lege, appendice }

class CourseLevel {
  const CourseLevel({
    required this.slug,
    required this.title,
    required this.sections,
  });

  final String slug;
  final String title;
  final List<CourseSection> sections;

  int get totalItems =>
      sections.fold<int>(0, (sum, section) => sum + section.items.length);
}

class CourseSection {
  const CourseSection({
    required this.title,
    required this.kind,
    required this.items,
  });

  final String title;
  final LevelSectionKind kind;
  final List<CourseItemRef> items;
}

class CourseItemRef {
  const CourseItemRef({
    required this.slug,
    required this.title,
    required this.kind,
    required this.icon,
  });

  final String slug;
  final String title;
  final CourseItemKind kind;
  final IconData icon;
}
