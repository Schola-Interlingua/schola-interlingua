import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app_state.dart';
import '../services/auth_redirect.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _submitting = false;
  String? _message;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppController controller = AppStateScope.of(context);
    final bool mobile = MediaQuery.sizeOf(context).width < 900;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: Theme.of(context).brightness == Brightness.dark
                    ? const <Color>[
                        Color(0xFF091321),
                        Color(0xFF11253C),
                        Color(0xFF07111D),
                      ]
                    : const <Color>[
                        Color(0xFFE8F1FF),
                        Color(0xFFDCEAFF),
                        Color(0xFFF6FAFF),
                      ],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1080),
                  child: mobile
                      ? Column(
                          children: <Widget>[
                            const _LoginBrandBlock(),
                            const SizedBox(height: 20),
                            _LoginPanel(
                              controller: controller,
                              emailController: _emailController,
                              message: _message,
                              submitting: _submitting,
                              onSubmit: () => _submit(controller),
                            ),
                          ],
                        )
                      : Row(
                          children: <Widget>[
                            const Expanded(flex: 6, child: _LoginBrandBlock()),
                            const SizedBox(width: 28),
                            Expanded(
                              flex: 5,
                              child: _LoginPanel(
                                controller: controller,
                                emailController: _emailController,
                                message: _message,
                                submitting: _submitting,
                                onSubmit: () => _submit(controller),
                              ),
                            ),
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

  Future<void> _submit(AppController controller) async {
    final String email = _emailController.text.trim();
    if (!email.contains('@')) {
      setState(() {
        _message = 'Entra un e-mail valide.';
      });
      return;
    }

    setState(() {
      _submitting = true;
      _message = null;
    });

    try {
      final Uri baseUri = Uri.base;
      final String redirectTo = buildAuthRedirectUri(baseUri);

      await controller.signInWithEmail(email, redirectTo: redirectTo);
      if (!mounted) return;
      setState(() {
        _message = 'Nos ha inviate un ligamine per e-mail.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _message = 'Error al inviar le e-mail, proba de novo plus tarde.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }
}

class _LoginBrandBlock extends StatelessWidget {
  const _LoginBrandBlock();

  @override
  Widget build(BuildContext context) {
    final bool mobile = MediaQuery.sizeOf(context).width < 900;

    return ScholaCard(
      padding: EdgeInsets.all(mobile ? 28 : 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const AppLogo(size: 68),
          const SizedBox(height: 20),
          Text(
            'Schola Interlingua',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 12),
          Text(
            'Lectiones, lecturas, audio, traductiones per parola e practica in Interlingua IALA.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: const <Widget>[
              _FeatureChip(
                icon: Icons.language_rounded,
                label: 'Web, mobile e desktop',
              ),
              _FeatureChip(
                icon: Icons.menu_book_rounded,
                label: 'Curso complete',
              ),
              _FeatureChip(
                icon: Icons.record_voice_over_rounded,
                label: 'Audio e lectura',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LoginPanel extends StatelessWidget {
  const _LoginPanel({
    required this.controller,
    required this.emailController,
    required this.message,
    required this.submitting,
    required this.onSubmit,
  });

  final AppController controller;
  final TextEditingController emailController;
  final String? message;
  final bool submitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return ScholaCard(
      child: controller.isAuthenticated
          ? _SignedInState(email: controller.currentUser?.email ?? '')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'Entrar',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  'Nos te inviara un ligamine per e-mail con le qual tu accedera.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'exemplo@email.com',
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: submitting ? null : onSubmit,
                  child: Text(
                    submitting ? 'Inviante ligamine...' : 'Inviar ligamine',
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => context.go('/'),
                  child: const Text('Continuar sin entrar'),
                ),
                if (message != null) ...<Widget>[
                  const SizedBox(height: 16),
                  Text(
                    message!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderColor(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 18, color: AppTheme.textColor(context)),
          const SizedBox(width: 8),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _SignedInState extends StatelessWidget {
  const _SignedInState({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    final AppController controller = AppStateScope.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          'Session aperte',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        Text(
          email,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: () => context.go('/'),
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: const Text('Ir al initio'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: controller.signOut,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: const Text('Exir'),
        ),
      ],
    );
  }
}
