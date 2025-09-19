import 'package:equatable/equatable.dart';

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
    );
  }

  bool get isPremium => subscriptionStatus == SubscriptionStatus.premium;
  
  bool get hasValidSubscription {
    if (!isPremium) return false;
    if (subscriptionExpiryDate == null) return false;
    return subscriptionExpiryDate!.isAfter(DateTime.now());
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
      ];
}

extension UserProfessionExtension on UserProfession {
  String get displayName {
    switch (this) {
      case UserProfession.electricalElectronicEngineer:
        return 'Elektrik-Elektronik Mühendisi';
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