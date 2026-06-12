import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: const <Widget>[
        _ProgressCard(),
        SizedBox(height: 24),
        _AnkiCard(),
        SizedBox(height: 24),
        _WelcomeCard(),
      ],
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard();

  @override
  Widget build(BuildContext context) {
    return ScholaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Tu progresso',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          Text(
            'Tu non ha ancora comenciate',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
          Container(
            height: 12,
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant(context),
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: AppTheme.borderColor(context)),
            ),
            child: const FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[AppTheme.primary, AppTheme.primaryLight],
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(99)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              const Text('🔥', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Text(
                '0 dies consecutive',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnkiCard extends StatelessWidget {
  const _AnkiCard();

  @override
  Widget build(BuildContext context) {
    final bool mobile = MediaQuery.sizeOf(context).width < 700;
    return ScholaCard(
      child: mobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const <Widget>[
                _AnkiButton(),
                SizedBox(height: 16),
                _AnkiMeta(),
              ],
            )
          : const Row(
              children: <Widget>[
                Expanded(child: _AnkiButton()),
                SizedBox(width: 16),
                _AnkiMeta(),
              ],
            ),
    );
  }
}

class _AnkiButton extends StatelessWidget {
  const _AnkiButton();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[AppTheme.primary, AppTheme.primaryLight],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Text(
          'Discarga Anki pro tote le curso',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _AnkiMeta extends StatelessWidget {
  const _AnkiMeta();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Text('AnkiWeb', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(width: 10),
        Image.asset('assets/images/logo_anki.png', width: 26, height: 26),
      ],
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard();

  @override
  Widget build(BuildContext context) {
    return ScholaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Benvenite a Schola Interlingua!',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 18),
          Text(
            'Schola Interlingua es un platteforma digital disveloppate con le scopo de impulsar le apprension de Interlingua IALA. Con un stilo clar e moderne, nos offere lectiones structurate, vocabulario, explicationes del grammatica, e exercitios que te permitte apprender passo a passo e con confidentia.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Text(
            'Nos crede in le fortia del saper collaborative, proque tote le material de Schola Interlingua es software libere e open source. Tu pote explorar, adaptar e compartir iste ressource sin restrictiones, e etiam contribuer al melioration continuate del sito.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
