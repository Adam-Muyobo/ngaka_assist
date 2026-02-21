// NgakaAssist
// Entry point for Flutter (mobile + web).
// Keeps initialization minimal and delegates UI setup to lib/app/app.dart.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/app.dart';
import 'core/storage/hive_boxes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Local persistence for sync queue / lightweight cache.
  // TODO(ngakaassist): Add encryption-at-rest hardening for sensitive data.
  await Hive.initFlutter();
  await Hive.openBox<String>(HiveBoxes.syncJobs);
  await Hive.openBox<String>(HiveBoxes.mockCache);

  runApp(const ProviderScope(child: NgakaAssistApp()));
}
