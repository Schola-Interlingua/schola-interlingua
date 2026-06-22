import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_theme.dart';
import '../../widgets/app_logo.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

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
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        compact ? 18 : 24,
                        horizontalPadding,
                        bottomNavHeight,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1200),
                          child: child,
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
                child: const _BottomNavBar(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AmbientBackground extends StatelessWidget {
  const _AmbientBackground();

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: dark
              ? const <Color>[
                  Color(0xFF091321),
                  Color(0xFF10233B),
                  Color(0xFF07111D),
                ]
              : const <Color>[
                  Color(0xFFE8F1FF),
                  Color(0xFFDCEAFF),
                  Color(0xFFF4F8FF),
                ],
        ),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: -70,
            left: -80,
            child: _GlowOrb(
              size: 260,
              color: dark ? AppTheme.glowBlue : const Color(0xA0B7D7FF),
            ),
          ),
          Positioned(
            top: 130,
            right: -100,
            child: _GlowOrb(
              size: 320,
              color: dark ? AppTheme.glowCyan : const Color(0x80D0E4FF),
            ),
          ),
          Positioned(
            bottom: -140,
            left: 60,
            child: _GlowOrb(
              size: 340,
              color: dark ? const Color(0x404287FF) : const Color(0x66F5FBFF),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 46, sigmaY: 46),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: <Color>[color, color.withValues(alpha: 0.0)],
            ),
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

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1240),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    color: dark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.white.withValues(alpha: 0.44),
                    border: Border.all(
                      color: dark
                          ? Colors.white.withValues(alpha: 0.16)
                          : Colors.white.withValues(alpha: 0.60),
                    ),
                    boxShadow: AppTheme.glassShadow(context),
                  ),
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IgnorePointer(
                          child: Container(
                            width: compact ? 120 : 220,
                            height: compact ? 72 : 92,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(28),
                                bottomRight: Radius.circular(28),
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: dark
                                    ? <Color>[
                                        const Color(0x00112940),
                                        const Color(0xFF112940),
                                        const Color(0xFF112940),
                                      ]
                                    : <Color>[
                                        const Color(0x00FFFFFF),
                                        const Color(0xFFF3F8FF),
                                        const Color(0xFFF3F8FF),
                                      ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: compact ? 16 : 24,
                          vertical: compact ? 14 : 16,
                        ),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: InkWell(
                                onTap: () => context.go('/'),
                                child: Row(
                                  children: <Widget>[
                                    AppLogo(
                                      size: compact ? 40 : 46,
                                      padding: EdgeInsets.all(compact ? 4 : 6),
                                      radius: compact ? 12 : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Schola Interlingua',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: dark
                                              ? Colors.white
                                              : AppTheme.textColor(context),
                                          fontSize: compact ? 18 : 22,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
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
            padding: EdgeInsets.all(compact ? 6 : 10),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.56),
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
          gradient: selected
              ? LinearGradient(
                  colors: <Color>[
                    AppTheme.primary.withValues(alpha: 0.92),
                    AppTheme.primaryLight.withValues(alpha: 0.74),
                  ],
                )
              : null,
          color: selected ? null : Colors.white.withValues(alpha: 0.08),
          border: Border.all(
            color: selected
                ? Colors.white.withValues(alpha: 0.18)
                : AppTheme.borderColor(context),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              item.icon,
              size: compact ? 18 : 20,
              color: selected ? Colors.white : AppTheme.textColor(context),
            ),
            SizedBox(height: compact ? 4 : 6),
            Text(
              item.label,
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: selected ? Colors.white : AppTheme.textColor(context),
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
