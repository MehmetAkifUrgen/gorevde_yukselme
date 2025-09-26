import 'package:equatable/equatable.dart';
import 'question_model.dart';
import 'user_model.dart';

enum ExamType {
  fullExam,
  miniExam,
  practiceMode,
}

enum ExamStatus {
  notStarted,
  inProgress,
  completed,
}

class Exam extends Equatable {
  final String id;
  final String title;
  final ExamType type;
  final UserProfession targetProfession;
  final List<Question> questions;
  final int durationInMinutes;
  final ExamStatus status;
  final DateTime? startTime;
  final DateTime? endTime;
  final Map<String, int> userAnswers; // questionId -> selectedAnswerIndex
  final int currentQuestionIndex;

  const Exam({
    required this.id,
    required this.title,
    required this.type,
    required this.targetProfession,
    required this.questions,
    required this.durationInMinutes,
    this.status = ExamStatus.notStarted,
    this.startTime,
    this.endTime,
    this.userAnswers = const {},
    this.currentQuestionIndex = 0,
  });

  Exam copyWith({
    String? id,
    String? title,
    ExamType? type,
    UserProfession? targetProfession,
    List<Question>? questions,
    int? durationInMinutes,
    ExamStatus? status,
    DateTime? startTime,
    DateTime? endTime,
    Map<String, int>? userAnswers,
    int? currentQuestionIndex,
  }) {
    return Exam(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      targetProfession: targetProfession ?? this.targetProfession,
      questions: questions ?? this.questions,
      durationInMinutes: durationInMinutes ?? this.durationInMinutes,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      userAnswers: userAnswers ?? this.userAnswers,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
    );
  }

  int get totalQuestions => questions.length;
  
  int get answeredQuestions => userAnswers.length;
  
  double get progressPercentage => 
      totalQuestions > 0 ? (answeredQuestions / totalQuestions) * 100 : 0;

  int get correctAnswers {
    int correct = 0;
    for (final entry in userAnswers.entries) {
      final question = questions.firstWhere((q) => q.id == entry.key);
      if (entry.value != -1 && question.isCorrectAnswer(entry.value)) {
        correct++;
      }
    }
    return correct;
  }

  int get incorrectAnswers {
    int incorrect = 0;
    for (final entry in userAnswers.entries) {
      final question = questions.firstWhere((q) => q.id == entry.key);
      // Sadece -1 olmayan (boş bırakılmayan) ve yanlış cevapları say
      if (entry.value != -1 && !question.isCorrectAnswer(entry.value)) {
        incorrect++;
      }
    }
    return incorrect;
  }

  int get blankAnswers {
    int blank = 0;
    for (final entry in userAnswers.entries) {
      if (entry.value == -1) {
        blank++;
      }
    }
    // Hiç cevaplanmayan soruları da ekle
    return blank + (totalQuestions - userAnswers.length);
  }

  double get scorePercentage => 
      totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0;

  Duration? get remainingTime {
    if (startTime == null || status != ExamStatus.inProgress) return null;
    final elapsed = DateTime.now().difference(startTime!);
    final total = Duration(minutes: durationInMinutes);
    final remaining = total - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  bool get isTimeUp {
    final remaining = remainingTime;
    return remaining != null && remaining.inSeconds <= 0;
  }

  @override
  List<Object?> get props => [
        id,
        title,
        type,
        targetProfession,
        questions,
        durationInMinutes,
        status,
        startTime,
        endTime,
        userAnswers,
        currentQuestionIndex,
      ];
}

class ExamResult extends Equatable {
  final String examId;
  final String userId;
  final DateTime completedAt;
  final int totalQuestions;
  final int correctAnswers;
  final int incorrectAnswers;
  final int blankAnswers;
  final double scorePercentage;
  final Duration timeTaken;
  final Map<QuestionCategory, int> categoryPerformance; // category -> correct answers
  final List<String> incorrectQuestionIds;

  const ExamResult({
    required this.examId,
    required this.userId,
    required this.completedAt,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.blankAnswers,
    required this.scorePercentage,
    required this.timeTaken,
    required this.categoryPerformance,
    required this.incorrectQuestionIds,
  });

  @override
  List<Object?> get props => [
        examId,
        userId,
        completedAt,
        totalQuestions,
        correctAnswers,
        incorrectAnswers,
        blankAnswers,
        scorePercentage,
        timeTaken,
        categoryPerformance,
        incorrectQuestionIds,
      ];
}

extension ExamTypeExtension on ExamType {
  String get displayName {
    switch (this) {
      case ExamType.fullExam:
        return 'Tam Sınav';
      case ExamType.miniExam:
        return 'Mini Sınav';
      case ExamType.practiceMode:
        return 'Pratik Modu';
    }
  }

  int get defaultDuration {
    switch (this) {
      case ExamType.fullExam:
        return 120; // 2 hours
      case ExamType.miniExam:
        return 30; // 30 minutes
      case ExamType.practiceMode:
        return 0; // No time limit
    }
  }

  /// Calculate duration based on question count: question count + 3 minutes
  int calculateDuration(int questionCount) {
    if (this == ExamType.practiceMode) {
      return 0; // No time limit for practice mode
    }
    return questionCount + 3; // question count + 3 minutes
  }

  int get defaultQuestionCount {
    switch (this) {
      case ExamType.fullExam:
        return 100;
      case ExamType.miniExam:
        return 30;
      case ExamType.practiceMode:
        return 20;
    }
  }
}