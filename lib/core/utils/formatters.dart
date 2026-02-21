// NgakaAssist
// Small formatting helpers (dates, labels).
// TODO(ngakaassist): Add clinician-configurable formats per facility.

import 'package:intl/intl.dart';

class AppFormatters {
  static final DateFormat _dateTime = DateFormat('yyyy-MM-dd HH:mm');

  static String dateTime(DateTime dt) => _dateTime.format(dt);
}
