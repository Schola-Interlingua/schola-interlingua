import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/course_seed.dart';
import '../screens/appendix_screen.dart';
import '../screens/chatina_screen.dart';
import '../screens/course_screen.dart';
import '../screens/home_screen.dart';
import '../screens/level_screen.dart';
import '../screens/lesson_screen.dart';
import '../screens/reading_screen.dart';
import '../screens/scaffold/app_shell.dart';
import '../screens/wordsearch_screen.dart';

final class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      ShellRoute(
        builder: (BuildContext context, GoRouterState state, Widget child) {
          return AppShell(child: child);
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/',
            builder: (BuildContext context, GoRouterState state) {
              return const HomeScreen();
            },
          ),
          GoRoute(
            path: '/course',
            builder: (BuildContext context, GoRouterState state) {
              return const CourseScreen();
            },
          ),
          GoRoute(
            path: '/level/:slug',
            builder: (BuildContext context, GoRouterState state) {
              final String slug = state.pathParameters['slug']!;
              final level = courseLevels.firstWhere(
                (level) => level.slug == slug,
              );
              return LevelScreen(level: level);
            },
          ),
          GoRoute(
            path: '/lesson/:slug',
            builder: (BuildContext context, GoRouterState state) {
              final String slug = state.pathParameters['slug']!;
              return LessonScreen(slug: slug);
            },
          ),
          GoRoute(
            path: '/reading/:slug',
            builder: (BuildContext context, GoRouterState state) {
              final String slug = state.pathParameters['slug']!;
              return ReadingScreen(slug: slug);
            },
          ),
          GoRoute(
            path: '/appendix/:slug',
            builder: (BuildContext context, GoRouterState state) {
              final String slug = state.pathParameters['slug']!;
              return AppendixScreen(slug: slug);
            },
          ),
          GoRoute(
            path: '/chat',
            builder: (BuildContext context, GoRouterState state) {
              return const ChatinaScreen();
            },
          ),
          GoRoute(
            path: '/jocos/wordsearch',
            builder: (BuildContext context, GoRouterState state) {
              return const WordsearchScreen();
            },
          ),
        ],
      ),
    ],
  );
}
