import 'package:flutter_test/flutter_test.dart';
import 'package:schola_interlingua_flutter/src/app.dart';
import 'package:schola_interlingua_flutter/src/app_state.dart';

void main() {
  testWidgets('shows the rewrite home shell', (WidgetTester tester) async {
    final AppController controller = AppController();
    await tester.pumpWidget(ScholaInterlinguaApp(controller: controller));
    await tester.pump();

    expect(find.text('Schola Interlingua'), findsWidgets);
    expect(find.text('Benvenite a Schola Interlingua!'), findsOneWidget);
    expect(find.text('Discarga Anki pro tote le curso'), findsOneWidget);
  });
}
