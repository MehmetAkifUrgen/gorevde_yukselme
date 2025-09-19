import 'package:equatable/equatable.dart';
import 'question_model.dart';

class PerformanceData extends Equatable {
  final String userId;
  final int totalQuestionsAnswered;
  final int totalCorrectAnswers;
  final int totalIncorrectAnswers;
  final double overallAccuracy;
  final Map<QuestionCategory, CategoryPerformance> categoryPerformance;
  final List<String> weakAreas;
  final List<String> strongAreas;
  final DateTime lastUpdated;

  const PerformanceData({
    required this.userId,
    required this.totalQuestionsAnswered,
    required this.totalCorrectAnswers,
    required this.totalIncorrectAnswers,
    required this.overallAccuracy,
    required this.categoryPerformance,
    required this.weakAreas,
    required this.strongAreas,
    required this.lastUpdated,
  });

  PerformanceData copyWith({
    String? userId,
    int? totalQuestionsAnswered,
    int? totalCorrectAnswers,
    int? totalIncorrectAnswers,
    double? overallAccuracy,
    Map<QuestionCategory, CategoryPerformance>? categoryPerformance,
    List<String>? weakAreas,
    List<String>? strongAreas,
    DateTime? lastUpdated,
  }) {
    return PerformanceData(
      userId: userId ?? this.userId,
      totalQuestionsAnswered: totalQuestionsAnswered ?? this.totalQuestionsAnswered,
      totalCorrectAnswers: totalCorrectAnswers ?? this.totalCorrectAnswers,
      totalIncorrectAnswers: totalIncorrectAnswers ?? this.totalIncorrectAnswers,
      overallAccuracy: overallAccuracy ?? this.overallAccuracy,
      categoryPerformance: categoryPerformance ?? this.categoryPerformance,
      weakAreas: weakAreas ?? this.weakAreas,
      strongAreas: strongAreas ?? this.strongAreas,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        totalQuestionsAnswered,
        totalCorrectAnswers,
        totalIncorrectAnswers,
        overallAccuracy,
        categoryPerformance,
        weakAreas,
        strongAreas,
        lastUpdated,
      ];
}

class CategoryPerformance extends Equatable {
  final QuestionCategory category;
  final int questionsAnswered;
  final int correctAnswers;
  final int incorrectAnswers;
  final double accuracy;
  final List<QuestionDifficulty> weakDifficulties;

  const CategoryPerformance({
    required this.category,
    required this.questionsAnswered,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.accuracy,
    required this.weakDifficulties,
  });

  CategoryPerformance copyWith({
    QuestionCategory? category,
    int? questionsAnswered,
    int? correctAnswers,
    int? incorrectAnswers,
    double? accuracy,
    List<QuestionDifficulty>? weakDifficulties,
  }) {
    return CategoryPerformance(
      category: category ?? this.category,
      questionsAnswered: questionsAnswered ?? this.questionsAnswered,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      incorrectAnswers: incorrectAnswers ?? this.incorrectAnswers,
      accuracy: accuracy ?? this.accuracy,
      weakDifficulties: weakDifficulties ?? this.weakDifficulties,
    );
  }

  bool get needsImprovement => accuracy < 70.0;
  
  String get performanceLevel {
    if (accuracy >= 90) return 'Mükemmel';
    if (accuracy >= 80) return 'İyi';
    if (accuracy >= 70) return 'Orta';
    if (accuracy >= 60) return 'Geliştirilmeli';
    return 'Zayıf';
  }

  @override
  List<Object?> get props => [
        category,
        questionsAnswered,
        correctAnswers,
        incorrectAnswers,
        accuracy,
        weakDifficulties,
      ];
}

class StudyRecommendation extends Equatable {
  final String title;
  final String description;
  final QuestionCategory? targetCategory;
  final QuestionDifficulty? targetDifficulty;
  final int priority; // 1-5, 5 being highest priority

  const StudyRecommendation({
    required this.title,
    required this.description,
    this.targetCategory,
    this.targetDifficulty,
    required this.priority,
  });

  @override
  List<Object?> get props => [
        title,
        description,
        targetCategory,
        targetDifficulty,
        priority,
      ];
}

class DailyProgress extends Equatable {
  final DateTime date;
  final int questionsAnswered;
  final int correctAnswers;
  final double accuracy;
  final Duration studyTime;

  const DailyProgress({
    required this.date,
    required this.questionsAnswered,
    required this.correctAnswers,
    required this.accuracy,
    required this.studyTime,
  });

  @override
  List<Object?> get props => [
        date,
        questionsAnswered,
        correctAnswers,
        accuracy,
        studyTime,
      ];
}