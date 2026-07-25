import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:schola_interlingua_flutter/src/app.dart';
import 'package:schola_interlingua_flutter/src/app_state.dart';
import 'package:schola_interlingua_flutter/src/routing/app_router.dart';

void main() {
  testWidgets('compact navigation does not constrain long course pages', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final AppController controller = AppController();
    await tester.runAsync(controller.loadVocab);
    await tester.pumpWidget(ScholaInterlinguaApp(controller: controller));

    for (final String route in <String>[
      '/course',
      '/lesson/lection1',
      '/course',
      '/decks',
      '/course',
    ]) {
      AppRouter.router.go(route);
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: 'Unexpected layout exception after navigating to $route',
      );
    }

    expect(find.text('Nivello 1'), findsOneWidget);
    expect(find.text('Nivello 6'), findsOneWidget);
  });
}
