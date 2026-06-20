import 'package:flutter/material.dart';

import '../widgets/chatina_embed.dart';

Future<void> showChatinaSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.34),
    builder: (BuildContext context) {
      return const _ChatinaBottomSheet();
    },
  );
}

class ChatinaScreen extends StatelessWidget {
  const ChatinaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ChatinaSurface(fullPage: true);
  }
}

class _ChatinaBottomSheet extends StatelessWidget {
  const _ChatinaBottomSheet();

  @override
  Widget build(BuildContext context) {
    return const FractionallySizedBox(
      heightFactor: 0.78,
      child: _ChatinaSurface(),
    );
  }
}

class _ChatinaSurface extends StatelessWidget {
  const _ChatinaSurface({this.fullPage = false});

  final bool fullPage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10, fullPage ? 0 : 0, 10, fullPage ? 0 : 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          children: <Widget>[
            Container(
              width: 56,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.30),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: ChatinaEmbed(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
