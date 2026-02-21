// NgakaAssist
// Sync queue controller.
// Reads Hive-backed queue and provides retry/remove actions.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/sync_job.dart';
import 'providers.dart';

final syncQueueControllerProvider = AsyncNotifierProvider<SyncQueueController, List<SyncJob>>(SyncQueueController.new);

class SyncQueueController extends AsyncNotifier<List<SyncJob>> {
  @override
  Future<List<SyncJob>> build() async {
    final repo = ref.watch(syncRepositoryProvider);
    final res = await repo.listJobs();
    return res.data ?? const <SyncJob>[];
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await build());
  }

  Future<void> retry(String id) async {
    final repo = ref.read(syncRepositoryProvider);
    await repo.retryJob(id);
    await refresh();
  }

  Future<void> remove(String id) async {
    final repo = ref.read(syncRepositoryProvider);
    await repo.removeJob(id);
    await refresh();
  }
}
