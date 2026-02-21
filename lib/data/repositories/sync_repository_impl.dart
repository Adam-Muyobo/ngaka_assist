// NgakaAssist
// Repository implementation: Sync queue.
// MVP behavior: retry marks job as success after a short delay in mock mode.

import 'package:uuid/uuid.dart';

import '../../core/constants.dart';
import '../../core/result.dart';
import '../../domain/entities/sync_job.dart';
import '../../domain/repositories/sync_repository.dart';
import '../local/hive_sync_queue.dart';

class SyncRepositoryImpl implements SyncRepository {
  SyncRepositoryImpl(this._queue);

  final HiveSyncQueue _queue;
  final _uuid = const Uuid();

  @override
  Future<AppResult<List<SyncJob>>> listJobs() => _queue.listJobs();

  @override
  Future<AppResult<void>> upsertJob(SyncJob job) => _queue.upsertJob(job);

  @override
  Future<AppResult<void>> removeJob(String id) => _queue.removeJob(id);

  @override
  Future<AppResult<SyncJob>> retryJob(String id) async {
    final existing = _queue.getJob(id);
    if (existing == null) {
      return AppResult.err(AppFailure(message: 'Job not found'));
    }

    final running = existing.copyWith(status: SyncJobStatus.running, retries: existing.retries + 1, lastError: null);
    await _queue.upsertJob(running);

    if (kUseMockData) {
      // Mock: flip to success.
      await Future<void>.delayed(const Duration(milliseconds: 600));
      final done = running.copyWith(status: SyncJobStatus.success);
      await _queue.upsertJob(done);
      return AppResult.ok(done);
    }

    // TODO(ngakaassist): Implement real retry behavior per job type (upload audio, push SOAP, sign).
    final failed = running.copyWith(status: SyncJobStatus.failed, lastError: 'Not implemented');
    await _queue.upsertJob(failed);
    return AppResult.ok(failed);
  }

  // Convenience: seed an example job if queue is empty.
  Future<void> ensureSeeded() async {
    final jobsRes = await _queue.listJobs();
    if (!jobsRes.isOk) return;
    if ((jobsRes.data ?? const <SyncJob>[]).isNotEmpty) return;

    final job = SyncJob(
      id: 'sj_${_uuid.v4()}',
      type: 'upload_audio',
      status: SyncJobStatus.queued,
      retries: 0,
      createdAt: DateTime.now(),
      payloadRef: const {
        'encounter_id': 'example',
        'note': 'Mock job for UI preview',
      },
    );
    await _queue.upsertJob(job);
  }
}
