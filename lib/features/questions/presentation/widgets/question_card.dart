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

  (String subject, String profession) _extractSubjectAndProfession() {
    // ID format: category_profession_subject_questionNo
    final parts = widget.question.id.split('_');
    if (parts.length < 4) return ('', '');
    final subject = parts[parts.length - 2];
    final profession = parts[parts.length - 3];
    return (subject, profession);
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
            // Question Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.question.difficulty.displayName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _getDifficultyColor(),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ...() {
                  final (subject, profession) = _extractSubjectAndProfession();
                  return [
                    if (subject.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryNavyBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          subject,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.primaryNavyBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    if (profession.isNotEmpty) const SizedBox(width: 8),
                    if (profession.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.mediumGrey.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          profession,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.darkGrey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ];
                }(),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    widget.question.isStarred ? Icons.star : Icons.star_border,
                    color: widget.question.isStarred ? AppTheme.accentGold : AppTheme.darkGrey,
                  ),
                  onPressed: widget.onStarToggle,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Question Text
            Text(
              widget.question.questionText,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: widget.fontSize,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
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

  Color _getDifficultyColor() {
    switch (widget.question.difficulty) {
      case QuestionDifficulty.easy:
        return AppTheme.successGreen;
      case QuestionDifficulty.medium:
        return AppTheme.warningYellow;
      case QuestionDifficulty.hard:
        return AppTheme.errorRed;
    }
  }
}