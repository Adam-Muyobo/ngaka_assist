// NgakaAssist
// Centralized Hive box names.
// Using constants prevents typos across the codebase.

class HiveBoxes {
  static const String syncJobs = 'sync_jobs';

  // Local mock persistence (so mock mode feels real across restarts).
  // TODO(ngakaassist): Replace with Isar + encryption for production.
  static const String mockCache = 'mock_cache';
}
