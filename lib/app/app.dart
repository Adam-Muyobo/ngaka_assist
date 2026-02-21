// NgakaAssist
// Root application widget.
// Sets up Material 3 theming and go_router-based navigation.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'router/app_router.dart';
import 'theme/app_theme.dart';

class NgakaAssistApp extends ConsumerWidget {
  const NgakaAssistApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'NgakaAssist',
      theme: AppTheme.light(),
      // English-first; keep i18n ready.
      // TODO(ngakaassist): Add Setswana language pack + clinician-controlled language switch.
      supportedLocales: const [Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}
