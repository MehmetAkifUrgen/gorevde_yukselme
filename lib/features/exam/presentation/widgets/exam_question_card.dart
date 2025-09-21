import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/question_model.dart';
import '../../../../core/widgets/category_display_widget.dart';

class ExamQuestionCard extends StatelessWidget {
  final Question question;
  final int? selectedAnswerIndex;
  final Function(int) onAnswerSelected;
  final bool isReviewMode;
  final bool showCorrectAnswer;
  final double fontSize;

  const ExamQuestionCard({
    super.key,
    required this.question,
    this.selectedAnswerIndex,
    required this.onAnswerSelected,
    this.isReviewMode = false,
    this.showCorrectAnswer = false,
    this.fontSize = 16.0,
  });

  Color _getOptionColor(int index) {
    if (!showCorrectAnswer && !isReviewMode) {
      return selectedAnswerIndex == index 
          ? AppTheme.primaryNavyBlue.withValues(alpha: 0.1)
          : Colors.transparent;
    }

    // Review mode or showing correct answer
    if (index == question.correctAnswerIndex) {
      return AppTheme.successGreen.withValues(alpha: 0.2);
    }
    
    if (selectedAnswerIndex == index && index != question.correctAnswerIndex) {
      return AppTheme.errorRed.withValues(alpha: 0.2);
    }
    
    return Colors.transparent;
  }

  Color _getOptionBorderColor(int index) {
    if (!showCorrectAnswer && !isReviewMode) {
      return selectedAnswerIndex == index 
          ? AppTheme.primaryNavyBlue
          : Colors.grey[300]!;
    }

    // Review mode or showing correct answer
    if (index == question.correctAnswerIndex) {
      return AppTheme.successGreen;
    }
    
    if (selectedAnswerIndex == index && index != question.correctAnswerIndex) {
      return AppTheme.errorRed;
    }
    
    return Colors.grey[300]!;
  }

  Widget _getOptionIcon(int index) {
    if (!showCorrectAnswer && !isReviewMode) {
      return Icon(
        selectedAnswerIndex == index 
            ? Icons.radio_button_checked
            : Icons.radio_button_unchecked,
        color: selectedAnswerIndex == index 
            ? AppTheme.primaryNavyBlue
            : Colors.grey[400],
      );
    }

    // Review mode or showing correct answer
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
            // Question difficulty and category
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: question.difficulty.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    question.difficulty.displayName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: question.difficulty.color,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CategoryDisplayText(
                    category: question.category,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Question text
            Text(
              question.questionText,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Answer options
            ...question.options.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: isReviewMode ? null : () => onAnswerSelected(index),
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