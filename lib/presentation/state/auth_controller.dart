// NgakaAssist
// Auth controller.
// Exposes login/logout and an in-memory session state for routing.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/result.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import 'providers.dart';

class AuthState {
  const AuthState({required this.accessToken, required this.user});

  final String? accessToken;
  final User? user;

  bool get isAuthenticated => accessToken != null && accessToken!.isNotEmpty;
}

final authControllerProvider = AsyncNotifierProvider<AuthController, AuthState>(AuthController.new);

class AuthController extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    // Initialize from stored token (if any).
    final repo = ref.watch(authRepositoryProvider);
    final session = await repo.currentSession();
    final AuthSession? s = session.data;
    return AuthState(accessToken: s?.accessToken, user: s?.user);
  }

  Future<AppResult<void>> login({required String username, required String password}) async {
    state = const AsyncLoading();
    final repo = ref.read(authRepositoryProvider);
    final res = await repo.login(username: username, password: password);
    return res.when(
      ok: (session) async {
        state = AsyncData(AuthState(accessToken: session.accessToken, user: session.user));
        return AppResult.ok(null);
      },
      err: (f) async {
        state = AsyncError(f, StackTrace.current);
        return AppResult.err(f);
      },
    );
  }

  Future<void> logout() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.logout();
    state = const AsyncData(AuthState(accessToken: null, user: null));
  }
}
