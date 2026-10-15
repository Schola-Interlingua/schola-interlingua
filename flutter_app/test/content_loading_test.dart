import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:schola_interlingua_flutter/src/screens/reading_screen.dart';
import 'package:schola_interlingua_flutter/src/screens/lesson_screen.dart';
import 'package:schola_interlingua_flutter/src/screens/appendix_screen.dart';

void main() {
  final screens = <String, Widget Function(String)>{
    'reading': (slug) => ReadingScreen(slug: slug),
    'lesson': (slug) => LessonScreen(slug: slug),
    'appendix': (slug) => AppendixScreen(slug: slug),
  };
  for (final entry in screens.entries) {
    testWidgets('${entry.key} reuses its load until the route changes', (
      tester,
    ) async {
      Widget app(String slug, Brightness brightness) => MaterialApp(
        theme: ThemeData(brightness: brightness),
        home: Scaffold(body: entry.value(slug)),
      );
      // Missing content exercises the same load lifecycle without audio plugins.
      await tester.pumpWidget(app('lection-missing', Brightness.light));
      final finder = find.byWidgetPredicate(
        (widget) => widget is FutureBuilder,
      );
      final initial = (tester.widget(finder) as FutureBuilder).future;
      await tester.pumpAndSettle();
      await tester.pumpWidget(app('lection-missing', Brightness.dark));
      expect(
        identical((tester.widget(finder) as FutureBuilder).future, initial),
        isTrue,
      );
      expect(find.byType(CircularProgressIndicator), findsNothing);
      await tester.pumpWidget(app('lection-other', Brightness.dark));
      expect(
        identical((tester.widget(finder) as FutureBuilder).future, initial),
        isFalse,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
