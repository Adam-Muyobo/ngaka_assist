// NgakaAssist
// Domain entity: Sync job.
// Represents offline queue work (upload audio, push note updates, sign encounter, etc.).

enum SyncJobStatus { queued, running, success, failed }

class SyncJob {
  const SyncJob({
    required this.id,
    required this.type,
    required this.status,
    required this.retries,
    required this.createdAt,
    required this.payloadRef,
    this.lastError,
  });

  final String id;
  final String type;
  final SyncJobStatus status;
  final int retries;
  final DateTime createdAt;
  final Map<String, dynamic> payloadRef;
  final String? lastError;

  factory SyncJob.fromJson(Map<String, dynamic> json) {
    final statusRaw = (json['status'] ?? 'queued').toString();
    final status = switch (statusRaw) {
      'running' => SyncJobStatus.running,
      'success' => SyncJobStatus.success,
      'failed' => SyncJobStatus.failed,
      _ => SyncJobStatus.queued,
    };

    return SyncJob(
      id: (json['id'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      status: status,
      retries: (json['retries'] is num) ? (json['retries'] as num).toInt() : 0,
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()) ?? DateTime.now(),
      payloadRef: (json['payload_ref'] is Map<String, dynamic>)
          ? (json['payload_ref'] as Map<String, dynamic>)
          : <String, dynamic>{},
      lastError: json['last_error']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'status': status.name,
        'retries': retries,
        'created_at': createdAt.toIso8601String(),
        'payload_ref': payloadRef,
        if (lastError != null) 'last_error': lastError,
      };

  SyncJob copyWith({SyncJobStatus? status, int? retries, String? lastError}) {
    return SyncJob(
      id: id,
      type: type,
      status: status ?? this.status,
      retries: retries ?? this.retries,
      createdAt: createdAt,
      payloadRef: payloadRef,
      lastError: lastError ?? this.lastError,
    );
  }
}
