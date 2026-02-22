// NgakaAssist
// Form validation helpers.
// Keep messages short and clinical.

class Validators {
  static String? requiredField(String? v, {String label = 'Field'}) {
    if (v == null || v.trim().isEmpty) return '$label is required';
    return null;
  }

  static String? personName(String? v, {String label = 'Name'}) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return '$label is required';
    if (s.length < 2) return '$label is too short';
    // Letters, spaces, hyphens and apostrophes only.
    if (!RegExp(r"^[A-Za-z][A-Za-z\-' ]*[A-Za-z]$").hasMatch(s)) {
      return 'Enter a valid $label';
    }
    return null;
  }

  static String? bwNationalId(String? v, {String label = 'National ID'}) {
    final raw = (v ?? '').trim();
    if (raw.isEmpty) return '$label is required';

    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length != raw.replaceAll(RegExp(r'\s+'), '').length) {
      return '$label must be digits only';
    }

    // Botswana Omang is typically 9 digits.
    if (!RegExp(r'^\d{9}$').hasMatch(digits)) {
      return 'Omang must be 9 digits';
    }
    return null;
  }

  static String? bwPhoneNumber(String? v, {String label = 'Phone number'}) {
    final raw = (v ?? '').trim();
    if (raw.isEmpty) return '$label is required';

    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return 'Enter a valid $label';

    // Accept: 7 digits (local), 267XXXXXXX, +267XXXXXXX, or 00267XXXXXXX.
    final normalized = _tryNormalizeBwPhone(raw);
    if (normalized == null) {
      return 'Use +267XXXXXXX or 7 digits';
    }
    return null;
  }

  static String normalizeBwPhoneNumber(String raw) {
    return _tryNormalizeBwPhone(raw) ?? raw.trim();
  }

  static String? _tryNormalizeBwPhone(String raw) {
    final s = raw.trim();
    final digits = s.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length == 7) {
      return '+267$digits';
    }
    if (digits.length == 10 && digits.startsWith('267')) {
      return '+$digits';
    }
    if (digits.length == 12 && digits.startsWith('00267')) {
      return '+267${digits.substring(5)}';
    }
    return null;
  }
}
