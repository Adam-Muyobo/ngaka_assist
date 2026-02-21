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
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.surface,
            cs.surface,
            Color.alphaBlend(cs.primary.withOpacity(0.05), cs.surface),
          ],
        ),
      ),
      child: child,
    );
  }
}
