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
        print('DEBUG: API Response keys: ${jsonData.keys.toList()}');
        print('DEBUG: API Response structure sample: ${jsonData.entries.take(1).map((e) => '${e.key}: ${e.value.runtimeType}').join(', ')}');
        
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
    String? filterByProfession,
    String? filterBySubject,
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
        
        // Skip if filtering by subject and this doesn't match
        if (filterBySubject != null && subjectName != filterBySubject) {
          continue;
        }
        
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
    print('getAvailableSubjects - categoryName: $categoryName');
    print('getAvailableSubjects - professionName: $professionName');
    print('getAvailableSubjects - available categories: ${apiResponse.categories.keys.toList()}');
    
    final categoryData = apiResponse.categories[categoryName];
    print('getAvailableSubjects - categoryData found: ${categoryData != null}');
    
    if (categoryData != null) {
      print('getAvailableSubjects - available professions in category: ${categoryData.keys.toList()}');
      
      final professionData = categoryData[professionName];
      if (professionData != null) {
        print('getAvailableSubjects - profession "$professionName" found');
        final subjects = professionData.keys.toList();
        print('getAvailableSubjects - subjects found: $subjects');
        return subjects;
      } else {
        print('getAvailableSubjects - profession "$professionName" not found in category');
      }
    }
    
    print('getAvailableSubjects - returning empty list');
    return [];
  }

  List<String> getAvailableSubjectsForMinistryAndProfession({
    required String categoryName,
    required String ministryName,
    required String professionName,
  }) {
    print('getAvailableSubjectsForMinistryAndProfession called with:');
    print('  categoryName: $categoryName');
    print('  ministryName: $ministryName');
    print('  professionName: $professionName');
    
    if (_rawJsonData == null) {
      print('ERROR: _rawJsonData is null');
      return [];
    }
    
    try {
      // Access raw JSON data directly to get subjects
      final categoryData = _rawJsonData![categoryName] as Map<String, dynamic>?;
      if (categoryData == null) {
        print('ERROR: Category "$categoryName" not found in raw JSON');
        return [];
      }
      
      final ministryData = categoryData[ministryName] as Map<String, dynamic>?;
      if (ministryData == null) {
        print('ERROR: Ministry "$ministryName" not found in category "$categoryName"');
        return [];
      }
      
      final professionData = ministryData[professionName] as Map<String, dynamic>?;
      if (professionData == null) {
        print('ERROR: Profession "$professionName" not found in ministry "$ministryName"');
        return [];
      }
      
      // professionData keys are subject names (e.g., "2017 Çıkmış Sorular")
      final subjects = professionData.keys.toList();
      print('Found ${subjects.length} subjects: $subjects');
      
      return subjects;
    } catch (e) {
      print('ERROR: Failed to parse subjects from raw JSON: $e');
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