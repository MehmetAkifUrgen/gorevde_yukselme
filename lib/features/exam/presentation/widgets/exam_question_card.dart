import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/question_model.dart';

class ExamQuestionCard extends StatelessWidget {
  final Question question;
  final int? selectedAnswerIndex;
  final Function(int) onAnswerSelected;
  final bool isReviewMode;
  final bool showCorrectAnswer;
  final bool showAnswerFeedback;
  final double fontSize;
  final VoidCallback? onShowSolution;
  final VoidCallback? onStarToggle;
  final bool? isStarredOverride;

  const ExamQuestionCard({
    super.key,
    required this.question,
    this.selectedAnswerIndex,
    required this.onAnswerSelected,
    this.isReviewMode = false,
    this.showCorrectAnswer = false,
    this.showAnswerFeedback = false,
    this.fontSize = 16.0,
    this.onShowSolution,
    this.onStarToggle,
    this.isStarredOverride,
  });

  Color _getOptionColor(int index) {
    if (!showCorrectAnswer && !isReviewMode && !showAnswerFeedback) {
      return selectedAnswerIndex == index 
          ? AppTheme.primaryNavyBlue.withValues(alpha: 0.1)
          : Colors.transparent;
    }

    // Review mode, showing correct answer, or showing feedback
    if (index == question.correctAnswerIndex) {
      return AppTheme.successGreen.withValues(alpha: 0.2);
    }
    
    if (selectedAnswerIndex == index && index != question.correctAnswerIndex) {
      return AppTheme.errorRed.withValues(alpha: 0.2);
    }
    
    return Colors.transparent;
  }

  Color _getOptionBorderColor(int index) {
    if (!showCorrectAnswer && !isReviewMode && !showAnswerFeedback) {
      return selectedAnswerIndex == index 
          ? AppTheme.primaryNavyBlue
          : Colors.grey[300]!;
    }

    // Review mode, showing correct answer, or showing feedback
    if (index == question.correctAnswerIndex) {
      return AppTheme.successGreen;
    }
    
    if (selectedAnswerIndex == index && index != question.correctAnswerIndex) {
      return AppTheme.errorRed;
    }
    
    return Colors.grey[300]!;
  }

  Widget _getOptionIcon(int index) {
    if (!showCorrectAnswer && !isReviewMode && !showAnswerFeedback) {
      return Icon(
        selectedAnswerIndex == index 
            ? Icons.radio_button_checked
            : Icons.radio_button_unchecked,
        color: selectedAnswerIndex == index 
            ? AppTheme.primaryNavyBlue
            : Colors.grey[400],
      );
    }

    // Review mode, showing correct answer, or showing feedback
    if (index == question.correctAnswerIndex) {
      return const Icon(
        Icons.check_circle,
        color: AppTheme.successGreen,
      );
    }
    
    if (selectedAnswerIndex == index && index != question.correctAnswerIndex) {
      return const Icon(
        Icons.cancel,
        color: AppTheme.errorRed,
      );
    }
    
    return Icon(
      Icons.radio_button_unchecked,
      color: Colors.grey[400],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question text with favorite icon
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    question.questionText,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),
                ),
                if (!isReviewMode) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      (isStarredOverride ?? question.isStarred) ? Icons.star : Icons.star_border,
                      color: (isStarredOverride ?? question.isStarred)
                          ? AppTheme.accentGold
                          : AppTheme.darkGrey,
                    ),
                    onPressed: onStarToggle,
                    tooltip: 'Favori',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                ],
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Answer options
            ...question.options.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: (isReviewMode || showAnswerFeedback) ? null : () => onAnswerSelected(index),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _getOptionColor(index),
                      border: Border.all(
                        color: _getOptionBorderColor(index),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        _getOptionIcon(index),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            option,
                            style: TextStyle(
                              fontSize: fontSize * 0.9,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            
            // Boş Bırak seçeneği
            if (!isReviewMode && !showAnswerFeedback) ...[
              const SizedBox(height: 8),
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () => onAnswerSelected(-1), // -1 boş bırakma için
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: selectedAnswerIndex == -1 
                          ? Colors.orange[100] 
                          : Colors.grey[50],
                      border: Border.all(
                        color: selectedAnswerIndex == -1 
                            ? Colors.orange[400]! 
                            : Colors.grey[300]!,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          selectedAnswerIndex == -1 
                              ? Icons.radio_button_checked 
                              : Icons.radio_button_unchecked,
                          color: selectedAnswerIndex == -1 
                              ? Colors.orange[600] 
                              : Colors.grey[500],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Boş Bırak',
                            style: TextStyle(
                              fontSize: fontSize * 0.9,
                              height: 1.4,
                              fontStyle: FontStyle.italic,
                              color: selectedAnswerIndex == -1 
                                  ? Colors.orange[700] 
                                  : Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            
            // Show Solution Button (only shown when answer feedback is active and callback is provided)
            if (showAnswerFeedback && onShowSolution != null) ...[
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton.icon(
                  onPressed: onShowSolution,
                  icon: const Icon(Icons.lightbulb_outline),
                  label: const Text('Çözümü Gör'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentGold,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
            
            // Explanation (only shown in review mode)
            if (showCorrectAnswer && question.explanation.isNotEmpty) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.lightGrey,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: AppTheme.accentGold,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Açıklama',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryNavyBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      question.explanation,
                      style: TextStyle(
                        fontSize: fontSize * 0.85,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}