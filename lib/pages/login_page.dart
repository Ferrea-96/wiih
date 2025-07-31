import 'package:flutter/material.dart';
import 'package:wiih/flutter/auth_service.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.login),
          label: const Text('Sign in with Google'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(fontSize: 18),
          ),
          onPressed: () async {
            try {
              final user = await AuthService.signInWithGoogle();
              if (user != null) {}
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Login failed. Please try again.')),
              );
            }
          },
        ),
      ),
    );
  }
}
