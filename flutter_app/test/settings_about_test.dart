import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:schola_interlingua_flutter/src/app.dart';
import 'package:schola_interlingua_flutter/src/app_state.dart';
import 'package:schola_interlingua_flutter/src/routing/app_router.dart';

void main() {
  testWidgets('about is available from settings', (WidgetTester tester) async {
    final AppController controller = AppController();
    await tester.pumpWidget(ScholaInterlinguaApp(controller: controller));
    await tester.pump();

    AppRouter.router.go('/settings');
    await tester.pumpAndSettle();

    final Finder aboutButton = find.byKey(const Key('settings-about-button'));
    expect(aboutButton, findsOneWidget);

    await tester.ensureVisible(aboutButton);
    tester.widget<FilledButton>(aboutButton).onPressed!();
    await tester.pumpAndSettle();

    expect(find.text('Benvenite a Schola Interlingua!'), findsOneWidget);

    final BuildContext closeButtonContext = tester.element(
      find.widgetWithText(TextButton, 'Clauder'),
    );
    final Color? actionColor = TextButtonTheme.of(
      closeButtonContext,
    ).style?.foregroundColor?.resolve(<WidgetState>{});
    expect(actionColor, const Color(0xFF8BC8FF));
  });
}
