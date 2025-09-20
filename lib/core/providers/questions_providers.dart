import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/question_model.dart';
import '../services/questions_api_service.dart';
import '../repositories/questions_repository.dart';
import 'auth_providers.dart';

// Questions API Service Provider
final questionsApiServiceProvider = Provider<QuestionsApiService>((ref) {
  return QuestionsApiService();
});

// Questions Repository Provider
final questionsRepositoryProvider = Provider<QuestionsRepository>((ref) {
  final apiService = ref.watch(questionsApiServiceProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  
  return QuestionsRepositoryImpl(
    apiService: apiService,
    prefs: prefs,
  );
});

// Available Categories Provider
final availableCategoriesProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(questionsRepositoryProvider);
  return repository.getAvailableCategories();
});

// Available Professions Provider (for a specific category)
final availableProfessionsProvider = FutureProvider.family<List<String>, String>((ref, category) async {
  final repository = ref.watch(questionsRepositoryProvider);
  return repository.getAvailableProfessions(category);
});

// Available Subjects Provider (for a specific category and profession)
final availableSubjectsProvider = FutureProvider.family<List<String>, ({String category, String profession})>((ref, params) async {
  final repository = ref.watch(questionsRepositoryProvider);
  return repository.getAvailableSubjects(params.category, params.profession);
});

// All Questions Provider
final allQuestionsProvider = FutureProvider<List<Question>>((ref) async {
  final repository = ref.watch(questionsRepositoryProvider);
  return repository.getAllQuestions();
});

// Questions by Category Provider
final questionsByCategoryProvider = FutureProvider.family<List<Question>, String>((ref, category) async {
  final repository = ref.watch(questionsRepositoryProvider);
  return repository.getQuestionsByCategory(category);
});

// Questions by Profession Provider
final questionsByProfessionProvider = FutureProvider.family<List<Question>, String>((ref, profession) async {
  final repository = ref.watch(questionsRepositoryProvider);
  return repository.getQuestionsByProfession(profession);
});

// Questions by Category and Profession Provider
final questionsByCategoryAndProfessionProvider = FutureProvider.family<List<Question>, ({String category, String profession})>((ref, params) async {
  final repository = ref.watch(questionsRepositoryProvider);
  return repository.getQuestionsByCategoryAndProfession(params.category, params.profession);
});

// Cache Status Provider
final cacheStatusProvider = FutureProvider<bool>((ref) async {
  final repository = ref.watch(questionsRepositoryProvider);
  return repository.isDataCached();
});

// Refresh Questions Provider (for manual refresh)
final refreshQuestionsProvider = FutureProvider.family<List<Question>, bool>((ref, forceRefresh) async {
  final repository = ref.watch(questionsRepositoryProvider);
  return repository.getAllQuestions(forceRefresh: forceRefresh);
});

// Clear Cache Provider
final clearCacheProvider = FutureProvider<void>((ref) async {
  final repository = ref.watch(questionsRepositoryProvider);
  await repository.clearCache();
  
  // Invalidate all question-related providers to force refresh
  ref.invalidate(allQuestionsProvider);
  ref.invalidate(availableCategoriesProvider);
  ref.invalidate(cacheStatusProvider);
});

// Questions State Notifier for managing local state
class QuestionsStateNotifier extends StateNotifier<AsyncValue<List<Question>>> {
  final QuestionsRepository _repository;
  
  QuestionsStateNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadQuestions();
  }
  
  Future<void> loadQuestions({bool forceRefresh = false}) async {
    state = const AsyncValue.loading();
    
    try {
      final questions = await _repository.getAllQuestions(forceRefresh: forceRefresh);
      state = AsyncValue.data(questions);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> loadQuestionsByCategory(String category, {bool forceRefresh = false}) async {
    state = const AsyncValue.loading();
    
    try {
      final questions = await _repository.getQuestionsByCategory(category, forceRefresh: forceRefresh);
      state = AsyncValue.data(questions);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> loadQuestionsByProfession(String profession, {bool forceRefresh = false}) async {
    state = const AsyncValue.loading();
    
    try {
      final questions = await _repository.getQuestionsByProfession(profession, forceRefresh: forceRefresh);
      state = AsyncValue.data(questions);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> loadQuestionsByCategoryAndProfession(
    String category,
    String profession, {
    bool forceRefresh = false,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      final questions = await _repository.getQuestionsByCategoryAndProfession(
        category,
        profession,
        forceRefresh: forceRefresh,
      );
      state = AsyncValue.data(questions);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> refreshQuestions() async {
    await loadQuestions(forceRefresh: true);
  }
  
  Future<void> clearCache() async {
    try {
      await _repository.clearCache();
      await loadQuestions(forceRefresh: true);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Questions State Provider
final questionsStateProvider = StateNotifierProvider<QuestionsStateNotifier, AsyncValue<List<Question>>>((ref) {
  final repository = ref.watch(questionsRepositoryProvider);
  return QuestionsStateNotifier(repository);
});

// Selected Category Provider
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

// Selected Profession Provider
final selectedProfessionProvider = StateProvider<String?>((ref) => null);

// Filtered Questions Provider (based on selected category and profession)
final filteredQuestionsProvider = Provider<AsyncValue<List<Question>>>((ref) {
  final questionsState = ref.watch(questionsStateProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);
  final selectedProfession = ref.watch(selectedProfessionProvider);
  
  return questionsState.when(
    data: (questions) {
      List<Question> filteredQuestions = questions;
      
      // Apply category filter if selected
      if (selectedCategory != null) {
        // Note: This is a simple text-based filter since we're working with dynamic API data
        // In a real implementation, you might want to add category metadata to the Question model
        filteredQuestions = filteredQuestions.where((question) {
          return question.id.contains(selectedCategory!);
        }).toList();
      }
      
      // Apply profession filter if selected
      if (selectedProfession != null) {
        filteredQuestions = filteredQuestions.where((question) {
          return question.id.contains(selectedProfession!);
        }).toList();
      }
      
      return AsyncValue.data(filteredQuestions);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

// Questions Count Provider
final questionsCountProvider = Provider<int>((ref) {
  final questionsState = ref.watch(questionsStateProvider);
  return questionsState.when(
    data: (questions) => questions.length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

// Starred Questions Provider
final starredQuestionsProvider = Provider<List<Question>>((ref) {
  final questionsState = ref.watch(questionsStateProvider);
  return questionsState.when(
    data: (questions) => questions.where((q) => q.isStarred).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

// Random Questions Provider (for practice mode)
final randomQuestionsProvider = Provider.family<List<Question>, int>((ref, count) {
  final questionsState = ref.watch(questionsStateProvider);
  return questionsState.when(
    data: (questions) {
      final shuffled = List<Question>.from(questions)..shuffle();
      return shuffled.take(count).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// API Categories Provider - Gets all categories from API
final apiCategoriesProvider = FutureProvider<List<String>>((ref) async {
  final apiService = ref.watch(questionsApiServiceProvider);
  final response = await apiService.fetchAllQuestions();
  return apiService.getAvailableCategories(response);
});

// API Professions Provider - Gets all professions for a specific category
final apiProfessionsProvider = FutureProvider.family<List<String>, String>((ref, category) async {
  final apiService = ref.watch(questionsApiServiceProvider);
  final response = await apiService.fetchAllQuestions();
  return apiService.getAvailableProfessions(response, category);
});

// API Subjects Provider - Gets all subjects for a specific category and profession
final apiSubjectsProvider = FutureProvider.family<List<String>, ({String category, String profession})>((ref, params) async {
  final apiService = ref.watch(questionsApiServiceProvider);
  final response = await apiService.fetchAllQuestions();
  return apiService.getAvailableSubjects(response, params.category, params.profession);
});

// API Questions Count Provider - Gets total number of questions in API
final apiQuestionsCountProvider = FutureProvider<int>((ref) async {
  final apiService = ref.watch(questionsApiServiceProvider);
  final response = await apiService.fetchAllQuestions();
  final questions = apiService.convertApiQuestionsToQuestions(response);
  return questions.length;
});

// API Category Questions Count Provider - Gets number of questions for a specific category
final apiCategoryQuestionsCountProvider = FutureProvider.family<int, String>((ref, category) async {
  final apiService = ref.watch(questionsApiServiceProvider);
  final response = await apiService.fetchAllQuestions();
  final questions = apiService.convertApiQuestionsToQuestions(response, filterByCategory: category);
  return questions.length;
});