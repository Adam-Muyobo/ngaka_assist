// NgakaAssist
// Repository contract: Sync queue.
// MVP: basic visual queue with retry.

import '../../core/result.dart';
import '../entities/sync_job.dart';

abstract class SyncRepository {
  Future<AppResult<List<SyncJob>>> listJobs();

  Future<AppResult<void>> upsertJob(SyncJob job);

  Future<AppResult<void>> removeJob(String id);

  Future<AppResult<SyncJob>> retryJob(String id);

  // TODO(ngakaassist): Add background sync scheduler + connectivity triggers.
}
