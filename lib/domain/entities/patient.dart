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
    final dobRaw = json['birthDate'] ?? json['date_of_birth'] ?? json['dob'];
    if (dobRaw is String && dobRaw.isNotEmpty) {
      dob = DateTime.tryParse(dobRaw);
    }

    String firstName = '';
    String lastName = '';
    final nameList = (json['name'] as List?)?.whereType<Map>().toList();
    if (nameList != null && nameList.isNotEmpty) {
      final n0 = nameList.first.cast<String, dynamic>();
      lastName = (n0['family'] ?? '').toString();
      final given = (n0['given'] as List?)?.whereType<String>().toList() ?? const <String>[];
      firstName = given.isNotEmpty ? given.first : '';
    }

    String? nationalId;
    final identifiers = (json['identifier'] as List?)?.whereType<Map>().toList() ?? const <Map>[];
    for (final id in identifiers) {
      final m = id.cast<String, dynamic>();
      if ((m['system'] ?? '').toString() == 'national_id') {
        nationalId = m['value']?.toString();
        break;
      }
    }

    String? phone;
    final telecom = (json['telecom'] as List?)?.whereType<Map>().toList() ?? const <Map>[];
    for (final t in telecom) {
      final m = t.cast<String, dynamic>();
      if ((m['system'] ?? '').toString() == 'phone') {
        phone = m['value']?.toString();
        break;
      }
    }

    return Patient(
      id: (json['id'] ?? '').toString(),
      firstName: firstName.isNotEmpty
          ? firstName
          : (json['first_name'] ?? json['firstName'] ?? '').toString(),
      lastName:
          lastName.isNotEmpty ? lastName : (json['last_name'] ?? json['lastName'] ?? '').toString(),
      dateOfBirth: dob,
      gender: (json['gender'] ?? json['sex'] ?? 'unknown').toString(),
      nationalId: nationalId ?? json['national_id']?.toString(),
      phone: phone ?? json['phone']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    // Backend expects these fields (not FHIR resource fields) for create/update.
    final dob = dateOfBirth == null ? null : dateOfBirth!.toIso8601String().split('T').first;
    final sex = (gender == 'unknown' || gender.trim().isEmpty) ? 'other' : gender;
    return {
      'first_name': firstName,
      'last_name': lastName,
      if (dob != null) 'date_of_birth': dob,
      // Backend schema uses `sex`; frontend uses `gender`.
      'sex': sex,
      if (nationalId != null) 'national_id': nationalId,
      if (phone != null) 'phone': phone,
    };
  }
}
