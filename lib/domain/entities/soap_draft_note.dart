// NgakaAssist
// Domain entity: SOAP draft note.
// Mirrors backend Note(SOAP) table (MVP fields only).

class SoapDraftNote {
  const SoapDraftNote({
    required this.encounterId,
    required this.subjective,
    required this.objective,
    required this.assessment,
    required this.plan,
    required this.transcript,
    required this.aiGenerated,
    required this.updatedAt,
  });

  final String encounterId;

  final String subjective;
  final String objective;
  final String assessment;
  final String plan;

  final String transcript;

  // Flags from AI pipeline.
  final bool aiGenerated;

  final DateTime updatedAt;

  factory SoapDraftNote.fromJson(Map<String, dynamic> json) {
    return SoapDraftNote(
      encounterId: (json['encounter_id'] ?? json['encounterId'] ?? '').toString(),
      subjective: (json['subjective'] ?? '').toString(),
      objective: (json['objective'] ?? '').toString(),
      assessment: (json['assessment'] ?? '').toString(),
      plan: (json['plan'] ?? '').toString(),
      transcript: (json['transcript'] ?? '').toString(),
      aiGenerated: (json['ai_generated'] ?? json['aiGenerated'] ?? false) == true,
      updatedAt: DateTime.tryParse((json['updated_at'] ?? '').toString()) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'encounter_id': encounterId,
        'subjective': subjective,
        'objective': objective,
        'assessment': assessment,
        'plan': plan,
        'transcript': transcript,
        'ai_generated': aiGenerated,
        'updated_at': updatedAt.toIso8601String(),
      };

  SoapDraftNote copyWith({
    String? subjective,
    String? objective,
    String? assessment,
    String? plan,
    String? transcript,
    bool? aiGenerated,
    DateTime? updatedAt,
  }) {
    return SoapDraftNote(
      encounterId: encounterId,
      subjective: subjective ?? this.subjective,
      objective: objective ?? this.objective,
      assessment: assessment ?? this.assessment,
      plan: plan ?? this.plan,
      transcript: transcript ?? this.transcript,
      aiGenerated: aiGenerated ?? this.aiGenerated,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
