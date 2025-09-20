import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ad_service.dart';

/// Provider for the AdService singleton instance
final adServiceProvider = Provider<AdService>((ref) {
  return AdService();
});

/// Provider for the number of ads watched today
final adsWatchedTodayProvider = StreamProvider<int>((ref) {
  final adService = ref.watch(adServiceProvider);
  return adService.adsWatchedStream;
});

/// Provider for the number of unlocked questions today
final unlockedQuestionsTodayProvider = StreamProvider<int>((ref) {
  final adService = ref.watch(adServiceProvider);
  return adService.unlockedQuestionsStream;
});

/// Provider for the current ad watching state
final adWatchingStateProvider = StateNotifierProvider<AdWatchingStateNotifier, AdWatchingState>((ref) {
  final adService = ref.watch(adServiceProvider);
  return AdWatchingStateNotifier(adService);
});

/// Provider for checking if user can unlock more questions
final canUnlockMoreQuestionsProvider = Provider<bool>((ref) {
  final adService = ref.watch(adServiceProvider);
  return adService.canUnlockMoreQuestions();
});

/// Provider for getting ads needed for next unlock
final adsNeededForUnlockProvider = Provider<int>((ref) {
  final adService = ref.watch(adServiceProvider);
  return adService.getAdsNeededForNextUnlock();
});

/// Provider for getting ad progress message
final adProgressMessageProvider = Provider<String>((ref) {
  final adService = ref.watch(adServiceProvider);
  return adService.getAdProgressMessage();
});

/// Provider for checking if user has unlocked questions
final hasUnlockedQuestionsProvider = Provider<bool>((ref) {
  final adService = ref.watch(adServiceProvider);
  return adService.hasUnlockedQuestions();
});

/// Provider for getting total available questions (base + unlocked)
final totalAvailableQuestionsProvider = Provider.family<int, int>((ref, baseLimit) {
  final adService = ref.watch(adServiceProvider);
  return adService.getTotalAvailableQuestions(baseLimit);
});

/// State for ad watching process
enum AdWatchingStatus {
  idle,
  loading,
  watching,
  completed,
  error,
}

class AdWatchingState {
  final AdWatchingStatus status;
  final String? errorMessage;
  final bool questionsUnlocked;
  final int adsWatched;
  final int unlockedQuestions;

  const AdWatchingState({
    required this.status,
    this.errorMessage,
    required this.questionsUnlocked,
    required this.adsWatched,
    required this.unlockedQuestions,
  });

  AdWatchingState copyWith({
    AdWatchingStatus? status,
    String? errorMessage,
    bool? questionsUnlocked,
    int? adsWatched,
    int? unlockedQuestions,
  }) {
    return AdWatchingState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      questionsUnlocked: questionsUnlocked ?? this.questionsUnlocked,
      adsWatched: adsWatched ?? this.adsWatched,
      unlockedQuestions: unlockedQuestions ?? this.unlockedQuestions,
    );
  }
}

/// State notifier for managing ad watching process
class AdWatchingStateNotifier extends StateNotifier<AdWatchingState> {
  final AdService _adService;

  AdWatchingStateNotifier(this._adService) 
      : super(AdWatchingState(
          status: AdWatchingStatus.idle,
          questionsUnlocked: false,
          adsWatched: _adService.adsWatchedToday,
          unlockedQuestions: _adService.unlockedQuestionsToday,
        )) {
    _initializeListeners();
  }

  void _initializeListeners() {
    // Listen to ad service streams
    _adService.adsWatchedStream.listen((adsWatched) {
      state = state.copyWith(adsWatched: adsWatched);
    });

    _adService.unlockedQuestionsStream.listen((unlockedQuestions) {
      state = state.copyWith(unlockedQuestions: unlockedQuestions);
    });
  }

  /// Watch an ad and handle the result
  Future<void> watchAd() async {
    if (state.status == AdWatchingStatus.watching) {
      return; // Already watching an ad
    }

    try {
      state = state.copyWith(
        status: AdWatchingStatus.watching,
        errorMessage: null,
        questionsUnlocked: false,
      );

      final questionsUnlocked = await _adService.watchAd();

      state = state.copyWith(
        status: AdWatchingStatus.completed,
        questionsUnlocked: questionsUnlocked,
        adsWatched: _adService.adsWatchedToday,
        unlockedQuestions: _adService.unlockedQuestionsToday,
      );

      // Reset to idle after a short delay
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        state = state.copyWith(status: AdWatchingStatus.idle);
      }
    } catch (error) {
      if (mounted) {
        state = state.copyWith(
          status: AdWatchingStatus.error,
          errorMessage: error.toString(),
        );
      }
    }
  }

  /// Reset the state to idle
  void resetState() {
    state = state.copyWith(
      status: AdWatchingStatus.idle,
      errorMessage: null,
      questionsUnlocked: false,
    );
  }

  /// Consume an unlocked question
  Future<void> consumeUnlockedQuestion() async {
    await _adService.consumeUnlockedQuestion();
    state = state.copyWith(unlockedQuestions: _adService.unlockedQuestionsToday);
  }
}