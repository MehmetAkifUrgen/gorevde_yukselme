import 'package:freezed_annotation/freezed_annotation.dart';
import 'question_model.dart';
import 'user_model.dart';

part 'api_question_model.freezed.dart';
part 'api_question_model.g.dart';

@freezed
class ApiQuestionsResponse with _$ApiQuestionsResponse {
  const factory ApiQuestionsResponse({
    required Map<String, Map<String, Map<String, Map<String, List<ApiQuestion>>>>> cikmisSorular,
  }) = _ApiQuestionsResponse;

  factory ApiQuestionsResponse.fromJson(Map<String, dynamic> json) {
    print('DEBUG: ApiQuestionsResponse.fromJson called with json keys: ${json.keys.toList()}');
    
    // Check if the new structure exists
    if (json.containsKey('cikmis_sorular')) {
      print('DEBUG: Using new API structure with cikmis_sorular');
      final cikmisSorularData = json['cikmis_sorular'] as Map<String, dynamic>;
      final Map<String, Map<String, Map<String, Map<String, List<ApiQuestion>>>>> cikmisSorular = {};
      
      for (final entry in cikmisSorularData.entries) {
        final categoryName = entry.key;
        print('DEBUG: Processing category: $categoryName');
        
        if (entry.value is! Map<String, dynamic>) {
          print('ERROR: Expected Map<String, dynamic> for category $categoryName, got ${entry.value.runtimeType}');
          continue;
        }
        
        final categoryData = entry.value as Map<String, dynamic>;
        final Map<String, Map<String, Map<String, List<ApiQuestion>>>> ministries = {};
        
        for (final ministryEntry in categoryData.entries) {
          final ministryName = ministryEntry.key;
          print('DEBUG: Processing ministry: $ministryName in category: $categoryName');
          
          if (ministryEntry.value is! Map<String, dynamic>) {
            print('ERROR: Expected Map<String, dynamic> for ministry $ministryName, got ${ministryEntry.value.runtimeType}');
            continue;
          }
          
          final ministryData = ministryEntry.value as Map<String, dynamic>;
          final Map<String, Map<String, List<ApiQuestion>>> professions = {};
          
          for (final professionEntry in ministryData.entries) {
            final professionName = professionEntry.key;
            print('DEBUG: Processing profession: $professionName in ministry: $ministryName');
            
            if (professionEntry.value is! Map<String, dynamic>) {
              print('ERROR: Expected Map<String, dynamic> for profession $professionName, got ${professionEntry.value.runtimeType}');
              continue;
            }
            
            final professionData = professionEntry.value as Map<String, dynamic>;
            final Map<String, List<ApiQuestion>> subjects = {};
            
            for (final subjectEntry in professionData.entries) {
              final subjectName = subjectEntry.key;
              print('DEBUG: Processing subject: $subjectName in profession: $professionName');
              
              // Subject data is directly a List of questions (not a Map with year keys)
              if (subjectEntry.value is! List) {
                print('ERROR: Expected List for subject $subjectName, got ${subjectEntry.value.runtimeType}');
                continue;
              }
              
              try {
                final subjectQuestions = (subjectEntry.value as List)
                    .map((q) => ApiQuestion.fromJson(q as Map<String, dynamic>))
                    .toList();
                
                subjects[subjectName] = subjectQuestions;
                print('DEBUG: Successfully processed ${subjectQuestions.length} questions for subject: $subjectName');
              } catch (e, stackTrace) {
                print('ERROR: Failed to process questions for subject $subjectName: $e');
                print('DEBUG: Stack trace: $stackTrace');
                print('DEBUG: Raw subject data: ${subjectEntry.value}');
              }
            }
            
            professions[professionName] = subjects;
          }
          
          ministries[ministryName] = professions;
        }
        
        cikmisSorular[categoryName] = ministries;
      }
      
      print('DEBUG: ApiQuestionsResponse.fromJson completed with ${cikmisSorular.length} categories');
      return ApiQuestionsResponse(cikmisSorular: cikmisSorular);
    }
    
    // Fallback to old structure for backward compatibility
    print('DEBUG: Using old API structure');
    final Map<String, Map<String, Map<String, List<ApiQuestion>>>> categories = {};
    
    for (final entry in json.entries) {
      final categoryName = entry.key;
      print('DEBUG: Processing category: $categoryName');
      print('DEBUG: Category data type: ${entry.value.runtimeType}');
      
      if (entry.value is! Map<String, dynamic>) {
        print('ERROR: Expected Map<String, dynamic> for category $categoryName, got ${entry.value.runtimeType}');
        continue;
      }
      
      final categoryData = entry.value as Map<String, dynamic>;
      final Map<String, Map<String, List<ApiQuestion>>> professions = {};
      
      for (final professionEntry in categoryData.entries) {
        final professionName = professionEntry.key;
        print('DEBUG: Processing profession: $professionName in category: $categoryName');
        print('DEBUG: Profession data type: ${professionEntry.value.runtimeType}');
        
        if (professionEntry.value is! Map<String, dynamic>) {
          print('ERROR: Expected Map<String, dynamic> for profession $professionName, got ${professionEntry.value.runtimeType}');
          continue;
        }
        
        final professionData = professionEntry.value as Map<String, dynamic>;
        final Map<String, List<ApiQuestion>> subjects = {};
        
        for (final subjectEntry in professionData.entries) {
          final subjectName = subjectEntry.key;
          print('DEBUG: Processing subject: $subjectName in profession: $professionName');
          print('DEBUG: Subject data type: ${subjectEntry.value.runtimeType}');
          
          // Subject data can be either a Map with year keys or directly a List
          if (subjectEntry.value is List) {
            // Direct list of questions (new structure)
            try {
              final subjectQuestions = (subjectEntry.value as List)
                  .map((q) => ApiQuestion.fromJson(q as Map<String, dynamic>))
                  .toList();
              
              subjects[subjectName] = subjectQuestions;
              print('DEBUG: Successfully processed ${subjectQuestions.length} questions for subject: $subjectName (direct list)');
            } catch (e, stackTrace) {
              print('ERROR: Failed to process direct questions for subject $subjectName: $e');
              print('DEBUG: Stack trace: $stackTrace');
            }
          } else if (subjectEntry.value is Map<String, dynamic>) {
            // Map with year keys (old structure)
            try {
              final subjectData = subjectEntry.value as Map<String, dynamic>;
              final List<ApiQuestion> allQuestions = [];
              
              // Process each year's questions
              for (final yearEntry in subjectData.entries) {
                final yearName = yearEntry.key;
                print('DEBUG: Processing year: $yearName for subject: $subjectName');
                
                if (yearEntry.value is! List) {
                  print('ERROR: Expected List for year $yearName in subject $subjectName, got ${yearEntry.value.runtimeType}');
                  continue;
                }
                
                final yearQuestions = (yearEntry.value as List)
                    .map((q) => ApiQuestion.fromJson(q as Map<String, dynamic>))
                    .toList();
                
                allQuestions.addAll(yearQuestions);
                print('DEBUG: Added ${yearQuestions.length} questions from year: $yearName');
              }
              
              subjects[subjectName] = allQuestions;
              print('DEBUG: Successfully processed ${allQuestions.length} total questions for subject: $subjectName (year-based)');
            } catch (e, stackTrace) {
              print('ERROR: Failed to process year-based questions for subject $subjectName: $e');
              print('DEBUG: Stack trace: $stackTrace');
              print('DEBUG: Raw subject data: ${subjectEntry.value}');
            }
          } else {
            print('ERROR: Expected List or Map<String, dynamic> for subject $subjectName, got ${subjectEntry.value.runtimeType}');
            print('DEBUG: Subject data content: ${subjectEntry.value}');
            continue;
          }
        }
        
        professions[professionName] = subjects;
      }
      
      categories[categoryName] = professions;
    }
    
    print('DEBUG: ApiQuestionsResponse.fromJson completed with ${categories.length} categories');
    // Convert old structure to new structure for consistency
    final Map<String, Map<String, Map<String, Map<String, List<ApiQuestion>>>>> cikmisSorular = {};
    for (final entry in categories.entries) {
      cikmisSorular[entry.key] = {'Genel': entry.value};
    }
    return ApiQuestionsResponse(cikmisSorular: cikmisSorular);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    
    for (final categoryEntry in cikmisSorular.entries) {
      final categoryName = categoryEntry.key;
      final ministries = categoryEntry.value;
      
      final Map<String, dynamic> categoryJson = {};
      
      for (final ministryEntry in ministries.entries) {
        final ministryName = ministryEntry.key;
        final professions = ministryEntry.value;
        
        final Map<String, dynamic> ministryJson = {};
        
        for (final professionEntry in professions.entries) {
          final professionName = professionEntry.key;
          final subjects = professionEntry.value;
          
          final Map<String, dynamic> professionJson = {};
          
          for (final subjectEntry in subjects.entries) {
            final subjectName = subjectEntry.key;
            final questions = subjectEntry.value;
            
            professionJson[subjectName] = questions.map((q) => q.toJson()).toList();
          }
          
          ministryJson[professionName] = professionJson;
        }
        
        categoryJson[ministryName] = ministryJson;
      }
      
      json[categoryName] = categoryJson;
    }
    
    return {'cikmis_sorular': json};
  }
}

@freezed
class ApiQuestion with _$ApiQuestion {
  const factory ApiQuestion({
    @JsonKey(name: 'soru_no') required int soruNo,
    @JsonKey(name: 'soru') required String soru,
    @JsonKey(name: 'secenekler') required Map<String, String> secenekler,
    @JsonKey(name: 'dogru_cevap') required String dogruCevap,
    @JsonKey(name: 'ozet') required String ozet,
  }) = _ApiQuestion;

  factory ApiQuestion.fromJson(Map<String, dynamic> json) =>
      _$ApiQuestionFromJson(json);
}