// NgakaAssist
// Subtle background to avoid flat clinical-white pages.
// Keep it calm and low-contrast for high trust.

import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final base = cs.surface;
    final tint = Color.alphaBlend(cs.primary.withOpacity(0.06), base);

    Widget blob({required Alignment align, required Color color, required double size}) {
      return Align(
        alignment: align,
        child: IgnorePointer(
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  color.withOpacity(0.22),
                  color.withOpacity(0.00),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            base,
            tint,
            Color.alphaBlend(cs.tertiary.withOpacity(0.04), base),
          ],
        ),
      ),
      child: Stack(
        children: [
          blob(align: const Alignment(-0.85, -0.95), color: cs.primary, size: 420),
          blob(align: const Alignment(0.95, 0.70), color: cs.tertiary, size: 520),
          child,
        ],
      ),
    );
  }
}
