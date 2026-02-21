// NgakaAssist
// App-wide constants and environment toggles.
// Keep this file simple and grep-friendly.

// Mock mode toggle (required).
//
// Default: true so the app runs even when backend is unavailable.
// Override at build-time with:
//   flutter run --dart-define=NGAKA_USE_MOCK=false
const bool _kUseMockFromEnv = bool.fromEnvironment('NGAKA_USE_MOCK', defaultValue: true);
bool kUseMockData = _kUseMockFromEnv;

// Backend base URL (placeholder).
// TODO(ngakaassist): Replace with real backend URL and environment strategy.
const String kBackendBaseUrlDefault = 'https://api.ngakaassist.example';
const String kBackendBaseUrl = String.fromEnvironment(
  'NGAKA_API_BASE_URL',
  defaultValue: kBackendBaseUrlDefault,
);

// Layout breakpoints.
const double kBpCompact = 600;
const double kBpWide = 1024;

// Simple network timeouts.
const Duration kApiConnectTimeout = Duration(seconds: 10);
const Duration kApiReceiveTimeout = Duration(seconds: 20);

// General UX constants.
const Duration kUiDebounce = Duration(milliseconds: 300);
