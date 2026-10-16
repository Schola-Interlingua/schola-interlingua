import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:schola_interlingua_flutter/src/app.dart';
import 'package:schola_interlingua_flutter/src/app_state.dart';
import 'package:schola_interlingua_flutter/src/data/course_seed.dart';
import 'package:schola_interlingua_flutter/src/models/course_models.dart';
import 'package:schola_interlingua_flutter/src/routing/app_router.dart';
import 'package:schola_interlingua_flutter/src/screens/course_screen.dart';
import 'package:schola_interlingua_flutter/src/theme/app_theme.dart';

void main() {
  testWidgets('each level opens its own summary and returns to the path', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 760));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final controller = AppController();
    await tester.runAsync(controller.loadVocab);
    await tester.pumpWidget(
      AppStateScope(
        controller: controller,
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: const Scaffold(
            body: SingleChildScrollView(child: CourseScreen()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    for (final level in courseLevels) {
      final header = find.byKey(ValueKey('course-level-${level.slug}'));
      await tester.ensureVisible(header);
      await tester.tap(header);
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Que apprendera tu?'), findsOneWidget);
      expect(level.learningGoals.length, 3);
      for (final goal in level.learningGoals) {
        expect(find.text(goal), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(header, findsOneWidget);
    }
  });

  testWidgets(
    'all course items remain compact, readable and reachable at 320px',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 760));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final controller = AppController();
      await tester.runAsync(controller.loadVocab);
      for (final theme in [AppTheme.dark(), AppTheme.light()]) {
        await tester.pumpWidget(
          AppStateScope(
            controller: controller,
            child: MaterialApp(
              theme: theme,
              home: const Scaffold(
                body: SingleChildScrollView(
                  padding: EdgeInsets.all(12),
                  child: CourseScreen(),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        for (final level in courseLevels) {
          expect(find.text(level.title), findsOneWidget);
          for (final item in level.sections.expand(
            (section) => section.items,
          )) {
            final node = find.byKey(
              ValueKey('course-node-${item.kind.name}-${item.slug}'),
            );
            expect(node, findsOneWidget);
            expect(tester.getSize(node).height, lessThan(140));
            final circle = find.byKey(
              ValueKey('course-circle-${item.kind.name}-${item.slug}'),
            );
            expect(tester.getSize(circle).width, inInclusiveRange(48, 72));
            final title = find.descendant(
              of: node,
              matching: find.text(item.title),
            );
            expect(title, findsOneWidget);
          }
        }
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets(
    'path nodes navigate to grammar, lessons, readings and vocabulary',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final controller = AppController();
      await tester.runAsync(controller.loadVocab);
      controller.markCompleted('lesson:basico1');
      await tester.pumpWidget(ScholaInterlinguaApp(controller: controller));
      final cases = <(CourseItemKind, String, String)>[
        (
          CourseItemKind.appendix,
          'grammatica-articulos',
          '/appendix/grammatica-articulos',
        ),
        (CourseItemKind.lesson, 'lection1', '/lesson/lection1'),
        (CourseItemKind.vocabulary, 'basico1', '/lesson/basico1'),
        (CourseItemKind.reading, 'mi-familia', '/reading/mi-familia'),
        (CourseItemKind.vocabulary, 'technologia', '/lesson/technologia'),
      ];
      for (final (kind, slug, route) in cases) {
        AppRouter.router.go('/course');
        await tester.pumpAndSettle();
        final node = find.byKey(ValueKey('course-node-${kind.name}-$slug'));
        if (slug == 'basico1') {
          expect(
            tester.widget<Semantics>(node).properties.label,
            'Basico1, complete',
          );
        }
        await tester.ensureVisible(node);
        await tester.tap(node);
        await tester.pumpAndSettle();
        expect(AppRouter.router.routeInformationProvider.value.uri.path, route);
        expect(tester.takeException(), isNull, reason: route);
      }
    },
  );
}
