import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/api_question_model.dart';
import '../repositories/questions_repository.dart';
import '../providers/questions_providers.dart';

/// Service for handling dynamic category data from API
class CategoryService {
  final QuestionsRepository _repository;
  
  CategoryService(this._repository);
  
  /// Get all available category names from API
  Future<List<String>> getAvailableCategories() async {
    return await _repository.getAvailableCategories();
  }
  
  /// Get display name for a category (uses the API key as display name)
  /// This replaces the static displayName extension
  Future<String> getCategoryDisplayName(String categoryKey) async {
    final categories = await getAvailableCategories();
    
    // Return the category key if it exists, otherwise return a fallback
    if (categories.contains(categoryKey)) {
      return categoryKey;
    }
    
    return 'Bilinmeyen Kategori';
  }
  
  /// Get all categories with their display names
  Future<Map<String, String>> getAllCategoriesWithDisplayNames() async {
    final categories = await getAvailableCategories();
    final Map<String, String> categoryMap = {};
    
    for (final category in categories) {
      categoryMap[category] = category; // Use API key as display name
    }
    
    return categoryMap;
  }
  
  /// Get available professions for a specific category
  Future<List<String>> getAvailableProfessions(String categoryName) async {
    return await _repository.getAvailableProfessions(categoryName);
  }
  
  /// Get available subjects for a specific category and profession
  Future<List<String>> getAvailableSubjects(
    String categoryName,
    String professionName,
  ) async {
    return await _repository.getAvailableSubjects(categoryName, professionName);
  }
}

/// Provider for CategoryService
final categoryServiceProvider = Provider<CategoryService>((ref) {
  final repository = ref.watch(questionsRepositoryProvider);
  return CategoryService(repository);
});

/// Provider for available categories with display names
final categoriesWithDisplayNamesProvider = FutureProvider<Map<String, String>>((ref) async {
  final categoryService = ref.watch(categoryServiceProvider);
  return categoryService.getAllCategoriesWithDisplayNames();
});

/// Provider for category display name
final categoryDisplayNameProvider = FutureProvider.family<String, String>((ref, categoryKey) async {
  final categoryService = ref.watch(categoryServiceProvider);
  return categoryService.getCategoryDisplayName(categoryKey);
});