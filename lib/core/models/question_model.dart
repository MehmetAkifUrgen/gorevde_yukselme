import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
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
  final String? subject;
  final String? ministry;

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
    this.subject,
    this.ministry,
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
    String? subject,
    String? ministry,
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
      subject: subject ?? this.subject,
      ministry: ministry ?? this.ministry,
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
        subject,
        ministry,
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

  Color get color {
    switch (this) {
      case QuestionDifficulty.easy:
        return const Color(0xFF4CAF50); // Green
      case QuestionDifficulty.medium:
        return const Color(0xFFFF9800); // Orange
      case QuestionDifficulty.hard:
        return const Color(0xFFF44336); // Red
    }
  }
}

extension QuestionCategoryExtension on QuestionCategory {
  // Remove static displayName - will be replaced with dynamic API-based service
  // Temporary static displayName for migration
  String get displayName {
    switch (this) {
      case QuestionCategory.electricalElectronics:
        return 'Elektrik Elektronik';
      case QuestionCategory.construction:
        return 'İnşaat';
      case QuestionCategory.computerTechnology:
        return 'Bilgisayar Teknolojisi';
      case QuestionCategory.machineTechnology:
        return 'Makine Teknolojisi';
      case QuestionCategory.generalRegulations:
        return 'Genel Yönetmelikler';
      case QuestionCategory.programmingLanguages:
        return 'Programlama Dilleri';
    }
  }
  
  Color get color {
    switch (this) {
      case QuestionCategory.electricalElectronics:
        return const Color(0xFF2196F3);
      case QuestionCategory.construction:
        return const Color(0xFF4CAF50);
      case QuestionCategory.computerTechnology:
        return const Color(0xFF9C27B0);
      case QuestionCategory.machineTechnology:
        return const Color(0xFFFF9800);
      case QuestionCategory.generalRegulations:
        return const Color(0xFFF44336);
      case QuestionCategory.programmingLanguages:
        return const Color(0xFF607D8B);
    }
  }
}