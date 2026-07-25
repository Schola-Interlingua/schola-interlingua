import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:schola_interlingua_flutter/src/app.dart';
import 'package:schola_interlingua_flutter/src/app_state.dart';
import 'package:schola_interlingua_flutter/src/models/srs_models.dart';
import 'package:schola_interlingua_flutter/src/routing/app_router.dart';
import 'package:schola_interlingua_flutter/src/screens/decks_screen.dart';
import 'package:schola_interlingua_flutter/src/theme/app_theme.dart';

void main() {
  testWidgets('controller manages favorites and custom deck words', (
    WidgetTester tester,
  ) async {
    final AppController controller = AppController();
    await tester.runAsync(controller.loadVocab);

    expect(controller.vocabularyWordForTerm('leger'), isNotNull);
    expect(controller.toggleFavoriteWord('Leger'), isTrue);
    expect(controller.isFavoriteWord('leger'), isTrue);
    expect(
      controller.favoriteWords.map((word) => word.term),
      contains('leger'),
    );

    final String deckId = controller.createCustomDeck('Viage');
    controller.addWordToCustomDeck(deckId, 'leger');
    controller.addWordToCustomDeck(deckId, 'Leger');

    expect(controller.customDeckById(deckId)?.wordIds, <String>['leger']);
    expect(controller.wordsForCustomDeck(deckId).single.term, 'leger');

    controller.removeWordFromCustomDeck(deckId, 'leger');
    expect(controller.customDeckById(deckId)?.wordIds, isEmpty);

    controller.deleteCustomDeck(deckId);
    expect(controller.customDeckById(deckId), isNull);
  });

  testWidgets('lesson and deck reviews share one SRS record per word', (
    WidgetTester tester,
  ) async {
    final AppController controller = AppController();
    await tester.runAsync(controller.loadVocab);

    controller.recordSrsReviewForSlugTerm('lection2', 'leger', success: true);
    final SrsCardProgress? firstReview = controller.srsProgressForSlugTerm(
      'lection9',
      'leger',
    );

    expect(firstReview, isNotNull);
    expect(firstReview!.cardId, 'word:leger');
    expect(firstReview.successCount, 1);

    controller.recordSrsReviewForSlugTerm('lection9', 'leger', success: true);
    final SrsCardProgress? sharedReview = controller.srsProgressForSlugTerm(
      'basico1',
      'leger',
    );

    expect(sharedReview, isNotNull);
    expect(sharedReview!.cardId, 'word:leger');
    expect(sharedReview.successCount, 2);
    expect(sharedReview.stage, SrsStage.reviewing);
  });

  testWidgets(
    'decks screen puts favorites before personal and thematic decks',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final AppController controller = AppController();
      await tester.runAsync(controller.loadVocab);
      controller.toggleFavoriteWord('leger');
      final String deckId = controller.createCustomDeck('Mi viage');
      controller.addWordToCustomDeck(deckId, 'leger');

      await tester.pumpWidget(
        _DeckTestApp(controller: controller, child: const DecksScreen()),
      );
      await tester.pump();

      expect(find.text('Favoritos'), findsOneWidget);
      expect(find.byKey(const Key('favorites-deck-card')), findsOneWidget);
      expect(find.text('Tu decks'), findsOneWidget);
      expect(find.text('Mi viage'), findsOneWidget);
      expect(find.text('Decks per thema'), findsOneWidget);
      expect(
        find.byKey(const ValueKey<String>('theme-deck-alimentos')),
        findsOneWidget,
      );
    },
  );

  testWidgets('custom deck dialog adds and detail removes a word', (
    WidgetTester tester,
  ) async {
    final AppController controller = AppController();
    await tester.runAsync(controller.loadVocab);
    final String deckId = controller.createCustomDeck('Lectura');

    await tester.pumpWidget(
      _DeckTestApp(
        controller: controller,
        child: DeckDetailScreen.custom(deckId: deckId),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('add-words-to-deck')));
    await tester.pump(const Duration(milliseconds: 350));
    await tester.enterText(find.byKey(const Key('add-words-search')), 'leger');
    await tester.pump();

    final Finder toggleWord = find.byKey(
      const ValueKey<String>('toggle-deck-word-leger'),
    );
    expect(toggleWord, findsOneWidget);
    await tester.tap(toggleWord);
    await tester.pump();
    expect(controller.customDeckById(deckId)?.wordIds, contains('leger'));

    await tester.tap(find.byTooltip('Clauder'));
    await tester.pump(const Duration(milliseconds: 350));

    final Finder removeWord = find.byKey(
      const ValueKey<String>('remove-deck-word-leger'),
    );
    expect(removeWord, findsOneWidget);
    await tester.ensureVisible(removeWord);
    await tester.tap(removeWord);
    await tester.pump();

    expect(controller.customDeckById(deckId)?.wordIds, isEmpty);
    expect(find.text('Iste deck es vacue'), findsOneWidget);
  });

  testWidgets('creating a deck survives the dialog route transition', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final AppController controller = AppController();
    await tester.runAsync(controller.loadVocab);
    await tester.pumpWidget(ScholaInterlinguaApp(controller: controller));

    AppRouter.router.go('/decks');
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    tester
        .widget<FilledButton>(find.byKey(const Key('create-deck-primary')))
        .onPressed!();
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('new-deck-name')),
      'Deck de regression',
    );
    await tester.pump();
    tester
        .widget<FilledButton>(find.byKey(const Key('confirm-create-deck')))
        .onPressed!();
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(controller.customDecks.single.name, 'Deck de regression');
    expect(find.text('Deck de regression'), findsOneWidget);
  });

  testWidgets('custom deck quick quiz updates the shared SRS progress', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final AppController controller = AppController();
    await tester.runAsync(controller.loadVocab);
    final String deckId = controller.createCustomDeck('Lectura');
    controller.addWordToCustomDeck(deckId, 'leger');
    await tester.pumpWidget(ScholaInterlinguaApp(controller: controller));

    AppRouter.router.go('/decks/custom/$deckId');
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('start-deck-quiz')), findsOneWidget);
    tester
        .widget<FilledButton>(find.byKey(const Key('start-deck-quiz')))
        .onPressed!();
    await tester.pumpAndSettle();

    expect(find.text('Repaso del deck'), findsOneWidget);
    expect(find.textContaining('progresso SRS compartite'), findsOneWidget);

    final Finder correctAnswer = find.widgetWithText(OutlinedButton, 'leger');
    expect(correctAnswer, findsOneWidget);
    tester.widget<OutlinedButton>(correctAnswer).onPressed!();
    await tester.pump(const Duration(milliseconds: 50));

    final SrsCardProgress? progress = controller.srsProgressForSlugTerm(
      'lection2',
      'leger',
    );
    expect(progress, isNotNull);
    expect(progress!.cardId, 'word:leger');
    expect(progress.successCount, 1);
    expect(progress.isDue, isFalse);
    await tester.pump(const Duration(milliseconds: 750));
  });
}

class _DeckTestApp extends StatelessWidget {
  const _DeckTestApp({required this.controller, required this.child});

  final AppController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      controller: controller,
      child: MaterialApp(
        theme: AppTheme.light().copyWith(splashFactory: NoSplash.splashFactory),
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}
