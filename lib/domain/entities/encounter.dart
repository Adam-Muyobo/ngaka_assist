// NgakaAssist
// Domain entity: Encounter.
// Mirrors backend Encounter table (MVP fields only).

class Encounter {
  const Encounter({
    required this.id,
    required this.patientId,
    required this.type,
    required this.startedAt,
    this.signedAt,
    this.status,
  });

  final String id;
  final String patientId;
  final String type;
  final DateTime startedAt;
  final DateTime? signedAt;
  final String? status;

  bool get isSigned => signedAt != null;

  factory Encounter.fromJson(Map<String, dynamic> json) {
    return Encounter(
      id: (json['id'] ?? '').toString(),
      patientId: (json['patient_id'] ?? '').toString(),
      type: (json['type'] ?? 'consult').toString(),
      startedAt: DateTime.tryParse((json['started_at'] ?? '').toString()) ?? DateTime.now(),
      signedAt: json['signed_at'] == null ? null : DateTime.tryParse(json['signed_at'].toString()),
      status: json['status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'patient_id': patientId,
        'type': type,
        'started_at': startedAt.toIso8601String(),
        'signed_at': signedAt?.toIso8601String(),
        if (status != null) 'status': status,
      };
}
