import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api_question_model.dart';
import '../models/question_model.dart';
import '../models/user_model.dart';

class QuestionsApiService {
  static const String _baseUrl = 'https://mehmetakifurgen.github.io/gorevde_yukselme/sorular.json';
  
  final http.Client _httpClient;
  
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
        return ApiQuestionsResponse.fromJson(jsonData);
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
    String? filterByProfession,
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
        filterByProfession,
      );
    }
    
    return questions;
  }

  void _processCategory(
    List<Question> questions,
    Map<String, Map<String, List<ApiQuestion>>> categoryData,
    String categoryName,
    String? filterByProfession,
  ) {
    for (final professionEntry in categoryData.entries) {
      final professionName = professionEntry.key;
      
      // Skip if filtering by profession and this doesn't match
      if (filterByProfession != null && professionName != filterByProfession) {
        continue;
      }
      
      final subjects = professionEntry.value;
      
      for (final subjectEntry in subjects.entries) {
        final subjectName = subjectEntry.key;
        final apiQuestions = subjectEntry.value;
        
        for (final apiQuestion in apiQuestions) {
          final question = _convertApiQuestionToQuestion(
            apiQuestion,
            categoryName,
            professionName,
            subjectName,
          );
          questions.add(question);
        }
      }
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
    switch (professionName.toLowerCase()) {
      case 'idare memuru':
      case 'İdare memuru':
        return [UserProfession.generalRegulations];
      case 'şef':
        return [UserProfession.generalRegulations];
      case 'yazı işleri müdürü':
        return [UserProfession.generalRegulations];
      case 'ikinci müdür':
        return [UserProfession.generalRegulations];
      case 'idari işler müdürü':
        return [UserProfession.generalRegulations];
      case 'infaz koruma baş memurluğu':
        return [UserProfession.generalRegulations];
      case 'zabıt katibi':
        return [UserProfession.generalRegulations];
      default:
        return [UserProfession.generalRegulations]; // Default
    }
  }
  
  QuestionCategory _mapCategoryNameToEnum(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'görevde yükselme':
        return QuestionCategory.generalRegulations;
      case 'ünvan değişikliği':
        return QuestionCategory.generalRegulations;
      default:
        return QuestionCategory.generalRegulations;
    }
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
    return categoryData?[professionName]?.keys.toList() ?? [];
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