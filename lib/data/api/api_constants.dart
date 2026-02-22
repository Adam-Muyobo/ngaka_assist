// NgakaAssist
// Single source of truth for API base URL + endpoint paths.

import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;

class ApiConstants {
  // Override at build/run time:
  //   flutter run --dart-define=NGAKA_API_BASE_URL=http://10.0.2.2:5000/api/v1
  // If not provided:
  // - Android emulator uses 10.0.2.2
  // - iOS simulator / desktop uses localhost
  static String get baseUrl {
    const fromEnv = String.fromEnvironment('NGAKA_API_BASE_URL', defaultValue: '');
    if (fromEnv.isNotEmpty) return fromEnv;
    if (kIsWeb) return 'http://localhost:5000/api/v1';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5000/api/v1';
    }
    return 'http://localhost:5000/api/v1';
  }

  // Auth
  static const String authLogin = '/auth/login';
  static const String authRefresh = '/auth/refresh';
  static const String authMe = '/auth/me';
  static const String authLogout = '/auth/logout';

  // Patients
  static const String patients = '/patients';
  static String patientById(String id) => '/patients/$id';

  // Encounters
  static const String encounters = '/encounters';
  static String encounterById(String id) => '/encounters/$id';
  static String encounterTranscript(String id) => '/encounters/$id/transcript';
  static String encounterTranscriptNlp(String id) => '/encounters/$id/transcript/nlp';
  static String encounterSoap(String id) => '/encounters/$id/soap';
  static String encounterDiagnosisSuggestions(String id) =>
      '/encounters/$id/diagnosis/suggestions';
  static String encounterDiagnosis(String id) => '/encounters/$id/diagnosis';
  static String encounterSign(String id) => '/encounters/$id/sign';

  // AI
  static const String aiTranscribe = '/ai/transcribe';
  static const String aiStructureNote = '/ai/structure-note';
  static const String aiDifferentials = '/ai/differentials';
}
