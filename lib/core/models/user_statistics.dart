import 'package:equatable/equatable.dart';

class UserStatistics extends Equatable {
  final int totalQuestionsAnswered;
  final int correctAnswers;
  final int totalExamsTaken;
  final double averageScore;
  final int totalStudyTimeMinutes;
  final int currentStreak;
  final int longestStreak;

  const UserStatistics({
    this.totalQuestionsAnswered = 0,
    this.correctAnswers = 0,
    this.totalExamsTaken = 0,
    this.averageScore = 0.0,
    this.totalStudyTimeMinutes = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
  });

  UserStatistics copyWith({
    int? totalQuestionsAnswered,
    int? correctAnswers,
    int? totalExamsTaken,
    double? averageScore,
    int? totalStudyTimeMinutes,
    int? currentStreak,
    int? longestStreak,
  }) {
    return UserStatistics(
      totalQuestionsAnswered: totalQuestionsAnswered ?? this.totalQuestionsAnswered,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      totalExamsTaken: totalExamsTaken ?? this.totalExamsTaken,
      averageScore: averageScore ?? this.averageScore,
      totalStudyTimeMinutes: totalStudyTimeMinutes ?? this.totalStudyTimeMinutes,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
    );
  }

  double get accuracy {
    if (totalQuestionsAnswered == 0) return 0.0;
    return (correctAnswers / totalQuestionsAnswered) * 100;
  }

  int get incorrectAnswers => totalQuestionsAnswered - correctAnswers;

  String get formattedStudyTime {
    final hours = totalStudyTimeMinutes ~/ 60;
    final minutes = totalStudyTimeMinutes % 60;
    return '${hours}s ${minutes}dk';
  }

  Map<String, dynamic> toJson() {
    return {
      'totalQuestionsAnswered': totalQuestionsAnswered,
      'correctAnswers': correctAnswers,
      'totalExamsTaken': totalExamsTaken,
      'averageScore': averageScore,
      'totalStudyTimeMinutes': totalStudyTimeMinutes,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
    };
  }

  factory UserStatistics.fromJson(Map<String, dynamic> json) {
    return UserStatistics(
      totalQuestionsAnswered: json['totalQuestionsAnswered'] as int? ?? 0,
      correctAnswers: json['correctAnswers'] as int? ?? 0,
      totalExamsTaken: json['totalExamsTaken'] as int? ?? 0,
      averageScore: (json['averageScore'] as num?)?.toDouble() ?? 0.0,
      totalStudyTimeMinutes: json['totalStudyTimeMinutes'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [
        totalQuestionsAnswered,
        correctAnswers,
        totalExamsTaken,
        averageScore,
        totalStudyTimeMinutes,
        currentStreak,
        longestStreak,
      ];
}