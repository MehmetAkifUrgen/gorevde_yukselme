import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/question_model.dart';
import '../models/exam_model.dart';
import '../models/subscription_model.dart';
import '../services/subscription_service.dart';
import '../services/question_report_service.dart';
import '../models/performance_model.dart';

// User State Provider
final userProvider = StateNotifierProvider<UserNotifier, User?>((ref) {
  return UserNotifier();
});

class UserNotifier extends StateNotifier<User?> {
  UserNotifier() : super(null);

  void setUser(User user) {
    state = user;
  }

  void updateUser(User user) {
    state = user;
  }

  void clearUser() {
    state = null;
  }

  void toggleNotifications() {
    if (state != null) {
      state = state!.copyWith(
        notificationsEnabled: !state!.notificationsEnabled,
      );
    }
  }

  void incrementQuestionsAnswered() {
    if (state != null) {
      state = state!.copyWith(
        questionsAnsweredToday: state!.questionsAnsweredToday + 1,
      );
    }
  }
}

// Legacy Questions State Provider (kept for backward compatibility)
// Note: Consider migrating to questionsStateProvider from questions_providers.dart
final questionsProvider = StateNotifierProvider<QuestionsNotifier, List<Question>>((ref) {
  return QuestionsNotifier();
});

class QuestionsNotifier extends StateNotifier<List<Question>> {
  QuestionsNotifier() : super([]);

  void setQuestions(List<Question> questions) {
    state = questions;
  }

  void toggleStarQuestion(String questionId) {
    state = state.map((question) {
      if (question.id == questionId) {
        return question.copyWith(isStarred: !question.isStarred);
      }
      return question;
    }).toList();
  }

  List<Question> getQuestionsByCategory(QuestionCategory category) {
    return state.where((question) => question.category == category).toList();
  }

  List<Question> getStarredQuestions() {
    return state.where((question) => question.isStarred).toList();
  }

  List<Question> getRandomQuestions(UserProfession profession, int count) {
    final filteredQuestions = state.where((question) => 
      question.targetProfessions.contains(profession)
    ).toList();
    
    filteredQuestions.shuffle();
    return filteredQuestions.take(count).toList();
  }

  void shuffleQuestions() {
    final shuffledQuestions = List<Question>.from(state);
    shuffledQuestions.shuffle();
    state = shuffledQuestions;
  }

  void updateQuestionStats(String questionId, bool isCorrect) {
    // This would typically update question statistics in a database
    // For now, we'll just keep it as a placeholder
    // In a real app, this would track answer history, success rates, etc.
  }

  void toggleQuestionStar(String questionId) {
    state = state.map((question) {
      if (question.id == questionId) {
        return question.copyWith(isStarred: !question.isStarred);
      }
      return question;
    }).toList();
  }
}

// Current Exam State Provider
final currentExamProvider = StateNotifierProvider<CurrentExamNotifier, Exam?>((ref) {
  return CurrentExamNotifier();
});

class CurrentExamNotifier extends StateNotifier<Exam?> {
  CurrentExamNotifier() : super(null);

  void startExam(Exam exam) {
    state = exam.copyWith(
      status: ExamStatus.inProgress,
      startTime: DateTime.now(),
    );
  }

  void answerQuestion(String questionId, int selectedAnswerIndex) {
    if (state != null) {
      final updatedAnswers = Map<String, int>.from(state!.userAnswers);
      updatedAnswers[questionId] = selectedAnswerIndex;
      
      state = state!.copyWith(userAnswers: updatedAnswers);
    }
  }

  void nextQuestion() {
    if (state != null && state!.currentQuestionIndex < state!.totalQuestions - 1) {
      state = state!.copyWith(
        currentQuestionIndex: state!.currentQuestionIndex + 1,
      );
    }
  }

  void previousQuestion() {
    if (state != null && state!.currentQuestionIndex > 0) {
      state = state!.copyWith(
        currentQuestionIndex: state!.currentQuestionIndex - 1,
      );
    }
  }

  void completeExam() {
    if (state != null) {
      state = state!.copyWith(
        status: ExamStatus.completed,
        endTime: DateTime.now(),
      );
    }
  }

  void clearExam() {
    state = null;
  }
}

// Performance Data Provider
final performanceProvider = StateNotifierProvider<PerformanceNotifier, PerformanceData?>((ref) {
  return PerformanceNotifier();
});

class PerformanceNotifier extends StateNotifier<PerformanceData?> {
  PerformanceNotifier() : super(null);

  void setPerformanceData(PerformanceData data) {
    state = data;
  }

  void updatePerformance(ExamResult result) {
    if (state != null) {
      // Update performance based on exam result
      final newTotalQuestions = state!.totalQuestionsAnswered + result.totalQuestions;
      final newCorrectAnswers = state!.totalCorrectAnswers + result.correctAnswers;
      final newIncorrectAnswers = state!.totalIncorrectAnswers + result.incorrectAnswers;
      final newAccuracy = (newCorrectAnswers / newTotalQuestions) * 100;

      state = state!.copyWith(
        totalQuestionsAnswered: newTotalQuestions,
        totalCorrectAnswers: newCorrectAnswers,
        totalIncorrectAnswers: newIncorrectAnswers,
        overallAccuracy: newAccuracy,
        lastUpdated: DateTime.now(),
      );
    }
  }
}

// Font Size Provider for accessibility
final fontSizeProvider = StateProvider<double>((ref) => 16.0);

// Selected Category Filter Provider
final selectedCategoryProvider = StateProvider<QuestionCategory?>((ref) => null);

// Ad Counter Provider (for non-premium users)
final adCounterProvider = StateProvider<int>((ref) => 0);

// Motivational Message Provider
final motivationalMessageProvider = StateProvider<String>((ref) {
  final messages = [
    'Bugün de harika gidiyorsun! Devam et!',
    'Her soru seni hedefe bir adım daha yaklaştırıyor.',
    'Başarı, hazırlık ve fırsatın buluştuğu yerdir.',
    'Çalışmaya devam et, hedefin çok yakın!',
    'Her gün biraz daha ilerle, büyük başarılar seni bekliyor.',
  ];
  
  // Günlük bazlı random seçim
  final now = DateTime.now();
  final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
  final messageIndex = dayOfYear % messages.length;
  
  return messages[messageIndex];
});

// Navigation Index Provider for Bottom Navigation
final navigationIndexProvider = StateProvider<int>((ref) => 0);

// Subscription Service Provider
final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  return SubscriptionService();
});

// Subscription State Provider
final subscriptionProvider = StateNotifierProvider<SubscriptionNotifier, SubscriptionModel?>((ref) {
  final service = ref.watch(subscriptionServiceProvider);
  return SubscriptionNotifier(service);
});

class SubscriptionNotifier extends StateNotifier<SubscriptionModel?> {
  final SubscriptionService _subscriptionService;

  SubscriptionNotifier(this._subscriptionService) : super(null) {
    _init();
  }

  Future<void> _init() async {
    await _subscriptionService.initialize();
    
    // Listen to subscription changes
    _subscriptionService.subscriptionStream.listen((subscription) {
      state = subscription;
    });
  }

  Future<void> purchaseSubscription(String productId) async {
    await _subscriptionService.purchaseSubscription(productId);
  }

  Future<void> restorePurchases() async {
    await _subscriptionService.restorePurchases();
  }

  bool get hasActiveSubscription => _subscriptionService.hasActiveSubscription;
  
  bool hasPremiumFeature(PremiumFeature feature) {
    return _subscriptionService.hasPremiumFeature(feature);
  }

  SubscriptionModel? get currentSubscription => _subscriptionService.currentSubscription;
}

// Available Products Provider
final availableProductsProvider = StateNotifierProvider<ProductsNotifier, List<ProductModel>>((ref) {
  final service = ref.watch(subscriptionServiceProvider);
  return ProductsNotifier(service);
});

class ProductsNotifier extends StateNotifier<List<ProductModel>> {
  final SubscriptionService _subscriptionService;

  ProductsNotifier(this._subscriptionService) : super([]) {
    _init();
  }

  Future<void> _init() async {
    await _subscriptionService.initialize();
    
    // Listen to products changes
    _subscriptionService.productsStream.listen((products) {
      state = products;
    });
  }

  List<ProductModel> get products => _subscriptionService.availableProducts;
}

// Purchase Result Provider
final purchaseResultProvider = StateNotifierProvider<PurchaseResultNotifier, PurchaseResult?>((ref) {
  final service = ref.watch(subscriptionServiceProvider);
  return PurchaseResultNotifier(service);
});

class PurchaseResultNotifier extends StateNotifier<PurchaseResult?> {
  final SubscriptionService _subscriptionService;

  PurchaseResultNotifier(this._subscriptionService) : super(null) {
    _init();
  }

  Future<void> _init() async {
    await _subscriptionService.initialize();
    
    // Listen to purchase results
    _subscriptionService.purchaseStream.listen((result) {
      state = result;
    });
  }

  void clearResult() {
    state = null;
  }
}

// Premium Feature Checker Provider
final premiumFeatureProvider = Provider.family<bool, PremiumFeature>((ref, feature) {
  final subscription = ref.watch(subscriptionProvider);
  return subscription?.features.contains(feature) ?? false;
});

// Subscription Plan Info Provider
final subscriptionPlanInfoProvider = Provider.family<Map<String, dynamic>?, SubscriptionPlan>((ref, plan) {
  return SubscriptionPlanInfo.getPlanInfo(plan);
});

// Is Premium User Provider
final isPremiumUserProvider = Provider<bool>((ref) {
  final subscription = ref.watch(subscriptionProvider);
  return subscription?.isActive == true && 
         (subscription?.expiryDate?.isAfter(DateTime.now()) ?? false);
});

// Daily Question Limit Provider (for free users)
final dailyQuestionLimitProvider = StateProvider<int>((ref) => 10);

// Questions Answered Today Provider
final questionsAnsweredTodayProvider = StateProvider<int>((ref) => 0);

// Can Answer More Questions Provider
final canAnswerMoreQuestionsProvider = Provider<bool>((ref) {
  final isPremium = ref.watch(isPremiumUserProvider);
  if (isPremium) return true;
  
  final limit = ref.watch(dailyQuestionLimitProvider);
  final answered = ref.watch(questionsAnsweredTodayProvider);
  return answered < limit;
});

// Question Report Service Provider
final questionReportServiceProvider = Provider<QuestionReportService>((ref) {
  return QuestionReportService();
});

// SharedPreferences Provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be initialized in main.dart');
});

// Selected Exam Provider
final selectedExamProvider = StateNotifierProvider<SelectedExamNotifier, String?>((ref) {
  return SelectedExamNotifier(ref.read(sharedPreferencesProvider));
});

class SelectedExamNotifier extends StateNotifier<String?> {
  final SharedPreferences _prefs;
  
  SelectedExamNotifier(this._prefs) : super(_prefs.getString('selected_exam'));
  
  void setExam(String exam) {
    state = exam;
    _prefs.setString('selected_exam', exam);
  }
  
  void clearExam() {
    state = null;
    _prefs.remove('selected_exam');
  }
}

// Selected Ministry Provider
final selectedMinistryProvider = StateNotifierProvider<SelectedMinistryNotifier, String?>((ref) {
  return SelectedMinistryNotifier(ref.read(sharedPreferencesProvider));
});

class SelectedMinistryNotifier extends StateNotifier<String?> {
  final SharedPreferences _prefs;
  
  SelectedMinistryNotifier(this._prefs) : super(_prefs.getString('selected_ministry'));
  
  void setMinistry(String ministry) {
    state = ministry;
    _prefs.setString('selected_ministry', ministry);
  }
  
  void clearMinistry() {
    state = null;
    _prefs.remove('selected_ministry');
  }
}

// Selected Profession Provider
final selectedProfessionProvider = StateNotifierProvider<SelectedProfessionNotifier, String?>((ref) {
  return SelectedProfessionNotifier(ref.read(sharedPreferencesProvider));
});

class SelectedProfessionNotifier extends StateNotifier<String?> {
  final SharedPreferences _prefs;
  
  SelectedProfessionNotifier(this._prefs) : super(_prefs.getString('selected_profession'));
  
  void setProfession(String profession) {
    state = profession;
    _prefs.setString('selected_profession', profession);
  }
  
  void clearProfession() {
    state = null;
    _prefs.remove('selected_profession');
  }
}