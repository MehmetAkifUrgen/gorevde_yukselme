import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Short delay then navigate to home
    Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        context.go(AppRouter.home);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryNavyBlue,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.secondaryWhite),
            ),
            SizedBox(height: 16),
            Text(
              'Yükleniyor...',
              style: TextStyle(
                color: AppTheme.secondaryWhite,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
