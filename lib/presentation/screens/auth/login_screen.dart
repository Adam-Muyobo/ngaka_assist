// NgakaAssist
// Screen: Login.
// MVP: simple username/password to establish a session (mock by default).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/validators.dart';
import '../../state/auth_controller.dart';
import '../../widgets/app_background.dart';
import '../../widgets/section_card.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final isBusy = auth.isLoading;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Ngaka Assist',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Smart EMR - Voice-First Clinical Assistant',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    SectionCard(
                      title: 'Sign in',
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _username,
                              decoration: const InputDecoration(
                                labelText: 'Username',
                                hintText: 'e.g. clinician01',
                              ),
                              textInputAction: TextInputAction.next,
                              validator: (v) => Validators.requiredField(v, label: 'Username'),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _password,
                              decoration: const InputDecoration(
                                labelText: 'Password',
                              ),
                              obscureText: true,
                              onFieldSubmitted: (_) => _onLogin(context),
                              validator: (v) => Validators.requiredField(v, label: 'Password'),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: isBusy ? null : () => _onLogin(context),
                                child: Text(isBusy ? 'Signing in...' : 'Sign in'),
                              ),
                            ),
                            const SizedBox(height: 10),
                            // TODO(ngakaassist): Add password reset + SSO integration.
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (auth.hasError)
                      Text(
                        (auth.error is Exception) ? auth.error.toString() : (auth.error?.toString() ?? 'Login failed'),
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onLogin(BuildContext context) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final res = await ref
        .read(authControllerProvider.notifier)
        .login(username: _username.text.trim(), password: _password.text);

    if (!mounted) return;
    if (!res.isOk) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.failure?.message ?? 'Login failed')),
      );
    }
  }
}
