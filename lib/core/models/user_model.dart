import 'package:equatable/equatable.dart';
import 'user_preferences.dart';
import 'user_statistics.dart';

enum UserProfession {
  electricalElectronicEngineer,
  constructionEngineer,
  computerTechnician,
  machineTechnician,
  generalRegulations,
}

enum SubscriptionStatus {
  free,
  premium,
}

// Adding SubscriptionType enum for compatibility
enum SubscriptionType {
  free,
  premium,
}

class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final UserProfession profession;
  final SubscriptionStatus subscriptionStatus;
  final DateTime? subscriptionExpiryDate;
  final bool notificationsEnabled;
  final int questionsAnsweredToday;
  final List<String> weakAreas;
  final UserPreferences preferences;
  final UserStatistics statistics;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool isEmailVerified;
  final String? profileImageUrl;
  final int target;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.profession,
    this.subscriptionStatus = SubscriptionStatus.free,
    this.subscriptionExpiryDate,
    this.notificationsEnabled = true,
    this.questionsAnsweredToday = 0,
    this.weakAreas = const [],
    this.preferences = const UserPreferences(),
    this.statistics = const UserStatistics(),
    required this.createdAt,
    this.lastLoginAt,
    this.isEmailVerified = false,
    this.profileImageUrl,
    this.target = 50,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    UserProfession? profession,
    SubscriptionStatus? subscriptionStatus,
    DateTime? subscriptionExpiryDate,
    bool? notificationsEnabled,
    int? questionsAnsweredToday,
    List<String>? weakAreas,
    UserPreferences? preferences,
    UserStatistics? statistics,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isEmailVerified,
    String? profileImageUrl,
    int? target,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profession: profession ?? this.profession,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      subscriptionExpiryDate: subscriptionExpiryDate ?? this.subscriptionExpiryDate,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      questionsAnsweredToday: questionsAnsweredToday ?? this.questionsAnsweredToday,
      weakAreas: weakAreas ?? this.weakAreas,
      preferences: preferences ?? this.preferences,
      statistics: statistics ?? this.statistics,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      target: target ?? this.target,
    );
  }

  bool get isPremium => subscriptionStatus == SubscriptionStatus.premium;
  
  bool get hasValidSubscription {
    if (!isPremium) return false;
    if (subscriptionExpiryDate == null) return false;
    return subscriptionExpiryDate!.isAfter(DateTime.now());
  }

  // Compatibility getter for subscriptionType
  SubscriptionType get subscriptionType {
    return subscriptionStatus == SubscriptionStatus.premium 
        ? SubscriptionType.premium 
        : SubscriptionType.free;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        profession,
        subscriptionStatus,
        subscriptionExpiryDate,
        notificationsEnabled,
        questionsAnsweredToday,
        weakAreas,
        preferences,
        statistics,
        createdAt,
        lastLoginAt,
        isEmailVerified,
        profileImageUrl,
        target,
      ];
}

extension UserProfessionExtension on UserProfession {
  String get displayName {
    switch (this) {
      case UserProfession.electricalElectronicEngineer:
        return '-Elektronik Mühendisi';
      case UserProfession.constructionEngineer:
        return 'İnşaat Mühendisi';
      case UserProfession.computerTechnician:
        return 'Bilgisayar Teknisyeni';
      case UserProfession.machineTechnician:
        return 'Makine Teknisyeni';
      case UserProfession.generalRegulations:
        return 'Genel Mevzuat';
    }
  }
}

extension SubscriptionTypeExtension on SubscriptionType {
  String get displayName {
    switch (this) {
      case SubscriptionType.free:
        return 'Ücretsiz';
      case SubscriptionType.premium:
        return 'Premium';
    }
  }
}