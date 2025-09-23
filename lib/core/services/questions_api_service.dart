import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api_question_model.dart';
import '../models/question_model.dart';
import '../models/user_model.dart';

class QuestionsApiService {
  static const String _baseUrl = 'https://mehmetakifurgen.github.io/gorevde_yukselme/sorular.json';
  
  final http.Client _httpClient;
  Map<String, dynamic>? _rawJsonData;
  ApiQuestionsResponse? apiResponse;
  
  QuestionsApiService({http.Client? httpClient}) 
      : _httpClient = httpClient ?? http.Client();

  /// Fetches all questions from the remote API
  Future<ApiQuestionsResponse> fetchAllQuestions() async {
    try {
      final response = await _httpClient.get(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        
        // Store raw JSON data for subject extraction
        _rawJsonData = jsonData;
        
        // Parse and store API response
        apiResponse = ApiQuestionsResponse.fromJson(jsonData);
        
        return apiResponse!;
      } else {
        throw QuestionsApiException(
          'Failed to fetch questions: ${response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is QuestionsApiException) {
        rethrow;
      }
      throw QuestionsApiException('Network error: ${e.toString()}');
    }
  }

  /// Converts API questions to app Question models
  List<Question> convertApiQuestionsToQuestions(
    ApiQuestionsResponse apiResponse, {
    String? filterByCategory,
    String? filterByMinistry,
    String? filterByProfession,
    String? filterBySubject,
  }) {
    final List<Question> questions = [];
    
    // Process all categories dynamically
    for (final categoryEntry in apiResponse.categories.entries) {
      final categoryName = categoryEntry.key;
      final categoryData = categoryEntry.value;
      
      // Skip if filtering by category and this doesn't match
      if (filterByCategory != null && categoryName != filterByCategory) {
        continue;
      }
      
      _processCategory(
        questions,
        categoryData,
        categoryName,
        filterByMinistry,
        filterByProfession,
        filterBySubject,
      );
    }
    
    return questions;
  }

  void _processCategory(
    List<Question> questions,
    Map<String, Map<String, List<ApiQuestion>>> categoryData,
    String categoryName,
    String? filterByMinistry,
    String? filterByProfession,
    String? filterBySubject,
  ) {
    // Note: categoryData structure is actually Category > Ministry > Profession > Subject
    // But the type signature shows Map<String, Map<String, List<ApiQuestion>>> which is 3-level
    // This is because the API response model doesn't match the actual JSON structure
    // We need to handle this by accessing raw JSON data for 4-level filtering
    
    if (_rawJsonData == null) {
      return;
    }
    
    try {
      final categoryRawData = _rawJsonData![categoryName] as Map<String, dynamic>?;
      if (categoryRawData == null) {
        return;
      }
      
      // Process ministries (second level)
      for (final ministryEntry in categoryRawData.entries) {
        final ministryName = ministryEntry.key;
        
        // Skip if filtering by ministry and this doesn't match
        if (filterByMinistry != null && ministryName != filterByMinistry) {
          continue;
        }
        
        final ministryData = ministryEntry.value as Map<String, dynamic>?;
        if (ministryData == null) continue;
        
        // Process professions (third level)
        for (final professionEntry in ministryData.entries) {
          final professionName = professionEntry.key;
          
          // Skip if filtering by profession and this doesn't match
          if (filterByProfession != null && professionName != filterByProfession) {
            continue;
          }
          
          final professionData = professionEntry.value as Map<String, dynamic>?;
          if (professionData == null) continue;
          
          // Process subjects (fourth level)
          for (final subjectEntry in professionData.entries) {
            final subjectName = subjectEntry.key;
            
            // Skip if filtering by subject and this doesn't match
            if (filterBySubject != null && subjectName != filterBySubject) {
              continue;
            }
            
            final subjectData = subjectEntry.value as List<dynamic>?;
            if (subjectData == null) continue;
            
            // Convert to ApiQuestion objects and process
            for (final questionData in subjectData) {
              try {
                final apiQuestion = ApiQuestion.fromJson(questionData as Map<String, dynamic>);
                final question = _convertApiQuestionToQuestion(
                  apiQuestion,
                  categoryName,
                  professionName,
                  subjectName,
                );
                questions.add(question);
              } catch (e) {
                // Skip invalid questions
              }
            }
          }
        }
      }
    } catch (e) {
      // Skip category processing on error
    }
  }

  Question _convertApiQuestionToQuestion(
    ApiQuestion apiQuestion,
    String categoryName,
    String professionName,
    String subjectName,
  ) {
    // Convert options map to list
    final optionsList = apiQuestion.secenekler.values.toList();
    
    // Find correct answer index
    final correctAnswerIndex = optionsList.indexOf(apiQuestion.dogruCevap);
    
    // Generate unique ID
    final id = '${categoryName}_${professionName}_${subjectName}_${apiQuestion.soruNo}';
    
    // Map profession name to UserProfession enum
    final targetProfessions = _mapProfessionNameToEnum(professionName);
    
    // Map category to QuestionCategory enum
    final category = _mapCategoryNameToEnum(categoryName);
    
    return Question(
      id: id,
      questionText: apiQuestion.soru,
      options: optionsList,
      correctAnswerIndex: correctAnswerIndex >= 0 ? correctAnswerIndex : 0,
      explanation: apiQuestion.ozet,
      difficulty: QuestionDifficulty.medium, // Default difficulty
      category: category,
      targetProfessions: targetProfessions,
      isStarred: false,
    );
  }
  
  List<UserProfession> _mapProfessionNameToEnum(String professionName) {
    // Dinamik meslek eşlemesi - tüm meslekler için genel düzenlemeler kullanılıyor
    return [UserProfession.generalRegulations];
  }
  
  QuestionCategory _mapCategoryNameToEnum(String categoryName) {
    // Dinamik kategori eşlemesi - tüm kategoriler için genel düzenlemeler kullanılıyor
    return QuestionCategory.generalRegulations;
  }

  /// Gets available categories from the API response
  List<String> getAvailableCategories(ApiQuestionsResponse apiResponse) {
    return apiResponse.categories.keys.toList();
  }

  /// Gets available professions for a specific category
  List<String> getAvailableProfessions(
    ApiQuestionsResponse apiResponse,
    String categoryName,
  ) {
    final categoryData = apiResponse.categories[categoryName];
    return categoryData?.keys.toList() ?? [];
  }

  /// Gets available subjects for a specific category and profession
  List<String> getAvailableSubjects(
    ApiQuestionsResponse apiResponse,
    String categoryName,
    String professionName,
  ) {
    final categoryData = apiResponse.categories[categoryName];
    
    if (categoryData != null) {
      final professionData = categoryData[professionName];
      if (professionData != null) {
        final subjects = professionData.keys.toList();
        return subjects;
      }
    }
    
    return [];
  }

  List<String> getAvailableSubjectsForMinistryAndProfession({
    required String categoryName,
    required String ministryName,
    required String professionName,
  }) {
    if (_rawJsonData == null) {
      return [];
    }
    
    try {
      // Access raw JSON data directly to get subjects
      final categoryData = _rawJsonData![categoryName] as Map<String, dynamic>?;
      if (categoryData == null) {
        return [];
      }
      
      final ministryData = categoryData[ministryName] as Map<String, dynamic>?;
      if (ministryData == null) {
        return [];
      }
      
      final professionData = ministryData[professionName] as Map<String, dynamic>?;
      if (professionData == null) {
        return [];
      }
      
      // professionData keys are subject names (e.g., "2017 Çıkmış Sorular")
      final subjects = professionData.keys.toList();
      
      return subjects;
    } catch (e) {
      return [];
    }
  }

  void dispose() {
    _httpClient.close();
  }
}

class QuestionsApiException implements Exception {
  final String message;
  final int? statusCode;
  
  const QuestionsApiException(this.message, [this.statusCode]);
  
  @override
  String toString() => 'QuestionsApiException: $message';
}