import 'package:equatable/equatable.dart';

class UserPreferences extends Equatable {
  final double fontSize;
  final bool notificationsEnabled;
  final bool darkModeEnabled;
  final bool soundEnabled;

  const UserPreferences({
    this.fontSize = 16.0,
    this.notificationsEnabled = true,
    this.darkModeEnabled = false,
    this.soundEnabled = true,
  });

  UserPreferences copyWith({
    double? fontSize,
    bool? notificationsEnabled,
    bool? darkModeEnabled,
    bool? soundEnabled,
  }) {
    return UserPreferences(
      fontSize: fontSize ?? this.fontSize,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fontSize': fontSize,
      'notificationsEnabled': notificationsEnabled,
      'darkModeEnabled': darkModeEnabled,
      'soundEnabled': soundEnabled,
    };
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 16.0,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      darkModeEnabled: json['darkModeEnabled'] as bool? ?? false,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [
        fontSize,
        notificationsEnabled,
        darkModeEnabled,
        soundEnabled,
      ];
}