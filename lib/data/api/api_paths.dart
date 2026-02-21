// NgakaAssist
// Backend endpoint paths.
// Keep these as constants to match backend routing 1:1 and allow easy edits.

class ApiPaths {
  static const String login = '/auth/login';

  static const String patients = '/patients';
  static String patientById(String id) => '/patients/$id';

  static const String encounters = '/encounters';
  static String encounterById(String id) => '/encounters/$id';
  static String encounterAudio(String id) => '/encounters/$id/audio';
  static String encounterTranscript(String id) => '/encounters/$id/transcript';
  static String encounterSoapDraft(String id) => '/encounters/$id/soap_draft';
  static String encounterIcd10Suggestions(String id) => '/encounters/$id/icd10_suggestions';
  static String encounterSign(String id) => '/encounters/$id/sign';
}
