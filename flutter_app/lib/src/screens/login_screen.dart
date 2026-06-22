import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _submitting = false;
  bool _awaitingOtp = false;
  String? _pendingEmail;
  String? _message;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
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
                              otpController: _otpController,
                              message: _message,
                              submitting: _submitting,
                              awaitingOtp: _awaitingOtp,
                              onSubmit: () => _submit(controller),
                              onVerify: () => _verifyOtp(controller),
                              onBack: _awaitingOtp
                                  ? () {
                                      setState(() {
                                        _awaitingOtp = false;
                                        _pendingEmail = null;
                                        _otpController.clear();
                                        _message = null;
                                      });
                                    }
                                  : null,
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
                                otpController: _otpController,
                                message: _message,
                                submitting: _submitting,
                                awaitingOtp: _awaitingOtp,
                                onSubmit: () => _submit(controller),
                                onVerify: () => _verifyOtp(controller),
                                onBack: _awaitingOtp
                                    ? () {
                                        setState(() {
                                          _awaitingOtp = false;
                                          _pendingEmail = null;
                                          _otpController.clear();
                                          _message = null;
                                        });
                                      }
                                    : null,
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
      await controller.signInWithEmailOtp(email);
      if (!mounted) return;
      setState(() {
        _awaitingOtp = true;
        _pendingEmail = email;
        _otpController.clear();
        _message = 'Nos ha inviate un codice de 6 digitos a $email.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _message = 'Error al inviar le codice, proba de novo plus tarde.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  Future<void> _verifyOtp(AppController controller) async {
    final String email = _pendingEmail ?? _emailController.text.trim();
    final String token = _otpController.text.replaceAll(RegExp(r'\s+'), '');
    if (token.length != 6) {
      setState(() {
        _message = 'Entra le codice complete de 6 digitos.';
      });
      return;
    }

    setState(() {
      _submitting = true;
      _message = null;
    });

    try {
      await controller.verifyEmailOtp(email: email, token: token);
      if (!mounted) return;
      setState(() {
        _message = 'Session aperite.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _message = 'Le codice non esseva valide o jam expirava.';
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
    required this.otpController,
    required this.message,
    required this.submitting,
    required this.awaitingOtp,
    required this.onSubmit,
    required this.onVerify,
    this.onBack,
  });

  final AppController controller;
  final TextEditingController emailController;
  final TextEditingController otpController;
  final String? message;
  final bool submitting;
  final bool awaitingOtp;
  final VoidCallback onSubmit;
  final VoidCallback onVerify;
  final VoidCallback? onBack;

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
                  awaitingOtp
                      ? 'Entra le codice que nos inviava per e-mail.'
                      : 'Nos te inviara un codice per e-mail pro initiar session.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                if (!awaitingOtp) ...<Widget>[
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
                      submitting ? 'Inviante codice...' : 'Inviar codice',
                    ),
                  ),
                ] else ...<Widget>[
                  TextField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 6,
                    decoration: const InputDecoration(
                      hintText: '123456',
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: submitting ? null : onVerify,
                    child: Text(
                      submitting ? 'Verificante...' : 'Confirmar codice',
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: submitting ? null : onSubmit,
                    child: const Text('Reinviar codice'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: submitting ? null : onBack,
                    child: const Text('Cambiar e-mail'),
                  ),
                ],
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
