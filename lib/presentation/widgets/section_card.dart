// NgakaAssist
// Reusable card with consistent padding and optional header.

import 'package:flutter/material.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({super.key, this.title, required this.child, this.trailing});

  final String? title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = title;

    // Soft, slightly neumorphic surface (raised from the background).
    final surface = Color.alphaBlend(cs.primary.withOpacity(0.025), cs.surface);
    final highlight = Colors.white.withOpacity(0.85);
    final shadow = Colors.black.withOpacity(0.10);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.55)),
        boxShadow: [
          BoxShadow(
            color: highlight,
            offset: const Offset(-10, -10),
            blurRadius: 22,
            spreadRadius: -6,
          ),
          BoxShadow(
            color: shadow,
            offset: const Offset(10, 10),
            blurRadius: 24,
            spreadRadius: -8,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (t != null) ...[
              Row(
                children: [
                  Expanded(
                    child: Text(
                      t,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                          ),
                    ),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
              const SizedBox(height: 12),
            ],
            child,
          ],
        ),
      ),
    );
  }
}
