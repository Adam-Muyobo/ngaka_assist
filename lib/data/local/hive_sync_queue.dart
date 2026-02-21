// NgakaAssist
// Local persistence for sync queue (Hive-backed, JSON string values).
// MVP: no background scheduler; user can retry from UI.

import 'dart:convert';

import 'package:hive/hive.dart';

import '../../core/result.dart';
import '../../core/storage/hive_boxes.dart';
import '../../domain/entities/sync_job.dart';

class HiveSyncQueue {
  Box<String> get _box => Hive.box<String>(HiveBoxes.syncJobs);

  Future<AppResult<List<SyncJob>>> listJobs() async {
    try {
      final jobs = _box.values
          .map((raw) => SyncJob.fromJson((jsonDecode(raw) as Map).cast<String, dynamic>()))
          .toList();
      jobs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return AppResult.ok(jobs);
    } catch (e) {
      return AppResult.err(AppFailure(message: 'Failed to read sync queue', cause: e));
    }
  }

  Future<AppResult<void>> upsertJob(SyncJob job) async {
    try {
      await _box.put(job.id, jsonEncode(job.toJson()));
      return AppResult.ok(null);
    } catch (e) {
      return AppResult.err(AppFailure(message: 'Failed to save sync job', cause: e));
    }
  }

  Future<AppResult<void>> removeJob(String id) async {
    try {
      await _box.delete(id);
      return AppResult.ok(null);
    } catch (e) {
      return AppResult.err(AppFailure(message: 'Failed to remove sync job', cause: e));
    }
  }

  SyncJob? getJob(String id) {
    final raw = _box.get(id);
    if (raw == null) return null;
    return SyncJob.fromJson((jsonDecode(raw) as Map).cast<String, dynamic>());
  }
}
