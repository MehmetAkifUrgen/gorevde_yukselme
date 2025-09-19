import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class PurchaseLoadingDialog extends StatelessWidget {
  const PurchaseLoadingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentGold),
                ),
              ),
            const SizedBox(height: 24),
            Text(
              'Satın Alma İşlemi',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryNavyBlue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Lütfen bekleyin...',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.darkGrey,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Bu işlem birkaç saniye sürebilir.\nLütfen uygulamayı kapatmayın.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.darkGrey,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}