// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'api_question_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ApiQuestionsResponse {
  Map<String, Map<String, Map<String, Map<String, List<ApiQuestion>>>>>
  get cikmisSorular => throw _privateConstructorUsedError;
  Map<String, Map<String, Map<String, Map<String, List<ApiQuestion>>>>>
  get miniSorular => throw _privateConstructorUsedError;

  /// Create a copy of ApiQuestionsResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ApiQuestionsResponseCopyWith<ApiQuestionsResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ApiQuestionsResponseCopyWith<$Res> {
  factory $ApiQuestionsResponseCopyWith(
    ApiQuestionsResponse value,
    $Res Function(ApiQuestionsResponse) then,
  ) = _$ApiQuestionsResponseCopyWithImpl<$Res, ApiQuestionsResponse>;
  @useResult
  $Res call({
    Map<String, Map<String, Map<String, Map<String, List<ApiQuestion>>>>>
    cikmisSorular,
    Map<String, Map<String, Map<String, Map<String, List<ApiQuestion>>>>>
    miniSorular,
  });
}

/// @nodoc
class _$ApiQuestionsResponseCopyWithImpl<
  $Res,
  $Val extends ApiQuestionsResponse
>
    implements $ApiQuestionsResponseCopyWith<$Res> {
  _$ApiQuestionsResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ApiQuestionsResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? cikmisSorular = null, Object? miniSorular = null}) {
    return _then(
      _value.copyWith(
            cikmisSorular: null == cikmisSorular
                ? _value.cikmisSorular
                : cikmisSorular // ignore: cast_nullable_to_non_nullable
                      as Map<
                        String,
                        Map<String, Map<String, Map<String, List<ApiQuestion>>>>
                      >,
            miniSorular: null == miniSorular
                ? _value.miniSorular
                : miniSorular // ignore: cast_nullable_to_non_nullable
                      as Map<
                        String,
                        Map<String, Map<String, Map<String, List<ApiQuestion>>>>
                      >,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ApiQuestionsResponseImplCopyWith<$Res>
    implements $ApiQuestionsResponseCopyWith<$Res> {
  factory _$$ApiQuestionsResponseImplCopyWith(
    _$ApiQuestionsResponseImpl value,
    $Res Function(_$ApiQuestionsResponseImpl) then,
  ) = __$$ApiQuestionsResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Map<String, Map<String, Map<String, Map<String, List<ApiQuestion>>>>>
    cikmisSorular,
    Map<String, Map<String, Map<String, Map<String, List<ApiQuestion>>>>>
    miniSorular,
  });
}

/// @nodoc
class __$$ApiQuestionsResponseImplCopyWithImpl<$Res>
    extends _$ApiQuestionsResponseCopyWithImpl<$Res, _$ApiQuestionsResponseImpl>
    implements _$$ApiQuestionsResponseImplCopyWith<$Res> {
  __$$ApiQuestionsResponseImplCopyWithImpl(
    _$ApiQuestionsResponseImpl _value,
    $Res Function(_$ApiQuestionsResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ApiQuestionsResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? cikmisSorular = null, Object? miniSorular = null}) {
    return _then(
      _$ApiQuestionsResponseImpl(
        cikmisSorular: null == cikmisSorular
            ? _value._cikmisSorular
            : cikmisSorular // ignore: cast_nullable_to_non_nullable
                  as Map<
                    String,
                    Map<String, Map<String, Map<String, List<ApiQuestion>>>>
                  >,
        miniSorular: null == miniSorular
            ? _value._miniSorular
            : miniSorular // ignore: cast_nullable_to_non_nullable
                  as Map<
                    String,
                    Map<String, Map<String, Map<String, List<ApiQuestion>>>>
                  >,
      ),
    );
  }
}

/// @nodoc

class _$ApiQuestionsResponseImpl implements _ApiQuestionsResponse {
  const _$ApiQuestionsResponseImpl({
    required final Map<
      String,
      Map<String, Map<String, Map<String, List<ApiQuestion>>>>
    >
    cikmisSorular,
    final Map<String, Map<String, Map<String, Map<String, List<ApiQuestion>>>>>
        miniSorular =
        const {},
  }) : _cikmisSorular = cikmisSorular,
       _miniSorular = miniSorular;

  final Map<String, Map<String, Map<String, Map<String, List<ApiQuestion>>>>>
  _cikmisSorular;
  @override
  Map<String, Map<String, Map<String, Map<String, List<ApiQuestion>>>>>
  get cikmisSorular {
    if (_cikmisSorular is EqualUnmodifiableMapView) return _cikmisSorular;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_cikmisSorular);
  }

  final Map<String, Map<String, Map<String, Map<String, List<ApiQuestion>>>>>
  _miniSorular;
  @override
  @JsonKey()
  Map<String, Map<String, Map<String, Map<String, List<ApiQuestion>>>>>
  get miniSorular {
    if (_miniSorular is EqualUnmodifiableMapView) return _miniSorular;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_miniSorular);
  }

  @override
  String toString() {
    return 'ApiQuestionsResponse(cikmisSorular: $cikmisSorular, miniSorular: $miniSorular)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ApiQuestionsResponseImpl &&
            const DeepCollectionEquality().equals(
              other._cikmisSorular,
              _cikmisSorular,
            ) &&
            const DeepCollectionEquality().equals(
              other._miniSorular,
              _miniSorular,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_cikmisSorular),
    const DeepCollectionEquality().hash(_miniSorular),
  );

  /// Create a copy of ApiQuestionsResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ApiQuestionsResponseImplCopyWith<_$ApiQuestionsResponseImpl>
  get copyWith =>
      __$$ApiQuestionsResponseImplCopyWithImpl<_$ApiQuestionsResponseImpl>(
        this,
        _$identity,
      );
      
        @override
        Map<String, dynamic> toJson() {
          // TODO: implement toJson
          throw UnimplementedError();
        }
}

abstract class _ApiQuestionsResponse implements ApiQuestionsResponse {
  const factory _ApiQuestionsResponse({
    required final Map<
      String,
      Map<String, Map<String, Map<String, List<ApiQuestion>>>>
    >
    cikmisSorular,
    final Map<String, Map<String, Map<String, Map<String, List<ApiQuestion>>>>>
    miniSorular,
  }) = _$ApiQuestionsResponseImpl;

  @override
  Map<String, Map<String, Map<String, Map<String, List<ApiQuestion>>>>>
  get cikmisSorular;
  @override
  Map<String, Map<String, Map<String, Map<String, List<ApiQuestion>>>>>
  get miniSorular;

  /// Create a copy of ApiQuestionsResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ApiQuestionsResponseImplCopyWith<_$ApiQuestionsResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ApiQuestion _$ApiQuestionFromJson(Map<String, dynamic> json) {
  return _ApiQuestion.fromJson(json);
}

/// @nodoc
mixin _$ApiQuestion {
  @JsonKey(name: 'soru_no')
  int get soruNo => throw _privateConstructorUsedError;
  @JsonKey(name: 'soru')
  String get soru => throw _privateConstructorUsedError;
  @JsonKey(name: 'secenekler')
  Map<String, String> get secenekler => throw _privateConstructorUsedError;
  @JsonKey(name: 'dogru_cevap')
  String get dogruCevap => throw _privateConstructorUsedError;
  @JsonKey(name: 'ozet')
  String get ozet => throw _privateConstructorUsedError;

  /// Serializes this ApiQuestion to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ApiQuestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ApiQuestionCopyWith<ApiQuestion> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ApiQuestionCopyWith<$Res> {
  factory $ApiQuestionCopyWith(
    ApiQuestion value,
    $Res Function(ApiQuestion) then,
  ) = _$ApiQuestionCopyWithImpl<$Res, ApiQuestion>;
  @useResult
  $Res call({
    @JsonKey(name: 'soru_no') int soruNo,
    @JsonKey(name: 'soru') String soru,
    @JsonKey(name: 'secenekler') Map<String, String> secenekler,
    @JsonKey(name: 'dogru_cevap') String dogruCevap,
    @JsonKey(name: 'ozet') String ozet,
  });
}

/// @nodoc
class _$ApiQuestionCopyWithImpl<$Res, $Val extends ApiQuestion>
    implements $ApiQuestionCopyWith<$Res> {
  _$ApiQuestionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ApiQuestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? soruNo = null,
    Object? soru = null,
    Object? secenekler = null,
    Object? dogruCevap = null,
    Object? ozet = null,
  }) {
    return _then(
      _value.copyWith(
            soruNo: null == soruNo
                ? _value.soruNo
                : soruNo // ignore: cast_nullable_to_non_nullable
                      as int,
            soru: null == soru
                ? _value.soru
                : soru // ignore: cast_nullable_to_non_nullable
                      as String,
            secenekler: null == secenekler
                ? _value.secenekler
                : secenekler // ignore: cast_nullable_to_non_nullable
                      as Map<String, String>,
            dogruCevap: null == dogruCevap
                ? _value.dogruCevap
                : dogruCevap // ignore: cast_nullable_to_non_nullable
                      as String,
            ozet: null == ozet
                ? _value.ozet
                : ozet // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ApiQuestionImplCopyWith<$Res>
    implements $ApiQuestionCopyWith<$Res> {
  factory _$$ApiQuestionImplCopyWith(
    _$ApiQuestionImpl value,
    $Res Function(_$ApiQuestionImpl) then,
  ) = __$$ApiQuestionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'soru_no') int soruNo,
    @JsonKey(name: 'soru') String soru,
    @JsonKey(name: 'secenekler') Map<String, String> secenekler,
    @JsonKey(name: 'dogru_cevap') String dogruCevap,
    @JsonKey(name: 'ozet') String ozet,
  });
}

/// @nodoc
class __$$ApiQuestionImplCopyWithImpl<$Res>
    extends _$ApiQuestionCopyWithImpl<$Res, _$ApiQuestionImpl>
    implements _$$ApiQuestionImplCopyWith<$Res> {
  __$$ApiQuestionImplCopyWithImpl(
    _$ApiQuestionImpl _value,
    $Res Function(_$ApiQuestionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ApiQuestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? soruNo = null,
    Object? soru = null,
    Object? secenekler = null,
    Object? dogruCevap = null,
    Object? ozet = null,
  }) {
    return _then(
      _$ApiQuestionImpl(
        soruNo: null == soruNo
            ? _value.soruNo
            : soruNo // ignore: cast_nullable_to_non_nullable
                  as int,
        soru: null == soru
            ? _value.soru
            : soru // ignore: cast_nullable_to_non_nullable
                  as String,
        secenekler: null == secenekler
            ? _value._secenekler
            : secenekler // ignore: cast_nullable_to_non_nullable
                  as Map<String, String>,
        dogruCevap: null == dogruCevap
            ? _value.dogruCevap
            : dogruCevap // ignore: cast_nullable_to_non_nullable
                  as String,
        ozet: null == ozet
            ? _value.ozet
            : ozet // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ApiQuestionImpl implements _ApiQuestion {
  const _$ApiQuestionImpl({
    @JsonKey(name: 'soru_no') required this.soruNo,
    @JsonKey(name: 'soru') required this.soru,
    @JsonKey(name: 'secenekler') required final Map<String, String> secenekler,
    @JsonKey(name: 'dogru_cevap') required this.dogruCevap,
    @JsonKey(name: 'ozet') required this.ozet,
  }) : _secenekler = secenekler;

  factory _$ApiQuestionImpl.fromJson(Map<String, dynamic> json) =>
      _$$ApiQuestionImplFromJson(json);

  @override
  @JsonKey(name: 'soru_no')
  final int soruNo;
  @override
  @JsonKey(name: 'soru')
  final String soru;
  final Map<String, String> _secenekler;
  @override
  @JsonKey(name: 'secenekler')
  Map<String, String> get secenekler {
    if (_secenekler is EqualUnmodifiableMapView) return _secenekler;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_secenekler);
  }

  @override
  @JsonKey(name: 'dogru_cevap')
  final String dogruCevap;
  @override
  @JsonKey(name: 'ozet')
  final String ozet;

  @override
  String toString() {
    return 'ApiQuestion(soruNo: $soruNo, soru: $soru, secenekler: $secenekler, dogruCevap: $dogruCevap, ozet: $ozet)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ApiQuestionImpl &&
            (identical(other.soruNo, soruNo) || other.soruNo == soruNo) &&
            (identical(other.soru, soru) || other.soru == soru) &&
            const DeepCollectionEquality().equals(
              other._secenekler,
              _secenekler,
            ) &&
            (identical(other.dogruCevap, dogruCevap) ||
                other.dogruCevap == dogruCevap) &&
            (identical(other.ozet, ozet) || other.ozet == ozet));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    soruNo,
    soru,
    const DeepCollectionEquality().hash(_secenekler),
    dogruCevap,
    ozet,
  );

  /// Create a copy of ApiQuestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ApiQuestionImplCopyWith<_$ApiQuestionImpl> get copyWith =>
      __$$ApiQuestionImplCopyWithImpl<_$ApiQuestionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ApiQuestionImplToJson(this);
  }
}

abstract class _ApiQuestion implements ApiQuestion {
  const factory _ApiQuestion({
    @JsonKey(name: 'soru_no') required final int soruNo,
    @JsonKey(name: 'soru') required final String soru,
    @JsonKey(name: 'secenekler') required final Map<String, String> secenekler,
    @JsonKey(name: 'dogru_cevap') required final String dogruCevap,
    @JsonKey(name: 'ozet') required final String ozet,
  }) = _$ApiQuestionImpl;

  factory _ApiQuestion.fromJson(Map<String, dynamic> json) =
      _$ApiQuestionImpl.fromJson;

  @override
  @JsonKey(name: 'soru_no')
  int get soruNo;
  @override
  @JsonKey(name: 'soru')
  String get soru;
  @override
  @JsonKey(name: 'secenekler')
  Map<String, String> get secenekler;
  @override
  @JsonKey(name: 'dogru_cevap')
  String get dogruCevap;
  @override
  @JsonKey(name: 'ozet')
  String get ozet;

  /// Create a copy of ApiQuestion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ApiQuestionImplCopyWith<_$ApiQuestionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
