import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app_state.dart';
import '../../theme/app_theme.dart';

const Map<String, String> _languageLabels = <String, String>{
  'es': 'Español',
  'en': 'English',
  'ru': 'Русский',
  'de': 'Deutsch',
  'fr': 'Français',
  'it': 'Italiano',
  'la': 'Lingua Latina',
  'eo': 'Esperanto',
  'pt': 'Português',
  'zh': '中文',
  'ja': '日本語',
  'ca': 'Català',
  'ko': '한국어',
};

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bool mobile = MediaQuery.sizeOf(context).width < 900;

    return Scaffold(
      drawer: mobile ? const Drawer(child: _MobileMenu()) : null,
      body: Column(
        children: <Widget>[
          _Header(mobile: mobile),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      child,
                      const SizedBox(height: 20),
                      const _Footer(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.mobile});

  final bool mobile;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[AppTheme.primary, AppTheme.primaryLight],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.10),
            blurRadius: 15,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                children: <Widget>[
                  InkWell(
                    onTap: () => context.go('/'),
                    child: Row(
                      children: <Widget>[
                        Image.asset('assets/images/logo.png', height: 45),
                        const SizedBox(width: 12),
                        const Text(
                          'Schola Interlingua',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (mobile)
                    Builder(
                      builder: (BuildContext context) {
                        return IconButton(
                          onPressed: () => Scaffold.of(context).openDrawer(),
                          icon: const Icon(
                            Icons.menu_rounded,
                            color: Colors.white,
                          ),
                        );
                      },
                    )
                  else
                    const _DesktopNav(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DesktopNav extends StatelessWidget {
  const _DesktopNav();

  @override
  Widget build(BuildContext context) {
    final AppController controller = AppStateScope.of(context);
    return Row(
      children: <Widget>[
        _NavMenuButton(
          label: 'Curso',
          items: const <PopupMenuEntry<String>>[
            PopupMenuItem<String>(value: 'nivel-1', child: Text('Nivello 1')),
            PopupMenuItem<String>(value: 'nivel-2', child: Text('Nivello 2')),
            PopupMenuItem<String>(value: 'nivel-3', child: Text('Nivello 3')),
            PopupMenuItem<String>(value: 'nivel-4', child: Text('Nivello 4')),
            PopupMenuItem<String>(value: 'nivel-5', child: Text('Nivello 5')),
            PopupMenuItem<String>(value: 'nivel-6', child: Text('Nivello 6')),
          ],
          onSelected: (_) => context.go('/course'),
        ),
        _NavMenuButton(
          label: 'Appendice',
          items: const <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'grammatica',
              child: Text('Breve grammatica'),
            ),
            PopupMenuItem<String>(value: 'numeros', child: Text('Numeros')),
            PopupMenuItem<String>(
              value: 'contos',
              child: Text('Contos legite'),
            ),
          ],
          onSelected: (String value) => context.go('/appendix/$value'),
        ),
        _NavMenuButton(
          label: 'Jocos',
          items: const <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'wordsearch',
              child: Text('Cerca de parolas'),
            ),
          ],
          onSelected: (_) => context.go('/jocos/wordsearch'),
        ),
        _NavMenuButton(
          label: 'Linguas',
          items: _languageLabels.entries
              .map(
                (MapEntry<String, String> entry) => PopupMenuItem<String>(
                  value: entry.key,
                  child: Text(entry.value),
                ),
              )
              .toList(),
          onSelected: controller.setSelectedLanguage,
        ),
        _NavTextButton(label: 'Login', onTap: () {}),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
          ),
          child: IconButton(
            onPressed: controller.toggleDarkMode,
            icon: Icon(
              controller.darkMode
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _MobileMenu extends StatelessWidget {
  const _MobileMenu();

  @override
  Widget build(BuildContext context) {
    final AppController controller = AppStateScope.of(context);
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          ListTile(title: const Text('Inicio'), onTap: () => context.go('/')),
          _MobileDropdownSection(
            title: 'Curso',
            children: List<Widget>.generate(
              6,
              (int index) => ListTile(
                contentPadding: const EdgeInsets.only(left: 16, right: 8),
                title: Text('Nivello ${index + 1}'),
                onTap: () => context.go('/course'),
              ),
            ),
          ),
          _MobileDropdownSection(
            title: 'Appendice',
            children: <Widget>[
              ListTile(
                contentPadding: const EdgeInsets.only(left: 16, right: 8),
                title: const Text('Breve grammatica'),
                onTap: () => context.go('/appendix/grammatica'),
              ),
              ListTile(
                contentPadding: const EdgeInsets.only(left: 16, right: 8),
                title: const Text('Numeros'),
                onTap: () => context.go('/appendix/numeros'),
              ),
              ListTile(
                contentPadding: const EdgeInsets.only(left: 16, right: 8),
                title: const Text('Contos legite'),
                onTap: () => context.go('/appendix/contos'),
              ),
            ],
          ),
          _MobileDropdownSection(
            title: 'Jocos',
            children: <Widget>[
              ListTile(
                contentPadding: const EdgeInsets.only(left: 16, right: 8),
                title: const Text('Cerca de parolas'),
                onTap: () => context.go('/jocos/wordsearch'),
              ),
            ],
          ),
          _MobileDropdownSection(
            title:
                'Linguas (${_languageLabels[controller.selectedLanguage] ?? controller.selectedLanguage})',
            children: _languageLabels.entries
                .map(
                  (MapEntry<String, String> entry) => ListTile(
                    contentPadding: const EdgeInsets.only(left: 16, right: 8),
                    title: Text(entry.value),
                    onTap: () => controller.setSelectedLanguage(entry.key),
                  ),
                )
                .toList(),
          ),
          ListTile(
            title: Text(controller.darkMode ? 'Modo clar' : 'Modo obscur'),
            trailing: Icon(
              controller.darkMode
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
            onTap: controller.toggleDarkMode,
          ),
          const Divider(),
          ListTile(title: const Text('Login'), onTap: () {}),
        ],
      ),
    );
  }
}

class _MobileDropdownSection extends StatefulWidget {
  const _MobileDropdownSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  State<_MobileDropdownSection> createState() => _MobileDropdownSectionState();
}

class _MobileDropdownSectionState extends State<_MobileDropdownSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text(widget.title),
          trailing: Icon(
            _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
          ),
          onTap: () => setState(() => _expanded = !_expanded),
        ),
        if (_expanded) ...widget.children,
        const Divider(height: 1),
      ],
    );
  }
}

class _NavTextButton extends StatelessWidget {
  const _NavTextButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(fontWeight: FontWeight.w500),
      ),
      child: Text(label),
    );
  }
}

class _NavMenuButton extends StatelessWidget {
  const _NavMenuButton({
    required this.label,
    required this.items,
    required this.onSelected,
  });

  final String label;
  final List<PopupMenuEntry<String>> items;
  final PopupMenuItemSelected<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onSelected,
      itemBuilder: (BuildContext context) => items,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(
          '$label ▼',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[AppTheme.primary, AppTheme.primaryLight],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 18,
              runSpacing: 18,
              children: const <Widget>[
                _FooterLink(label: 'Gruppetto'),
                _FooterLink(label: 'Repositorio official'),
                _FooterLink(label: 'Plus materiales'),
                _FooterLink(label: 'Union Mundial pro Interlingua'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white.withValues(alpha: 0.10),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
