import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_theme.dart';
import '../../widgets/app_logo.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool _scrollLocked = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool compact = constraints.maxWidth < 430;
        final double horizontalPadding = compact ? 12 : 16;
        final double bottomNavHeight = compact ? 104 : 112;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: <Widget>[
              const _AmbientBackground(),
              Column(
                children: <Widget>[
                  const _Header(),
                  Expanded(
                    child: NotificationListener<AppShellScrollLockNotification>(
                      onNotification:
                          (AppShellScrollLockNotification notification) {
                            if (_scrollLocked == notification.locked) {
                              return true;
                            }
                            setState(() {
                              _scrollLocked = notification.locked;
                            });
                            return true;
                          },
                      child: SingleChildScrollView(
                        physics: _scrollLocked
                            ? const NeverScrollableScrollPhysics()
                            : null,
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          compact ? 18 : 24,
                          horizontalPadding,
                          bottomNavHeight,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1200),
                            child: widget.child,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                left: horizontalPadding,
                right: horizontalPadding,
                bottom: compact ? 12 : 16,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 620),
                    child: const _BottomNavBar(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AppShellScrollLockNotification extends Notification {
  const AppShellScrollLockNotification({required this.locked});

  final bool locked;
}

class _AmbientBackground extends StatelessWidget {
  const _AmbientBackground();

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: dark
                ? const [
                    AppTheme.darkBackgroundSecondary,
                    AppTheme.darkBackground,
                  ]
                : const [AppTheme.backgroundSecondary, AppTheme.background],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final bool compact = MediaQuery.sizeOf(context).width < 560;

    return SafeArea(
      bottom: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, compact ? 16 : 20, 76, 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => context.go('/'),
              child: Row(
                children: [
                  AppLogo(
                    size: compact ? 38 : 42,
                    padding: const EdgeInsets.all(5),
                    radius: 12,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Schola Interlingua',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: dark ? AppTheme.darkText : AppTheme.text,
                        fontSize: compact ? 18 : 21,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  const _NavItemData({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    final bool compact = MediaQuery.sizeOf(context).width < 430;
    final List<_NavItemData> items = <_NavItemData>[
      const _NavItemData(label: 'Domo', icon: Icons.home_rounded, route: '/'),
      const _NavItemData(
        label: 'Studiar',
        icon: Icons.school_rounded,
        route: '/course',
      ),
      const _NavItemData(
        label: 'Jocos',
        icon: Icons.extension_rounded,
        route: '/jocos/wordsearch',
      ),
      const _NavItemData(
        label: 'Config',
        icon: Icons.tune_rounded,
        route: '/settings',
      ),
    ];

    return SafeArea(
      top: false,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.darkCard.withValues(alpha: 0.96)
                  : Colors.white.withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppTheme.borderColor(context)),
              boxShadow: AppTheme.glassShadow(context),
            ),
            child: Row(
              children: items.map((item) {
                final bool selected =
                    location == item.route ||
                    (item.route == '/course' &&
                        (location.startsWith('/course') ||
                            location.startsWith('/decks') ||
                            location.startsWith('/level/') ||
                            location.startsWith('/lesson/') ||
                            location.startsWith('/reading/') ||
                            location.startsWith('/appendix/'))) ||
                    (item.route == '/jocos/wordsearch' &&
                        location.startsWith('/jocos')) ||
                    (item.route == '/settings' &&
                        location.startsWith('/settings'));
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: compact ? 2 : 4),
                    child: _BottomNavButton(
                      item: item,
                      selected: selected,
                      compact: compact,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavButton extends StatelessWidget {
  const _BottomNavButton({
    required this.item,
    required this.selected,
    required this.compact,
  });

  final _NavItemData item;
  final bool selected;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(compact ? 18 : 20),
      onTap: () => context.go(item.route),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 6 : 10,
          vertical: compact ? 10 : 12,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(compact ? 18 : 20),
          color: selected ? AppTheme.primaryLight : Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              item.icon,
              size: compact ? 18 : 20,
              color: selected ? Colors.white : AppTheme.mutedTextColor(context),
            ),
            SizedBox(height: compact ? 4 : 6),
            Text(
              item.label,
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: selected
                    ? Colors.white
                    : AppTheme.mutedTextColor(context),
                fontWeight: FontWeight.w700,
                fontSize: compact ? 11.5 : 14,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
