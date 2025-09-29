import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_question_model.dart';
import '../models/question_model.dart';
import '../services/questions_api_service.dart';

abstract class QuestionsRepository {
  Future<List<Question>> getAllQuestions({bool forceRefresh = false});
  Future<List<Question>> getQuestionsByCategory(String category, {bool forceRefresh = false});
  Future<List<Question>> getQuestionsByProfession(String profession, {bool forceRefresh = false});
  Future<List<Question>> getQuestionsByCategoryAndProfession(
    String category,
    String profession, {
    bool forceRefresh = false,
  });
  Future<List<Question>> getQuestionsByCategoryProfessionAndSubject(
    String category,
    String profession,
    String subject, {
    bool forceRefresh = false,
  });
  Future<List<Question>> getQuestionsByCategoryMinistryProfessionAndSubject(
    String category,
    String ministry,
    String profession,
    String subject, {
    bool forceRefresh = false,
  });
  Future<List<String>> getAvailableCategories({bool forceRefresh = false});
  Future<List<String>> getAvailableProfessions(String category, {bool forceRefresh = false});
  Future<List<String>> getAvailableSubjects(String category, String profession, {bool forceRefresh = false});
  Future<void> clearCache();
  Future<bool> isDataCached();
}

class QuestionsRepositoryImpl implements QuestionsRepository {
  static const String _cacheKey = 'cached_questions_data';
  static const String _cacheTimestampKey = 'cached_questions_timestamp';
  static const Duration _cacheExpiration = Duration(hours: 24);

  final QuestionsApiService _apiService;
  final SharedPreferences _prefs;
  
  ApiQuestionsResponse? _cachedApiResponse;
  DateTime? _lastCacheTime;

  QuestionsRepositoryImpl({
    required QuestionsApiService apiService,
    required SharedPreferences prefs,
  }) : _apiService = apiService, _prefs = prefs;

  @override
  Future<List<Question>> getAllQuestions({bool forceRefresh = false}) async {
    final apiResponse = await _getApiResponse(forceRefresh: forceRefresh);
    return _apiService.convertApiQuestionsToQuestions(apiResponse);
  }

  @override
  Future<List<Question>> getQuestionsByCategory(
    String category, {
    bool forceRefresh = false,
  }) async {
    final apiResponse = await _getApiResponse(forceRefresh: forceRefresh);
    return _apiService.convertApiQuestionsToQuestions(
      apiResponse,
      filterByCategory: category,
    );
  }

  @override
  Future<List<Question>> getQuestionsByProfession(
    String profession, {
    bool forceRefresh = false,
  }) async {
    final apiResponse = await _getApiResponse(forceRefresh: forceRefresh);
    return _apiService.convertApiQuestionsToQuestions(
      apiResponse,
      filterByProfession: profession,
    );
  }

  @override
  Future<List<Question>> getQuestionsByCategoryAndProfession(
    String category,
    String profession, {
    bool forceRefresh = false,
  }) async {
    final apiResponse = await _getApiResponse(forceRefresh: forceRefresh);
    return _apiService.convertApiQuestionsToQuestions(
      apiResponse,
      filterByCategory: category,
      filterByProfession: profession,
    );
  }

  @override
  Future<List<Question>> getQuestionsByCategoryProfessionAndSubject(
    String category,
    String profession,
    String subject, {
    bool forceRefresh = false,
  }) async {
    final apiResponse = await _getApiResponse(forceRefresh: forceRefresh);
    return _apiService.convertApiQuestionsToQuestions(
      apiResponse,
      filterByCategory: category,
      filterByProfession: profession,
      filterBySubject: subject,
    );
  }

  // New method for 4-level filtering: Category > Ministry > Profession > Subject
  Future<List<Question>> getQuestionsByCategoryMinistryProfessionAndSubject(
    String category,
    String ministry,
    String profession,
    String subject, {
    bool forceRefresh = false,
  }) async {
    final apiResponse = await _getApiResponse(forceRefresh: forceRefresh);
    return _apiService.convertApiQuestionsToQuestions(
      apiResponse,
      filterByCategory: category,
      filterByMinistry: ministry,
      filterByProfession: profession,
      filterBySubject: subject,
    );
  }

  @override
  Future<List<String>> getAvailableCategories({bool forceRefresh = false}) async {
    final apiResponse = await _getApiResponse(forceRefresh: forceRefresh);
    return _apiService.getAvailableCategories(apiResponse);
  }

  @override
  Future<List<String>> getAvailableProfessions(
    String category, {
    bool forceRefresh = false,
  }) async {
    final apiResponse = await _getApiResponse(forceRefresh: forceRefresh);
    // For backward compatibility, get all professions from all ministries
    final List<String> allProfessions = [];
    final ministries = _apiService.getAvailableMinistries(apiResponse, category);
    
    for (final ministry in ministries) {
      final professions = _apiService.getAvailableProfessions(apiResponse, category, ministry);
      allProfessions.addAll(professions);
    }
    
    return allProfessions.toSet().toList(); // Remove duplicates
  }

  @override
  Future<List<String>> getAvailableSubjects(
    String category,
    String profession, {
    bool forceRefresh = false,
  }) async {
    final apiResponse = await _getApiResponse(forceRefresh: forceRefresh);
    // For backward compatibility, get all subjects from all ministries
    final List<String> allSubjects = [];
    final ministries = _apiService.getAvailableMinistries(apiResponse, category);
    
    for (final ministry in ministries) {
      final subjects = _apiService.getAvailableSubjects(apiResponse, category, ministry, profession);
      allSubjects.addAll(subjects);
    }
    
    return allSubjects.toSet().toList(); // Remove duplicates
  }

  @override
  Future<void> clearCache() async {
    await _prefs.remove(_cacheKey);
    await _prefs.remove(_cacheTimestampKey);
    _cachedApiResponse = null;
    _lastCacheTime = null;
  }

  @override
  Future<bool> isDataCached() async {
    final cachedData = _prefs.getString(_cacheKey);
    final timestampString = _prefs.getString(_cacheTimestampKey);
    
    if (cachedData == null || timestampString == null) {
      return false;
    }
    
    final timestamp = DateTime.tryParse(timestampString);
    if (timestamp == null) {
      return false;
    }
    
    final isExpired = DateTime.now().difference(timestamp) > _cacheExpiration;
    return !isExpired;
  }

  Future<ApiQuestionsResponse> _getApiResponse({bool forceRefresh = false}) async {
    // Return cached response if available and not forcing refresh
    if (!forceRefresh && _cachedApiResponse != null && _isCacheValid()) {
      return _cachedApiResponse!;
    }

    // Try to load from local cache first
    if (!forceRefresh) {
      final cachedResponse = await _loadFromCache();
      if (cachedResponse != null) {
        _cachedApiResponse = cachedResponse;
        return cachedResponse;
      }
    }

    // Fetch from API
    try {
      final apiResponse = await _apiService.fetchAllQuestions();
      
      // Cache the response
      await _saveToCache(apiResponse);
      _cachedApiResponse = apiResponse;
      _lastCacheTime = DateTime.now();
      
      return apiResponse;
    } catch (e) {
      // If API fails and we have cached data, use it even if expired
      final cachedResponse = await _loadFromCache();
      if (cachedResponse != null) {
        _cachedApiResponse = cachedResponse;
        return cachedResponse;
      }
      
      // If no cached data available, rethrow the error
      rethrow;
    }
  }

  bool _isCacheValid() {
    if (_lastCacheTime == null) return false;
    return DateTime.now().difference(_lastCacheTime!) < _cacheExpiration;
  }

  Future<ApiQuestionsResponse?> _loadFromCache() async {
    try {
      final cachedData = _prefs.getString(_cacheKey);
      final timestampString = _prefs.getString(_cacheTimestampKey);
      
      if (cachedData == null || timestampString == null) {
        return null;
      }
      
      final timestamp = DateTime.tryParse(timestampString);
      if (timestamp == null) {
        return null;
      }
      
      // Check if cache is expired
      final isExpired = DateTime.now().difference(timestamp) > _cacheExpiration;
      if (isExpired) {
        return null;
      }
      
      final jsonData = json.decode(cachedData) as Map<String, dynamic>;
      _lastCacheTime = timestamp;
      
      return ApiQuestionsResponse.fromJson(jsonData);
    } catch (e) {
      // If cache is corrupted, clear it
      await clearCache();
      return null;
    }
  }

  Future<void> _saveToCache(ApiQuestionsResponse response) async {
    try {
      final jsonString = json.encode(response.toJson());
      final timestamp = DateTime.now().toIso8601String();
      
      await _prefs.setString(_cacheKey, jsonString);
      await _prefs.setString(_cacheTimestampKey, timestamp);
    } catch (e) {
      // If caching fails, continue without caching
      // This ensures the app doesn't break if storage is full
    }
  }
}