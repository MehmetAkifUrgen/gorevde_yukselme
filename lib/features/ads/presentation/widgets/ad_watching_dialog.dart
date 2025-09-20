import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/ad_providers.dart';

/// Dialog for watching ads to unlock additional questions
/// Implements the "Watch 3 ads for 5 questions" feature as per PRD
class AdWatchingDialog extends ConsumerStatefulWidget {
  const AdWatchingDialog({super.key});

  @override
  ConsumerState<AdWatchingDialog> createState() => _AdWatchingDialogState();
}

class _AdWatchingDialogState extends ConsumerState<AdWatchingDialog>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adWatchingState = ref.watch(adWatchingStateProvider);
    final adsNeeded = ref.watch(adsNeededForUnlockProvider);
    final adProgressMessage = ref.watch(adProgressMessageProvider);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.play_circle_filled,
                    color: AppTheme.accentGold,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reklam İzle',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryNavyBlue,
                        ),
                      ),
                      Text(
                        'Daha fazla soru için',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.darkGrey.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close,
                    color: AppTheme.darkGrey.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Progress Section
            _buildProgressSection(adWatchingState, adsNeeded),

            const SizedBox(height: 24),

            // Message
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.lightGrey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                adProgressMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.primaryNavyBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            _buildActionButtons(adWatchingState),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection(AdWatchingState state, int adsNeeded) {
    return Column(
      children: [
        // Circular Progress
        SizedBox(
          width: 120,
          height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background circle
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.lightGrey.withValues(alpha: 0.3),
                ),
              ),
              
              // Progress circle
              if (state.status == AdWatchingStatus.watching)
                AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return CircularProgressIndicator(
                      value: _progressAnimation.value,
                      strokeWidth: 8,
                      backgroundColor: AppTheme.lightGrey.withValues(alpha: 0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentGold),
                    );
                  },
                ),
              
              // Center content
              if (state.status == AdWatchingStatus.watching)
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Icon(
                        Icons.play_arrow,
                        color: AppTheme.accentGold,
                        size: 40,
                      ),
                    );
                  },
                )
              else
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$adsNeeded',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryNavyBlue,
                      ),
                    ),
                    Text(
                      'reklam kaldı',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.darkGrey.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Status message
        _buildStatusMessage(state),
      ],
    );
  }

  Widget _buildStatusMessage(AdWatchingState state) {
    String message;
    Color color;
    IconData icon;

    switch (state.status) {
      case AdWatchingStatus.idle:
        message = 'Reklam izlemeye hazır';
        color = AppTheme.primaryNavyBlue;
        icon = Icons.play_circle_outline;
        break;
      case AdWatchingStatus.watching:
        message = 'Reklam izleniyor...';
        color = AppTheme.accentGold;
        icon = Icons.play_circle_filled;
        break;
      case AdWatchingStatus.completed:
        if (state.questionsUnlocked) {
          message = '🎉 5 soru daha kazandınız!';
          color = Colors.green;
          icon = Icons.check_circle;
        } else {
          message = 'Reklam tamamlandı';
          color = AppTheme.primaryNavyBlue;
          icon = Icons.check_circle_outline;
        }
        break;
      case AdWatchingStatus.error:
        message = 'Bir hata oluştu';
        color = Colors.red;
        icon = Icons.error_outline;
        break;
      default:
        message = '';
        color = AppTheme.primaryNavyBlue;
        icon = Icons.info_outline;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          message,
          style: TextStyle(
            fontSize: 16,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(AdWatchingState state) {
    return Row(
      children: [
        // Cancel button
        Expanded(
          child: OutlinedButton(
            onPressed: state.status == AdWatchingStatus.watching 
                ? null 
                : () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: AppTheme.darkGrey.withValues(alpha: 0.3)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'İptal',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.darkGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),

        const SizedBox(width: 16),

        // Watch ad button
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: state.status == AdWatchingStatus.watching 
                ? null 
                : () => _watchAd(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentGold,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (state.status == AdWatchingStatus.watching)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                else
                  Icon(Icons.play_arrow, size: 20),
                const SizedBox(width: 8),
                Text(
                  state.status == AdWatchingStatus.watching 
                      ? 'İzleniyor...' 
                      : 'Reklam İzle',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _watchAd() async {
    _progressController.reset();
    _progressController.forward();
    
    await ref.read(adWatchingStateProvider.notifier).watchAd();
    
    final state = ref.read(adWatchingStateProvider);
    if (state.questionsUnlocked) {
      // Show success animation and close dialog after delay
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    }
  }
}