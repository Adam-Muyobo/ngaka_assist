// NgakaAssist
// Screen: Sync queue / Offline status.
// MVP: basic visual queue with retry/remove actions.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/sync_job.dart';
import '../../state/sync_queue_controller.dart';
import '../../widgets/app_background.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/section_card.dart';

class SyncQueueScreen extends ConsumerWidget {
  const SyncQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(syncQueueControllerProvider);
    final ctrl = ref.read(syncQueueControllerProvider.notifier);

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Sync & offline'),
          actions: [
            IconButton(
              tooltip: 'Refresh',
              onPressed: ctrl.refresh,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SectionCard(
                      title: 'Status',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Offline-ready (basic queue).'),
                          const SizedBox(height: 6),
                          Text(
                            'TODO(ngakaassist): Detect connectivity, auto-retry, and resolve conflicts for SOAP edits & signing.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: vm.when(
                        data: (jobs) {
                          if (jobs.isEmpty) {
                            return const EmptyState(
                              title: 'Queue is empty',
                              subtitle: 'Work will appear here when offline actions are queued.',
                            );
                          }
                          return ListView.separated(
                            itemCount: jobs.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, i) => _JobCard(job: jobs[i]),
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, _) => EmptyState(title: 'Could not load queue', subtitle: e.toString()),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _JobCard extends ConsumerWidget {
  const _JobCard({required this.job});

  final SyncJob job;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrl = ref.read(syncQueueControllerProvider.notifier);
    final cs = Theme.of(context).colorScheme;
    final (label, color) = switch (job.status) {
      SyncJobStatus.queued => ('Queued', cs.tertiary),
      SyncJobStatus.running => ('Running', cs.primary),
      SyncJobStatus.success => ('Success', Colors.green.shade700),
      SyncJobStatus.failed => ('Failed', cs.error),
    };

    return SectionCard(
      title: job.type,
      trailing: Chip(
        label: Text(label),
        backgroundColor: color.withOpacity(0.10),
        side: BorderSide(color: color.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Retries: ${job.retries}'),
          if (job.lastError != null) ...[
            const SizedBox(height: 6),
            Text('Last error: ${job.lastError}', style: TextStyle(color: cs.error)),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.tonal(
                  onPressed: () => ctrl.retry(job.id),
                  child: const Text('Retry'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.tonal(
                  onPressed: () => ctrl.remove(job.id),
                  child: const Text('Remove'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
