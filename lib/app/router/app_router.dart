// NgakaAssist
// go_router configuration.
// Implements an auth gate and a responsive shell (bottom nav on phones, rail on wide).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/encounters/consultation_mode_screen.dart';
import '../../presentation/screens/encounters/icd10_suggestions_screen.dart';
import '../../presentation/screens/encounters/review_sign_screen.dart';
import '../../presentation/screens/encounters/soap_editor_screen.dart';
import '../../presentation/screens/home/home_dashboard_screen.dart';
import '../../presentation/screens/patients/create_patient_screen.dart';
import '../../presentation/screens/patients/patient_profile_screen.dart';
import '../../presentation/screens/patients/patient_search_screen.dart';
import '../../presentation/screens/patients/start_encounter_screen.dart';
import '../../presentation/screens/sync/sync_queue_screen.dart';
import '../../presentation/state/auth_controller.dart';
import '../../presentation/widgets/adaptive_shell_scaffold.dart';

/// Riverpod provider for the app router.
///
/// We keep the router in a provider so it can react to auth changes.
final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = RouterRefreshNotifier(ref);
  ref.onDispose(notifier.dispose);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: notifier,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider).valueOrNull;
      final isAuthed = auth?.isAuthenticated ?? false;
      final isLoggingIn = state.matchedLocation == '/login';

      if (!isAuthed && !isLoggingIn) return '/login';
      if (isAuthed && isLoggingIn) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),

      /// Main shell (Home, Patients, Sync).
      StatefulShellRoute.indexedStack(
        builder: (context, state, navShell) {
          return AdaptiveShellScaffold(navigationShell: navShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeDashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/patients',
                builder: (context, state) => const PatientSearchScreen(),
                routes: [
                  GoRoute(
                    path: 'create',
                    builder: (context, state) => const CreatePatientScreen(),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return PatientProfileScreen(patientId: id);
                    },
                    routes: [
                      GoRoute(
                        path: 'start-encounter',
                        builder: (context, state) {
                          final id = state.pathParameters['id']!;
                          return StartEncounterScreen(patientId: id);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/sync',
                builder: (context, state) => const SyncQueueScreen(),
              ),
            ],
          ),
        ],
      ),

      /// Encounter flow routes (outside shell so they can take full focus).
      GoRoute(
        path: '/encounters/:eid/consult',
        builder: (context, state) {
          final eid = state.pathParameters['eid']!;
          return ConsultationModeScreen(encounterId: eid);
        },
      ),
      GoRoute(
        path: '/encounters/:eid/soap',
        builder: (context, state) {
          final eid = state.pathParameters['eid']!;
          return SoapEditorScreen(encounterId: eid);
        },
      ),
      GoRoute(
        path: '/encounters/:eid/icd10',
        builder: (context, state) {
          final eid = state.pathParameters['eid']!;
          return Icd10SuggestionsScreen(encounterId: eid);
        },
      ),
      GoRoute(
        path: '/encounters/:eid/review',
        builder: (context, state) {
          final eid = state.pathParameters['eid']!;
          return ReviewSignScreen(encounterId: eid);
        },
      ),
    ],
  );
});

/// Notifies go_router when auth state changes.
class RouterRefreshNotifier extends ChangeNotifier {
  RouterRefreshNotifier(this.ref) {
    // Whenever auth controller emits a new value, refresh the router.
    _sub = ref.listen(authControllerProvider, (_, __) => notifyListeners());
  }

  final Ref ref;
  late final ProviderSubscription _sub;

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}
