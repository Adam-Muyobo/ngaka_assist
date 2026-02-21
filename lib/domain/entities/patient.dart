// NgakaAssist
// Domain entity: Patient.
// Mirrors backend Patient table (MVP fields only).

class Patient {
  const Patient({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.gender,
    this.nationalId,
    this.phone,
  });

  final String id;
  final String firstName;
  final String lastName;
  final DateTime? dateOfBirth;
  final String gender;

  // TODO(ngakaassist): Add address, next of kin, identifiers, facility linkage.
  final String? nationalId;
  final String? phone;

  String get displayName => '$lastName, $firstName';

  factory Patient.fromJson(Map<String, dynamic> json) {
    DateTime? dob;
    final dobRaw = json['date_of_birth'] ?? json['dob'];
    if (dobRaw is String && dobRaw.isNotEmpty) {
      dob = DateTime.tryParse(dobRaw);
    }
    return Patient(
      id: (json['id'] ?? '').toString(),
      firstName: (json['first_name'] ?? json['firstName'] ?? '').toString(),
      lastName: (json['last_name'] ?? json['lastName'] ?? '').toString(),
      dateOfBirth: dob,
      gender: (json['gender'] ?? 'unknown').toString(),
      nationalId: json['national_id']?.toString(),
      phone: json['phone']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'first_name': firstName,
        'last_name': lastName,
        'date_of_birth': dateOfBirth?.toIso8601String(),
        'gender': gender,
        if (nationalId != null) 'national_id': nationalId,
        if (phone != null) 'phone': phone,
      };
}
