// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_question_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ApiQuestionImpl _$$ApiQuestionImplFromJson(Map<String, dynamic> json) =>
    _$ApiQuestionImpl(
      soruNo: (json['soru_no'] as num).toInt(),
      soru: json['soru'] as String,
      secenekler: Map<String, String>.from(json['secenekler'] as Map),
      dogruCevap: json['dogru_cevap'] as String,
      ozet: json['ozet'] as String,
    );

Map<String, dynamic> _$$ApiQuestionImplToJson(_$ApiQuestionImpl instance) =>
    <String, dynamic>{
      'soru_no': instance.soruNo,
      'soru': instance.soru,
      'secenekler': instance.secenekler,
      'dogru_cevap': instance.dogruCevap,
      'ozet': instance.ozet,
    };
