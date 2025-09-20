import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ExamTimerWidget extends StatelessWidget {
  final int remainingSeconds;
  final int totalSeconds;

  const ExamTimerWidget({
    super.key,
    required this.remainingSeconds,
    required this.totalSeconds,
  });

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
  }

  Color _getTimerColor() {
    final percentage = remainingSeconds / totalSeconds;
    if (percentage > 0.5) {
      return Colors.white;
    } else if (percentage > 0.25) {
      return AppTheme.warningYellow;
    } else {
      return AppTheme.errorRed;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            color: _getTimerColor(),
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            _formatTime(remainingSeconds),
            style: TextStyle(
              color: _getTimerColor(),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}