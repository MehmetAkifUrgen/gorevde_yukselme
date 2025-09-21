import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/exam_model.dart';

class ExamResultsModal extends StatelessWidget {
  final ExamResult result;
  final VoidCallback onReviewAnswers;
  final VoidCallback onRetakeExam;
  final VoidCallback onBackToHome;

  const ExamResultsModal({
    super.key,
    required this.result,
    required this.onReviewAnswers,
    required this.onRetakeExam,
    required this.onBackToHome,
  });

  Color get _scoreColor {
    if (result.scorePercentage >= 80) return AppTheme.successGreen;
    if (result.scorePercentage >= 60) return AppTheme.accentGold;
    return AppTheme.errorRed;
  }

  String get _performanceMessage {
    if (result.scorePercentage >= 80) return 'Mükemmel!';
    if (result.scorePercentage >= 60) return 'İyi!';
    return 'Geliştirilmeli';
  }

  IconData get _performanceIcon {
    if (result.scorePercentage >= 80) return Icons.emoji_events;
    if (result.scorePercentage >= 60) return Icons.thumb_up;
    return Icons.trending_up;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  _performanceIcon,
                  color: _scoreColor,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sınav Tamamlandı!',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryNavyBlue,
                        ),
                      ),
                      Text(
                        _performanceMessage,
                        style: TextStyle(
                          fontSize: 16,
                          color: _scoreColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Score circle
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _scoreColor,
                  width: 8,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${result.scorePercentage.toInt()}%',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: _scoreColor,
                      ),
                    ),
                    Text(
                      '${result.correctAnswers}/${result.totalQuestions}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Statistics
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.lightGrey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildStatRow('Toplam Soru', '${result.totalQuestions}'),
                  const SizedBox(height: 8),
                  _buildStatRow('Doğru Cevap', '${result.correctAnswers}', 
                      color: AppTheme.successGreen),
                  const SizedBox(height: 8),
                  _buildStatRow('Yanlış Cevap', '${result.incorrectAnswers}', 
                      color: AppTheme.errorRed),
                  const SizedBox(height: 8),
                  _buildStatRow('Boş Cevap', '${result.blankAnswers}', 
                      color: Colors.grey[600]!),
                  const SizedBox(height: 8),
                  _buildStatRow('Süre', _formatDuration(result.timeTaken)),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Action buttons
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onReviewAnswers,
                    icon: const Icon(Icons.visibility),
                    label: const Text('Cevapları İncele'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryNavyBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onRetakeExam,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tekrar Çöz'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryNavyBlue,
                          side: const BorderSide(color: AppTheme.primaryNavyBlue),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onBackToHome,
                        icon: const Icon(Icons.home),
                        label: const Text('Ana Sayfa'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey[600],
                          side: BorderSide(color: Colors.grey[400]!),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.primaryNavyBlue,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color ?? AppTheme.primaryNavyBlue,
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }
}