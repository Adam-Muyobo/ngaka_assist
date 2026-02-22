// NgakaAssist
// Domain entity: User.
// Mirrors backend User table (MVP fields only).

class User {
  const User({
    required this.id,
    required this.name,
    required this.role,
    this.facilityId,
  });

  final String id;
  final String name;
  final String role;

  // TODO(ngakaassist): Multi-facility support (facility, departments, permissions).
  final String? facilityId;

  factory User.fromJson(Map<String, dynamic> json) {
    // Backend may return a FHIR-ish Practitioner resource.
    if ((json['resourceType'] ?? '').toString() == 'Practitioner') {
      final nameList = (json['name'] as List?)?.whereType<Map>().toList() ?? const <Map>[];
      final first = nameList.isEmpty ? const <String, dynamic>{} : nameList.first.cast<String, dynamic>();
      final family = (first['family'] ?? '').toString();
      final given = (first['given'] as List?)?.whereType<String>().toList() ?? const <String>[];
      final displayName = ([...given, family].where((p) => p.trim().isNotEmpty).join(' ')).trim();

      final ext = (json['extension'] as Map?)?.cast<String, dynamic>() ?? const <String, dynamic>{};
      final role = (ext['role'] ?? json['role'] ?? 'clinician').toString();

      return User(
        id: (json['id'] ?? '').toString(),
        name: displayName.isEmpty ? 'Clinician' : displayName,
        role: role,
        facilityId: (json['facility_id'] ?? '').toString().isEmpty ? null : json['facility_id']?.toString(),
      );
    }

    return User(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? json['full_name'] ?? '').toString(),
      role: (json['role'] ?? 'clinician').toString(),
      facilityId: json['facility_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'role': role,
        if (facilityId != null) 'facility_id': facilityId,
      };
}
