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
    for (final categoryEntry in apiResponse.cikmisSorular.entries) {
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
    Map<String, Map<String, Map<String, List<ApiQuestion>>>> categoryData,
    String categoryName,
    String? filterByMinistry,
    String? filterByProfession,
    String? filterBySubject,
  ) {
    // Process ministries (second level)
    for (final ministryEntry in categoryData.entries) {
      final ministryName = ministryEntry.key;
      
      // Skip if filtering by ministry and this doesn't match
      if (filterByMinistry != null && ministryName != filterByMinistry) {
        continue;
      }
      
      final ministryData = ministryEntry.value;
      
      // Process professions (third level)
      for (final professionEntry in ministryData.entries) {
        final professionName = professionEntry.key;
        
        // Skip if filtering by profession and this doesn't match
        if (filterByProfession != null && professionName != filterByProfession) {
          continue;
        }
        
        final professionData = professionEntry.value;
        
        // Process subjects (fourth level)
        for (final subjectEntry in professionData.entries) {
          final subjectName = subjectEntry.key;
          
          // Skip if filtering by subject and this doesn't match
          if (filterBySubject != null && subjectName != filterBySubject) {
            continue;
          }
          
          final apiQuestions = subjectEntry.value;
          
          // Convert to Question objects and process
          for (final apiQuestion in apiQuestions) {
            final question = _convertApiQuestionToQuestion(
              apiQuestion,
              categoryName,
              ministryName,
              professionName,
              subjectName,
            );
            questions.add(question);
          }
        }
      }
    }
  }

  Question _convertApiQuestionToQuestion(
    ApiQuestion apiQuestion,
    String categoryName,
    String ministryName,
    String professionName,
    String subjectName,
  ) {
    // Convert options map to list
    final optionsList = apiQuestion.secenekler.values.toList();
    
    // Find correct answer index
    final correctAnswerIndex = optionsList.indexOf(apiQuestion.dogruCevap);
    
    // Generate unique ID: categoryName_ministryName_professionName_subjectName_questionNo
    final id = '${categoryName}_${ministryName}_${professionName}_${subjectName}_${apiQuestion.soruNo}';
    
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
      subject: subjectName,
      ministry: ministryName,
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
    return apiResponse.cikmisSorular.keys.toList();
  }

  /// Gets available ministries for a specific category
  List<String> getAvailableMinistries(
    ApiQuestionsResponse apiResponse,
    String categoryName,
  ) {
    final categoryData = apiResponse.cikmisSorular[categoryName];
    return categoryData?.keys.toList() ?? [];
  }

  /// Gets available professions for a specific category and ministry
  List<String> getAvailableProfessions(
    ApiQuestionsResponse apiResponse,
    String categoryName,
    String ministryName,
  ) {
    final categoryData = apiResponse.cikmisSorular[categoryName];
    if (categoryData != null) {
      final ministryData = categoryData[ministryName];
      return ministryData?.keys.toList() ?? [];
    }
    return [];
  }

  /// Gets available subjects for a specific category, ministry and profession
  List<String> getAvailableSubjects(
    ApiQuestionsResponse apiResponse,
    String categoryName,
    String ministryName,
    String professionName,
  ) {
    final categoryData = apiResponse.cikmisSorular[categoryName];
    
    if (categoryData != null) {
      final ministryData = categoryData[ministryName];
      if (ministryData != null) {
        final professionData = ministryData[professionName];
        if (professionData != null) {
          return professionData.keys.toList();
        }
      }
    }
    
    return [];
  }

  /// Gets available mini question categories
  List<String> getAvailableMiniCategories(ApiQuestionsResponse apiResponse) {
    return apiResponse.miniSorular.keys.toList();
  }

  /// Gets available ministries for mini questions in a specific category
  List<String> getAvailableMiniMinistries(
    ApiQuestionsResponse apiResponse,
    String categoryName,
  ) {
    final categoryData = apiResponse.miniSorular[categoryName];
    return categoryData?.keys.toList() ?? [];
  }

  /// Gets available professions for mini questions in a specific category and ministry
  List<String> getAvailableMiniProfessions(
    ApiQuestionsResponse apiResponse,
    String categoryName,
    String ministryName,
  ) {
    final categoryData = apiResponse.miniSorular[categoryName];
    if (categoryData != null) {
      final ministryData = categoryData[ministryName];
      return ministryData?.keys.toList() ?? [];
    }
    return [];
  }

  /// Gets available subjects for mini questions in a specific category, ministry and profession
  List<String> getAvailableMiniSubjects(
    ApiQuestionsResponse apiResponse,
    String categoryName,
    String ministryName,
    String professionName,
  ) {
    final categoryData = apiResponse.miniSorular[categoryName];
    
    if (categoryData != null) {
      final ministryData = categoryData[ministryName];
      if (ministryData != null) {
        final professionData = ministryData[professionName];
        if (professionData != null) {
          return professionData.keys.toList();
        }
      }
    }
    
    return [];
  }

  /// Gets mini questions for a specific category, ministry, profession and subject
  List<ApiQuestion> getMiniQuestions(
    ApiQuestionsResponse apiResponse,
    String categoryName,
    String ministryName,
    String professionName,
    String subjectName,
  ) {
    final categoryData = apiResponse.miniSorular[categoryName];
    
    if (categoryData != null) {
      final ministryData = categoryData[ministryName];
      if (ministryData != null) {
        final professionData = ministryData[professionName];
        if (professionData != null) {
          return professionData[subjectName] ?? [];
        }
      }
    }
    
    return [];
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