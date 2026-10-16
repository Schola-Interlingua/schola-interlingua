import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:schola_interlingua_flutter/src/app.dart';
import 'package:schola_interlingua_flutter/src/app_state.dart';
import 'package:schola_interlingua_flutter/src/routing/app_router.dart';
import 'package:schola_interlingua_flutter/src/services/guided_session_store.dart';
import 'package:schola_interlingua_flutter/src/services/learning_activity_catalog.dart';
import 'package:schola_interlingua_flutter/src/services/learning_practice_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await GuidedSessionStore.instance.load();
    await LearningPracticeStore.instance.load();
    await LearningActivityCatalog.load();
  });

  testWidgets('main routes fit phones, tablets and desktop in both themes', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    addTearDown(tester.view.resetViewInsets);
    for (final size in const [
      Size(320, 568),
      Size(390, 844),
      Size(844, 390),
      Size(768, 1024),
      Size(1024, 768),
      Size(1440, 900),
    ]) {
      await tester.binding.setSurfaceSize(size);
      final controller = AppController();
      await tester.runAsync(controller.loadVocab);
      await tester.pumpWidget(ScholaInterlinguaApp(controller: controller));
      for (final theme in [ThemeMode.light, ThemeMode.dark]) {
        if (controller.themeMode != theme) controller.toggleDarkMode();
        for (final route in [
          '/',
          '/course',
          '/level/nivel-1',
          '/appendix/grammatica-articulos',
          '/lesson/basico1',
          '/session/basico1',
          '/reading/mi-familia',
          '/decks',
          '/decks/theme/basico1',
          '/jocos/wordsearch',
          '/review',
          '/settings',
          '/entrar',
        ]) {
          AppRouter.router.go(route);
          // Resolve asset-backed content before checking its final layout.
          for (var frame = 0; frame < 5; frame++) {
            await tester.pump(const Duration(milliseconds: 100));
            await tester.runAsync(
              () => Future<void>.delayed(const Duration(milliseconds: 20)),
            );
          }
          await tester.pumpAndSettle();
          expect(
            tester.takeException(),
            isNull,
            reason: '$route at $size ($theme)',
          );
          expect(
            AppRouter.router.routeInformationProvider.value.uri.path,
            route,
          );
        }
        if (size.width <= 390) {
          AppRouter.router.go('/');
          await tester.pumpAndSettle();
          tester.view.viewInsets = FakeViewPadding(
            bottom: 280 * tester.view.devicePixelRatio,
          );
          final input = find.byType(TextField).first;
          await tester.showKeyboard(input);
          await tester.enterText(input, 'parlar');
          await tester.pumpAndSettle();
          expect(
            tester.takeException(),
            isNull,
            reason: 'Search with keyboard at $size ($theme)',
          );
          expect(
            tester.getBottomLeft(input).dy,
            lessThanOrEqualTo(size.height - 280),
          );
          FocusManager.instance.primaryFocus?.unfocus();
          tester.view.resetViewInsets();
          await tester.pumpAndSettle();
        }
      }
      AppRouter.router.go('/');
      await tester.pumpAndSettle();
    }
  });
}
