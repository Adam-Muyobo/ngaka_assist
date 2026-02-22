// NgakaAssist
// Entry point for Flutter (mobile + web).
// Keeps initialization minimal and delegates UI setup to lib/app/app.dart.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/app.dart';
import 'core/storage/hive_boxes.dart';
import 'package:http/http.dart' as http;


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Local persistence for sync queue / lightweight cache.
  // TODO(ngakaassist): Add encryption-at-rest hardening for sensitive data.
  await Hive.initFlutter();
  await Hive.openBox<String>(HiveBoxes.syncJobs);
  await Hive.openBox<String>(HiveBoxes.mockCache);

  runApp(const ProviderScope(child: NgakaAssistApp()));
}

Future<void> fetchData() async {
  final response = await http.get(
    Uri.parse("http://192.168.1.100:5000/api"),
  );

  if (response.statusCode == 200) {
    print('success');
    print(response.body);
  }
}


