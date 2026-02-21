// NgakaAssist
// Screen: Home dashboard.
// Minimal, high-trust launchpad for common clinician tasks.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/auth_controller.dart';
import '../../widgets/app_background.dart';
import '../../widgets/section_card.dart';

class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider).valueOrNull;
    final userName = auth?.user?.name ?? 'Clinician';

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Dashboard'),
          actions: [
            TextButton(
              onPressed: () => ref.read(authControllerProvider.notifier).logout(),
              child: const Text('Sign out'),
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                Text(
                  'Dumela, $userName',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  'Capture consultations faster. Review AI drafts with confidence.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),

                SectionCard(
                  title: 'Quick actions',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FilledButton.icon(
                        onPressed: () => context.go('/patients'),
                        icon: const Icon(Icons.search),
                        label: const Text('Find a patient'),
                      ),
                      const SizedBox(height: 10),
                      FilledButton.tonalIcon(
                        onPressed: () => context.go('/patients/create'),
                        icon: const Icon(Icons.person_add_alt_1),
                        label: const Text('Create patient'),
                      ),
                      const SizedBox(height: 10),
                      FilledButton.tonalIcon(
                        onPressed: () => context.go('/sync'),
                        icon: const Icon(Icons.sync),
                        label: const Text('View sync queue'),
                      ),
                      // TODO(ngakaassist): Add “Resume last encounter” and “Drafts needing review”.
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                SectionCard(
                  title: 'Today',
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatTile(title: 'Encounters', value: '—'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatTile(title: 'Pending sync', value: '—'),
                      ),
                    ],
                  ),
                ),
                // TODO(ngakaassist): Analytics dashboard (public health, facility-level metrics).
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 6),
          Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
