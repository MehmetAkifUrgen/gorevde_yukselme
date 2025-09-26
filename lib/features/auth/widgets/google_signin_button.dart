import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/auth_providers.dart';
import '../../../core/utils/error_utils.dart';

class GoogleSignInButton extends ConsumerWidget {
  const GoogleSignInButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authNotifier = ref.read(authNotifierProvider.notifier);
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          return Column(
            children: [
              Text('Hoş geldiniz, ${user.displayName ?? user.email}!'),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  try {
                    await authNotifier.signOut();
                  } catch (e) {
                    if (context.mounted) {
                      ErrorUtils.showGeneralError(context, e);
                    }
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Çıkış Yap'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          );
        }

        return ElevatedButton.icon(
          onPressed: () async {
            try {
              await authNotifier.signInWithGoogle();
            } catch (e) {
              if (context.mounted) {
                ErrorUtils.showGeneralError(context, e);
              }
            }
          },
          icon: Image.asset(
            'assets/images/google_logo.png',
            height: 24,
            width: 24,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.login, color: Colors.white);
            },
          ),
          label: const Text('Google ile Giriş Yap'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4285F4),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, stackTrace) => Column(
        children: [
          const Icon(Icons.error, color: Colors.red),
          const SizedBox(height: 8),
          Text('Hata: $error'),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(authStateProvider);
            },
            child: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }
}