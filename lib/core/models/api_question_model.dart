import 'package:freezed_annotation/freezed_annotation.dart';
import 'question_model.dart';
import 'user_model.dart';

part 'api_question_model.freezed.dart';
part 'api_question_model.g.dart';

@freezed
class ApiQuestionsResponse with _$ApiQuestionsResponse {
  const factory ApiQuestionsResponse({
    required Map<String, Map<String, Map<String, List<ApiQuestion>>>> categories,
  }) = _ApiQuestionsResponse;

  factory ApiQuestionsResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, Map<String, Map<String, List<ApiQuestion>>>> categories = {};
    
    for (final entry in json.entries) {
      final categoryName = entry.key;
      final categoryData = entry.value as Map<String, dynamic>;
      
      final Map<String, Map<String, List<ApiQuestion>>> professions = {};
      
      for (final professionEntry in categoryData.entries) {
        final professionName = professionEntry.key;
        final professionData = professionEntry.value as Map<String, dynamic>;
        
        final Map<String, List<ApiQuestion>> subjects = {};
        
        for (final subjectEntry in professionData.entries) {
          final subjectName = subjectEntry.key;
          final questionsList = (subjectEntry.value as List)
              .map((q) => ApiQuestion.fromJson(q as Map<String, dynamic>))
              .toList();
          
          subjects[subjectName] = questionsList;
        }
        
        professions[professionName] = subjects;
      }
      
      categories[categoryName] = professions;
    }
    
    return ApiQuestionsResponse(categories: categories);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    
    for (final categoryEntry in categories.entries) {
      final categoryName = categoryEntry.key;
      final professions = categoryEntry.value;
      
      final Map<String, dynamic> categoryJson = {};
      
      for (final professionEntry in professions.entries) {
        final professionName = professionEntry.key;
        final subjects = professionEntry.value;
        
        final Map<String, dynamic> professionJson = {};
        
        for (final subjectEntry in subjects.entries) {
          final subjectName = subjectEntry.key;
          final questions = subjectEntry.value;
          
          professionJson[subjectName] = questions.map((q) => q.toJson()).toList();
        }
        
        categoryJson[professionName] = professionJson;
      }
      
      json[categoryName] = categoryJson;
    }
    
    return json;
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