import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/question_model.dart';

class QuestionCard extends StatefulWidget {
  final Question question;
  final double fontSize;
  final Function(int) onAnswered;
  final VoidCallback onStarToggle;

  const QuestionCard({
    super.key,
    required this.question,
    required this.fontSize,
    required this.onAnswered,
    required this.onStarToggle,
  });

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  int? selectedAnswer;
  bool showExplanation = false;

  @override
  void didUpdateWidget(QuestionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset state when question changes
    if (oldWidget.question.id != widget.question.id) {
      setState(() {
        selectedAnswer = null;
        showExplanation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question Text with Favorite Icon
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    widget.question.questionText,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: widget.fontSize,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    widget.question.isStarred ? Icons.star : Icons.star_border,
                    color: widget.question.isStarred ? AppTheme.accentGold : AppTheme.darkGrey,
                  ),
                  onPressed: widget.onStarToggle,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Answer Options
            ...widget.question.options.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              final isSelected = selectedAnswer == index;
              final isCorrect = index == widget.question.correctAnswerIndex;
              final showResult = selectedAnswer != null;
              
              Color? backgroundColor;
              Color? borderColor;
              Color? textColor;
              
              if (showResult) {
                if (isCorrect) {
                  backgroundColor = AppTheme.successGreen.withValues(alpha: 0.1);
                  borderColor = AppTheme.successGreen;
                  textColor = AppTheme.successGreen;
                } else if (isSelected) {
                  backgroundColor = AppTheme.errorRed.withValues(alpha: 0.1);
                  borderColor = AppTheme.errorRed;
                  textColor = AppTheme.errorRed;
                }
              } else if (isSelected) {
                backgroundColor = AppTheme.primaryNavyBlue.withValues(alpha: 0.1);
                borderColor = AppTheme.primaryNavyBlue;
                textColor = AppTheme.primaryNavyBlue;
              }
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: selectedAnswer == null ? () {
                    setState(() {
                      selectedAnswer = index;
                      showExplanation = true;
                    });
                    widget.onAnswered(index);
                  } : null,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: backgroundColor ?? AppTheme.lightGrey,
                      border: Border.all(
                        color: borderColor ?? AppTheme.darkGrey.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: textColor?.withValues(alpha: 0.2) ?? AppTheme.darkGrey.withValues(alpha: 0.1),
                            border: Border.all(
                              color: textColor ?? AppTheme.darkGrey.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              String.fromCharCode(65 + index), // A, B, C, D
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: textColor ?? AppTheme.darkGrey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            option,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: widget.fontSize * 0.9,
                              color: textColor ?? AppTheme.darkGrey,
                              fontWeight: showResult && isCorrect ? FontWeight.w600 : null,
                            ),
                          ),
                        ),
                        if (showResult && isCorrect)
                          Icon(
                            Icons.check_circle,
                            color: AppTheme.successGreen,
                            size: 20,
                          ),
                        if (showResult && isSelected && !isCorrect)
                          Icon(
                            Icons.cancel,
                            color: AppTheme.errorRed,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            
            // Explanation
            if (showExplanation && widget.question.explanation.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryNavyBlue.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.primaryNavyBlue.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: AppTheme.primaryNavyBlue,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Açıklama',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppTheme.primaryNavyBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.question.explanation,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: widget.fontSize * 0.9,
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