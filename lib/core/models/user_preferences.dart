import 'package:equatable/equatable.dart';

class UserPreferences extends Equatable {
  final double fontSize;
  final bool notificationsEnabled;
  final bool darkModeEnabled;
  final bool soundEnabled;
  final String language;

  const UserPreferences({
    this.fontSize = 16.0,
    this.notificationsEnabled = true,
    this.darkModeEnabled = false,
    this.soundEnabled = true,
    this.language = 'tr',
  });

  UserPreferences copyWith({
    double? fontSize,
    bool? notificationsEnabled,
    bool? darkModeEnabled,
    bool? soundEnabled,
    String? language,
  }) {
    return UserPreferences(
      fontSize: fontSize ?? this.fontSize,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      language: language ?? this.language,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fontSize': fontSize,
      'notificationsEnabled': notificationsEnabled,
      'darkModeEnabled': darkModeEnabled,
      'soundEnabled': soundEnabled,
      'language': language,
    };
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 16.0,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      darkModeEnabled: json['darkModeEnabled'] as bool? ?? false,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      language: json['language'] as String? ?? 'tr',
    );
  }

  @override
  List<Object?> get props => [
        fontSize,
        notificationsEnabled,
        darkModeEnabled,
        soundEnabled,
        language,
      ];
}