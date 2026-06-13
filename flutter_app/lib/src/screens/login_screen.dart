import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app_state.dart';
import '../theme/app_theme.dart';

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

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: ScholaCard(
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
                          const SizedBox(height: 20),
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              hintText: 'exemplo@email.com',
                            ),
                          ),
                          const SizedBox(height: 14),
                          FilledButton(
                            onPressed: _submitting
                                ? null
                                : () => _submit(controller),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              _submitting
                                  ? 'Inviante ligamine...'
                                  : 'Inviar ligamine',
                            ),
                          ),
                          if (_message != null) ...<Widget>[
                            const SizedBox(height: 16),
                            Text(
                              _message!,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ],
                      ),
              ),
            ),
          ),
        ),
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
      final Uri baseUri = Uri.base.removeFragment();
      final String redirectTo = kIsWeb
          ? baseUri
                .replace(
                  queryParameters: <String, String>{'auth_callback': '1'},
                )
                .toString()
          : baseUri.toString();

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
