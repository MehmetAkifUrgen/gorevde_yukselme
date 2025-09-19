import 'package:equatable/equatable.dart';
import 'user_model.dart';

enum QuestionDifficulty {
  easy,
  medium,
  hard,
}

enum QuestionCategory {
  electricalElectronics,
  construction,
  computerTechnology,
  machineTechnology,
  generalRegulations,
  programmingLanguages,
}

class Question extends Equatable {
  final String id;
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;
  final QuestionDifficulty difficulty;
  final QuestionCategory category;
  final List<UserProfession> targetProfessions;
  final bool isStarred;

  const Question({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
    required this.difficulty,
    required this.category,
    required this.targetProfessions,
    this.isStarred = false,
  });

  Question copyWith({
    String? id,
    String? questionText,
    List<String>? options,
    int? correctAnswerIndex,
    String? explanation,
    QuestionDifficulty? difficulty,
    QuestionCategory? category,
    List<UserProfession>? targetProfessions,
    bool? isStarred,
  }) {
    return Question(
      id: id ?? this.id,
      questionText: questionText ?? this.questionText,
      options: options ?? this.options,
      correctAnswerIndex: correctAnswerIndex ?? this.correctAnswerIndex,
      explanation: explanation ?? this.explanation,
      difficulty: difficulty ?? this.difficulty,
      category: category ?? this.category,
      targetProfessions: targetProfessions ?? this.targetProfessions,
      isStarred: isStarred ?? this.isStarred,
    );
  }

  bool isCorrectAnswer(int selectedIndex) {
    return selectedIndex == correctAnswerIndex;
  }

  @override
  List<Object?> get props => [
        id,
        questionText,
        options,
        correctAnswerIndex,
        explanation,
        difficulty,
        category,
        targetProfessions,
        isStarred,
      ];
}

extension QuestionDifficultyExtension on QuestionDifficulty {
  String get displayName {
    switch (this) {
      case QuestionDifficulty.easy:
        return 'Kolay';
      case QuestionDifficulty.medium:
        return 'Orta';
      case QuestionDifficulty.hard:
        return 'Zor';
    }
  }
}

extension QuestionCategoryExtension on QuestionCategory {
  String get displayName {
    switch (this) {
      case QuestionCategory.electricalElectronics:
        return 'Elektrik-Elektronik';
      case QuestionCategory.construction:
        return 'İnşaat';
      case QuestionCategory.computerTechnology:
        return 'Bilgisayar Teknolojisi';
      case QuestionCategory.machineTechnology:
        return 'Makine Teknolojisi';
      case QuestionCategory.generalRegulations:
        return 'Genel Mevzuat';
      case QuestionCategory.programmingLanguages:
        return 'Programlama Dilleri';
    }
  }
}