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
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 112),
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
          const Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: _BottomNavBar(),
          ),
        ],
      ),
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Row(
                      children: <Widget>[
                        InkWell(
                          onTap: () => context.go('/'),
                          child: Row(
                            children: <Widget>[
                              const AppLogo(size: 46),
                              const SizedBox(width: 12),
                              Text(
                                'Schola Interlingua',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: dark
                                      ? Colors.white
                                      : AppTheme.textColor(context),
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        if (!compact)
                          Text(
                            'Interlingua IALA',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppTheme.mutedTextColor(context),
                                  fontWeight: FontWeight.w600,
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
            padding: const EdgeInsets.all(10),
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
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _BottomNavButton(item: item, selected: selected),
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
  const _BottomNavButton({required this.item, required this.selected});

  final _NavItemData item;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => context.go(item.route),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
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
              size: 20,
              color: selected ? Colors.white : AppTheme.textColor(context),
            ),
            const SizedBox(height: 6),
            Text(
              item.label,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.fade,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: selected ? Colors.white : AppTheme.textColor(context),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
