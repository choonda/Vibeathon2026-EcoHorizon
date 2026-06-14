import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/auth_controller.dart';
import '../../../shared/widgets/app_button.dart';

class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit({required bool signUp}) async {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(authControllerProvider.notifier);
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (signUp) {
      await notifier.signUpWithPassword(email: email, password: password);
    } else {
      await notifier.signInWithPassword(email: email, password: password);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'EcoHorizon',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sign in to load your Supabase profile and trip history.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Email is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password is required';
                            }
                            if (value.length < 6) {
                              return 'Use at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        if (authState.hasError) ...[
                          Text(
                            authState.error.toString(),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        AppButton(
                          label:
                              authState.isLoading ? 'Signing in...' : 'Sign In',
                          onPressed: authState.isLoading
                              ? () {}
                              : () => _submit(signUp: false),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: authState.isLoading
                              ? null
                              : () => _submit(signUp: true),
                          child: const Text('Create account'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
