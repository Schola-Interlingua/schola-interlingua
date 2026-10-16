import 'dart:math' as math;
import 'package:flutter/material.dart';

class TopicProgressRing extends StatelessWidget {
  const TopicProgressRing({
    super.key,
    required this.parts,
    required this.completed,
    required this.child,
  });
  final int parts, completed;
  final Widget child;
  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _RingPainter(
      parts,
      completed,
      Theme.of(context).brightness == Brightness.dark,
    ),
    child: Padding(padding: const EdgeInsets.all(7), child: child),
  );
}

class _RingPainter extends CustomPainter {
  const _RingPainter(this.parts, this.completed, this.dark);
  final int parts, completed;
  final bool dark;
  @override
  void paint(Canvas canvas, Size size) {
    final total = math.max(1, parts);
    final angle = math.pi * 2 / total;
    final gap = total == 1 ? 0.0 : math.min(.12, angle * .2);
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: size.shortestSide / 2 - 2,
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < total; i++) {
      paint.color = i < completed
          ? const Color(0xFF6CCB9B)
          : dark
          ? const Color(0xFF3D5269)
          : const Color(0xFFB8C9D9);
      canvas.drawArc(
        rect,
        -math.pi / 2 + i * angle + gap / 2,
        angle - gap,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      parts != oldDelegate.parts ||
      completed != oldDelegate.completed ||
      dark != oldDelegate.dark;
}
