// NgakaAssist
// App-wide constants and environment toggles.
// Keep this file simple and grep-friendly.

// Mock mode toggle (required).
//
// Default: false (backend-connected).
// Override at build-time with:
//   flutter run --dart-define=NGAKA_USE_MOCK=true
const bool _kUseMockFromEnv = bool.fromEnvironment('NGAKA_USE_MOCK', defaultValue: false);
bool kUseMockData = _kUseMockFromEnv;

// Layout breakpoints.
const double kBpCompact = 600;
const double kBpWide = 1024;

// Simple network timeouts.
const Duration kApiConnectTimeout = Duration(seconds: 10);
const Duration kApiReceiveTimeout = Duration(seconds: 20);

// General UX constants.
const Duration kUiDebounce = Duration(milliseconds: 300);
