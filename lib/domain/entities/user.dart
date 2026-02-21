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
