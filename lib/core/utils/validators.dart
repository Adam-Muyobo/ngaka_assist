// NgakaAssist
// Form validation helpers.
// Keep messages short and clinical.

class Validators {
  static String? requiredField(String? v, {String label = 'Field'}) {
    if (v == null || v.trim().isEmpty) return '$label is required';
    return null;
  }
}
