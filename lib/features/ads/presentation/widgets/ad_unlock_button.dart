import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/ad_providers.dart';
import 'ad_watching_dialog.dart';

/// Reusable button widget for unlocking questions via ads
/// Shows progress and handles ad watching flow
class AdUnlockButton extends ConsumerWidget {
  final VoidCallback? onQuestionsUnlocked;
  final bool isCompact;

  const AdUnlockButton({
    super.key,
    this.onQuestionsUnlocked,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canUnlock = ref.watch(canUnlockMoreQuestionsProvider);
    final adsNeeded = ref.watch(adsNeededForUnlockProvider);
    final adProgressMessage = ref.watch(adProgressMessageProvider);
    final unlockedQuestions = ref.watch(unlockedQuestionsTodayProvider);

    if (!canUnlock) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          // Unlocked questions counter (if any)
          unlockedQuestions.when(
            data: (count) => count > 0 
                ? Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$count ek soru kazandınız',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Main unlock button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showAdWatchingDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentGold,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  vertical: isCompact ? 12 : 16,
                  horizontal: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: isCompact ? _buildCompactContent(adsNeeded) : _buildFullContent(adProgressMessage, adsNeeded),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactContent(int adsNeeded) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.play_circle_filled, size: 20),
        const SizedBox(width: 8),
        Text(
          '$adsNeeded reklam = 5 soru',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildFullContent(String progressMessage, int adsNeeded) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.play_circle_filled,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daha Fazla Soru İçin',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    progressMessage,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '🎯 $adsNeeded reklam izle → 5 soru kazan',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showAdWatchingDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AdWatchingDialog(),
    );

    // If questions were unlocked, notify parent
    if (result == true && onQuestionsUnlocked != null) {
      onQuestionsUnlocked!();
    }
  }
}

/// Compact version of the ad unlock button for smaller spaces
class CompactAdUnlockButton extends StatelessWidget {
  final VoidCallback? onQuestionsUnlocked;

  const CompactAdUnlockButton({
    super.key,
    this.onQuestionsUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    return AdUnlockButton(
      onQuestionsUnlocked: onQuestionsUnlocked,
      isCompact: true,
    );
  }
}

/// Ad progress indicator widget for showing current status
class AdProgressIndicator extends ConsumerWidget {
  const AdProgressIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adsWatched = ref.watch(adsWatchedTodayProvider);
    final unlockedQuestions = ref.watch(unlockedQuestionsTodayProvider);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.lightGrey.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.analytics,
            color: AppTheme.primaryNavyBlue,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bugünkü İlerleme',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.darkGrey.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    adsWatched.when(
                      data: (count) => Text(
                        '$count reklam izlendi',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.primaryNavyBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      loading: () => const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      error: (_, __) => Text('--'),
                    ),
                    const SizedBox(width: 8),
                    Text('•', style: TextStyle(color: AppTheme.darkGrey)),
                    const SizedBox(width: 8),
                    unlockedQuestions.when(
                      data: (count) => Text(
                        '$count soru kazanıldı',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.primaryNavyBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      loading: () => const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      error: (_, __) => Text('--'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}