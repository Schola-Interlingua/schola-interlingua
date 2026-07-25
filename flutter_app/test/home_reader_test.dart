import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:schola_interlingua_flutter/src/app_state.dart';
import 'package:schola_interlingua_flutter/src/screens/home_screen.dart';
import 'package:schola_interlingua_flutter/src/theme/app_theme.dart';

void main() {
  testWidgets('reader highlights pasted text in place and translates a word', (
    WidgetTester tester,
  ) async {
    final AppController controller = AppController();
    await tester.runAsync(controller.loadVocab);
    expect(AppController.normalizeTerm('parlar'), 'parlar');
    expect(
      controller.allVocabItems.where(
        (Map<String, String> item) => item['term'] == 'parlar',
      ),
      isNotEmpty,
    );
    expect(controller.resolveMeaning('Le', 'es'), isNotNull);
    expect(controller.resolveMeaning('homine', 'es'), 'hombre');
    expect(controller.lookupMeaning('parlar')?['es'], 'hablar');
    expect(controller.resolveMeaning('parla', 'es'), 'hablar');
    await tester.pumpWidget(_ReaderTestApp(controller: controller));

    await tester.enterText(
      find.byKey(const Key('home-reader-input')),
      'Le homine parla mysteriose.',
    );
    await tester.pump();

    expect(find.text('Texto in Interlingua'), findsNothing);
    expect(find.byKey(const Key('home-reader-preview')), findsNothing);
    expect(find.text('Lectura interactive'), findsNothing);
    expect(find.textContaining('Traduction in'), findsNothing);

    final TextField field = tester.widget<TextField>(
      find.byKey(const Key('home-reader-input')),
    );
    final TextSpan renderedText = field.controller!.buildTextSpan(
      context: tester.element(find.byKey(const Key('home-reader-input'))),
      style: const TextStyle(),
      withComposing: false,
    );
    final Map<String, TextSpan> renderedWords = <String, TextSpan>{
      for (final TextSpan span in renderedText.children!.whereType<TextSpan>())
        if (<String>{'Le', 'homine', 'parla'}.contains(span.text))
          span.text!: span,
    };
    final TextSpan unknownWord = renderedText.children!
        .whereType<TextSpan>()
        .singleWhere((TextSpan span) => span.text == 'mysteriose');
    expect(renderedWords.keys, containsAll(<String>['Le', 'homine', 'parla']));
    for (final TextSpan knownWord in renderedWords.values) {
      expect(knownWord.style?.decoration, TextDecoration.underline);
    }
    expect(unknownWord.style, isNull);

    await _tapWordInReader(tester, 'homine');

    expect(find.text('hombre'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('favorite-word-homine')),
      findsOneWidget,
    );

    tester
        .widget<IconButton>(
          find.byKey(const ValueKey<String>('favorite-word-homine')),
        )
        .onPressed
        ?.call();
    await tester.pump(const Duration(milliseconds: 350));
    expect(controller.isFavoriteWord('homine'), isTrue);

    await tester.tap(find.byKey(const Key('home-reader-clear')));
    await tester.pump();

    expect(find.byKey(const Key('home-reader-preview')), findsNothing);
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('home-reader-input')))
          .controller
          ?.text,
      isEmpty,
    );
  });

  testWidgets('reader uses the selected language on a compact layout', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final AppController controller = AppController();
    await tester.runAsync(controller.loadVocab);
    controller.setSelectedLanguage('en');
    await tester.pumpWidget(_ReaderTestApp(controller: controller));

    expect(find.text('Traduction in English'), findsNothing);

    await tester.enterText(
      find.byKey(const Key('home-reader-input')),
      'Io parla.',
    );
    await tester.pump();
    await _tapWordInReader(tester, 'parla');

    expect(find.text('to speak'), findsOneWidget);
  });
}

Future<void> _tapWordInReader(WidgetTester tester, String word) async {
  final Finder fieldFinder = find.byKey(const Key('home-reader-input'));
  await tester.ensureVisible(fieldFinder);
  final TextField field = tester.widget<TextField>(fieldFinder);
  final int wordOffset = field.controller!.text.indexOf(word);
  expect(wordOffset, greaterThanOrEqualTo(0));

  final Finder editableFinder = find.descendant(
    of: fieldFinder,
    matching: find.byType(EditableText),
  );
  final RenderEditable editable = tester
      .state<EditableTextState>(editableFinder)
      .renderEditable;
  final Rect caret = editable.getLocalRectForCaret(
    TextPosition(offset: wordOffset + 1),
  );
  await tester.tapAt(editable.localToGlobal(caret.center));
  await tester.pumpAndSettle();
}

class _ReaderTestApp extends StatelessWidget {
  const _ReaderTestApp({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      controller: controller,
      child: MaterialApp(
        theme: AppTheme.light().copyWith(splashFactory: NoSplash.splashFactory),
        home: const Scaffold(
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: HomeScreen(),
          ),
        ),
      ),
    );
  }
}
