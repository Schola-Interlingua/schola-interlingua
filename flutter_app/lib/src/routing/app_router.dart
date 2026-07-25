import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/course_seed.dart';
import '../screens/appendix_screen.dart';
import '../screens/chatina_screen.dart';
import '../screens/course_screen.dart';
import '../screens/decks_screen.dart';
import '../screens/home_screen.dart';
import '../screens/level_screen.dart';
import '../screens/lesson_screen.dart';
import '../screens/login_screen.dart';
import '../screens/reading_screen.dart';
import '../screens/scaffold/app_shell.dart';
import '../screens/settings_screen.dart';
import '../screens/srs_review_screen.dart';
import '../screens/wordsearch_screen.dart';

final class AppRouter {
  static Widget _withShell(Widget child) => AppShell(child: child);

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(
        path: '/entrar',
        builder: (BuildContext context, GoRouterState state) {
          return const LoginScreen();
        },
      ),
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return _withShell(const HomeScreen());
        },
      ),
      GoRoute(
        path: '/course',
        builder: (BuildContext context, GoRouterState state) {
          return _withShell(const CourseScreen());
        },
      ),
      GoRoute(
        path: '/decks',
        builder: (BuildContext context, GoRouterState state) {
          return _withShell(const DecksScreen());
        },
      ),
      GoRoute(
        path: '/decks/favorites/quiz',
        builder: (BuildContext context, GoRouterState state) {
          return _withShell(const DeckQuizScreen.favorites());
        },
      ),
      GoRoute(
        path: '/decks/favorites',
        builder: (BuildContext context, GoRouterState state) {
          return _withShell(const DeckDetailScreen.favorites());
        },
      ),
      GoRoute(
        path: '/decks/theme/:slug/quiz',
        builder: (BuildContext context, GoRouterState state) {
          return _withShell(
            DeckQuizScreen.thematic(slug: state.pathParameters['slug']!),
          );
        },
      ),
      GoRoute(
        path: '/decks/theme/:slug',
        builder: (BuildContext context, GoRouterState state) {
          return _withShell(
            DeckDetailScreen.thematic(slug: state.pathParameters['slug']!),
          );
        },
      ),
      GoRoute(
        path: '/decks/custom/:deckId/quiz',
        builder: (BuildContext context, GoRouterState state) {
          return _withShell(
            DeckQuizScreen.custom(deckId: state.pathParameters['deckId']!),
          );
        },
      ),
      GoRoute(
        path: '/decks/custom/:deckId',
        builder: (BuildContext context, GoRouterState state) {
          return _withShell(
            DeckDetailScreen.custom(deckId: state.pathParameters['deckId']!),
          );
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (BuildContext context, GoRouterState state) {
          return _withShell(const SettingsScreen());
        },
      ),
      GoRoute(
        path: '/review',
        builder: (BuildContext context, GoRouterState state) {
          return _withShell(const SrsReviewScreen());
        },
      ),
      GoRoute(
        path: '/level/:slug',
        builder: (BuildContext context, GoRouterState state) {
          final String slug = state.pathParameters['slug']!;
          final level = courseLevels.firstWhere((level) => level.slug == slug);
          return _withShell(LevelScreen(level: level));
        },
      ),
      GoRoute(
        path: '/lesson/:slug',
        builder: (BuildContext context, GoRouterState state) {
          final String slug = state.pathParameters['slug']!;
          return _withShell(LessonScreen(slug: slug));
        },
      ),
      GoRoute(
        path: '/reading/:slug',
        builder: (BuildContext context, GoRouterState state) {
          final String slug = state.pathParameters['slug']!;
          return _withShell(ReadingScreen(slug: slug));
        },
      ),
      GoRoute(
        path: '/appendix/:slug',
        builder: (BuildContext context, GoRouterState state) {
          final String slug = state.pathParameters['slug']!;
          return _withShell(AppendixScreen(slug: slug));
        },
      ),
      GoRoute(
        path: '/chat',
        builder: (BuildContext context, GoRouterState state) {
          return _withShell(const ChatinaScreen());
        },
      ),
      GoRoute(
        path: '/jocos/wordsearch',
        builder: (BuildContext context, GoRouterState state) {
          return _withShell(const WordsearchScreen());
        },
      ),
    ],
  );
}
