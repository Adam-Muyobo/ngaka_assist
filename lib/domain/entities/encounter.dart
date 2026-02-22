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
    // Backend returns a FHIR-ish Encounter resource.
    String patientId = (json['patient_id'] ?? '').toString();
    final subject = (json['subject'] as Map?)?.cast<String, dynamic>();
    final ref = subject?['reference']?.toString() ?? '';
    if (ref.startsWith('Patient/')) {
      patientId = ref.substring('Patient/'.length);
    }

    String type = (json['type'] ?? '').toString();
    final clazz = (json['class'] as Map?)?.cast<String, dynamic>();
    final classCode = clazz?['code']?.toString();
    if ((classCode ?? '').isNotEmpty) type = classCode!;

    DateTime startedAt = DateTime.now();
    final period = (json['period'] as Map?)?.cast<String, dynamic>();
    final startRaw = (period?['start'] ?? json['started_at'] ?? '').toString();
    final parsedStart = DateTime.tryParse(startRaw);
    if (parsedStart != null) startedAt = parsedStart;

    return Encounter(
      id: (json['id'] ?? '').toString(),
      patientId: patientId,
      type: type.isEmpty ? 'consult' : type,
      startedAt: startedAt,
      signedAt: json['signed_at'] == null ? null : DateTime.tryParse(json['signed_at'].toString()),
      status: (json['status'] ?? '').toString().isEmpty ? null : json['status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        // Used only in local/mock flows.
        'id': id,
        'patient_id': patientId,
        'encounter_type': type,
        'started_at': startedAt.toIso8601String(),
        'signed_at': signedAt?.toIso8601String(),
        if (status != null) 'status': status,
      };
}
