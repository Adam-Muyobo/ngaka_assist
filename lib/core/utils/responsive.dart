// NgakaAssist
// Responsive helpers.
// Keep layout decisions consistent across screens (mobile + tablet + web).

import '../constants.dart';

enum ScreenSize { compact, medium, wide }

ScreenSize screenSizeForWidth(double width) {
  if (width >= kBpWide) return ScreenSize.wide;
  if (width >= kBpCompact) return ScreenSize.medium;
  return ScreenSize.compact;
}

bool isWide(double width) => width >= kBpWide;
