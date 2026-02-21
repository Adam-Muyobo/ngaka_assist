// NgakaAssist
// Domain entity: ICD-10 suggestion.
// Mirrors backend Diagnosis suggestion entity (MVP fields only).

class Icd10Suggestion {
  const Icd10Suggestion({
    required this.code,
    required this.description,
    required this.confidence,
    required this.accepted,
  });

  final String code;
  final String description;
  final double confidence;
  final bool accepted;

  factory Icd10Suggestion.fromJson(Map<String, dynamic> json) {
    return Icd10Suggestion(
      code: (json['code'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      confidence: (json['confidence'] is num) ? (json['confidence'] as num).toDouble() : 0.0,
      accepted: (json['accepted'] ?? false) == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'description': description,
        'confidence': confidence,
        'accepted': accepted,
      };

  Icd10Suggestion copyWith({bool? accepted}) {
    return Icd10Suggestion(
      code: code,
      description: description,
      confidence: confidence,
      accepted: accepted ?? this.accepted,
    );
  }
}
