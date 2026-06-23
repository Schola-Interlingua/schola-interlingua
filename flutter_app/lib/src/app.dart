import 'package:flutter/material.dart';

import 'app_state.dart';
import 'routing/app_router.dart';
import 'theme/app_theme.dart';

class ScholaInterlinguaApp extends StatelessWidget {
  const ScholaInterlinguaApp({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      controller: controller,
      child: AnimatedBuilder(
        animation: controller.themeModeListenable,
        builder: (BuildContext context, Widget? child) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Schola Interlingua',
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: controller.themeMode,
            routerConfig: AppRouter.router,
            builder: (BuildContext context, Widget? child) {
              final MediaQueryData media = MediaQuery.of(context);
              final double width = media.size.width;
              final double maxScale = width < 430
                  ? 1.05
                  : width < 600
                  ? 1.1
                  : 1.2;
              return MediaQuery(
                data: media.copyWith(
                  textScaler: media.textScaler.clamp(
                    minScaleFactor: 0.95,
                    maxScaleFactor: maxScale,
                  ),
                ),
                child: child ?? const SizedBox.shrink(),
              );
            },
          );
        },
      ),
    );
  }
}
