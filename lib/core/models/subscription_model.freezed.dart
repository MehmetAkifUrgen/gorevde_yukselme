// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subscription_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SubscriptionModel _$SubscriptionModelFromJson(Map<String, dynamic> json) {
  return _SubscriptionModel.fromJson(json);
}

/// @nodoc
mixin _$SubscriptionModel {
  String get id => throw _privateConstructorUsedError;
  SubscriptionPlan get plan => throw _privateConstructorUsedError;
  StoreType get store => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  DateTime? get expiryDate => throw _privateConstructorUsedError;
  List<PremiumFeature> get features => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  String get productId => throw _privateConstructorUsedError;
  String? get originalTransactionId => throw _privateConstructorUsedError;
  String? get purchaseToken => throw _privateConstructorUsedError;
  DateTime? get purchaseDate => throw _privateConstructorUsedError;
  bool? get autoRenewing => throw _privateConstructorUsedError;

  /// Serializes this SubscriptionModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SubscriptionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubscriptionModelCopyWith<SubscriptionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubscriptionModelCopyWith<$Res> {
  factory $SubscriptionModelCopyWith(
    SubscriptionModel value,
    $Res Function(SubscriptionModel) then,
  ) = _$SubscriptionModelCopyWithImpl<$Res, SubscriptionModel>;
  @useResult
  $Res call({
    String id,
    SubscriptionPlan plan,
    StoreType store,
    bool isActive,
    DateTime? expiryDate,
    List<PremiumFeature> features,
    double price,
    String currency,
    String productId,
    String? originalTransactionId,
    String? purchaseToken,
    DateTime? purchaseDate,
    bool? autoRenewing,
  });
}

/// @nodoc
class _$SubscriptionModelCopyWithImpl<$Res, $Val extends SubscriptionModel>
    implements $SubscriptionModelCopyWith<$Res> {
  _$SubscriptionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubscriptionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? plan = null,
    Object? store = null,
    Object? isActive = null,
    Object? expiryDate = freezed,
    Object? features = null,
    Object? price = null,
    Object? currency = null,
    Object? productId = null,
    Object? originalTransactionId = freezed,
    Object? purchaseToken = freezed,
    Object? purchaseDate = freezed,
    Object? autoRenewing = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            plan: null == plan
                ? _value.plan
                : plan // ignore: cast_nullable_to_non_nullable
                      as SubscriptionPlan,
            store: null == store
                ? _value.store
                : store // ignore: cast_nullable_to_non_nullable
                      as StoreType,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            expiryDate: freezed == expiryDate
                ? _value.expiryDate
                : expiryDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            features: null == features
                ? _value.features
                : features // ignore: cast_nullable_to_non_nullable
                      as List<PremiumFeature>,
            price: null == price
                ? _value.price
                : price // ignore: cast_nullable_to_non_nullable
                      as double,
            currency: null == currency
                ? _value.currency
                : currency // ignore: cast_nullable_to_non_nullable
                      as String,
            productId: null == productId
                ? _value.productId
                : productId // ignore: cast_nullable_to_non_nullable
                      as String,
            originalTransactionId: freezed == originalTransactionId
                ? _value.originalTransactionId
                : originalTransactionId // ignore: cast_nullable_to_non_nullable
                      as String?,
            purchaseToken: freezed == purchaseToken
                ? _value.purchaseToken
                : purchaseToken // ignore: cast_nullable_to_non_nullable
                      as String?,
            purchaseDate: freezed == purchaseDate
                ? _value.purchaseDate
                : purchaseDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            autoRenewing: freezed == autoRenewing
                ? _value.autoRenewing
                : autoRenewing // ignore: cast_nullable_to_non_nullable
                      as bool?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SubscriptionModelImplCopyWith<$Res>
    implements $SubscriptionModelCopyWith<$Res> {
  factory _$$SubscriptionModelImplCopyWith(
    _$SubscriptionModelImpl value,
    $Res Function(_$SubscriptionModelImpl) then,
  ) = __$$SubscriptionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    SubscriptionPlan plan,
    StoreType store,
    bool isActive,
    DateTime? expiryDate,
    List<PremiumFeature> features,
    double price,
    String currency,
    String productId,
    String? originalTransactionId,
    String? purchaseToken,
    DateTime? purchaseDate,
    bool? autoRenewing,
  });
}

/// @nodoc
class __$$SubscriptionModelImplCopyWithImpl<$Res>
    extends _$SubscriptionModelCopyWithImpl<$Res, _$SubscriptionModelImpl>
    implements _$$SubscriptionModelImplCopyWith<$Res> {
  __$$SubscriptionModelImplCopyWithImpl(
    _$SubscriptionModelImpl _value,
    $Res Function(_$SubscriptionModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SubscriptionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? plan = null,
    Object? store = null,
    Object? isActive = null,
    Object? expiryDate = freezed,
    Object? features = null,
    Object? price = null,
    Object? currency = null,
    Object? productId = null,
    Object? originalTransactionId = freezed,
    Object? purchaseToken = freezed,
    Object? purchaseDate = freezed,
    Object? autoRenewing = freezed,
  }) {
    return _then(
      _$SubscriptionModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        plan: null == plan
            ? _value.plan
            : plan // ignore: cast_nullable_to_non_nullable
                  as SubscriptionPlan,
        store: null == store
            ? _value.store
            : store // ignore: cast_nullable_to_non_nullable
                  as StoreType,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        expiryDate: freezed == expiryDate
            ? _value.expiryDate
            : expiryDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        features: null == features
            ? _value._features
            : features // ignore: cast_nullable_to_non_nullable
                  as List<PremiumFeature>,
        price: null == price
            ? _value.price
            : price // ignore: cast_nullable_to_non_nullable
                  as double,
        currency: null == currency
            ? _value.currency
            : currency // ignore: cast_nullable_to_non_nullable
                  as String,
        productId: null == productId
            ? _value.productId
            : productId // ignore: cast_nullable_to_non_nullable
                  as String,
        originalTransactionId: freezed == originalTransactionId
            ? _value.originalTransactionId
            : originalTransactionId // ignore: cast_nullable_to_non_nullable
                  as String?,
        purchaseToken: freezed == purchaseToken
            ? _value.purchaseToken
            : purchaseToken // ignore: cast_nullable_to_non_nullable
                  as String?,
        purchaseDate: freezed == purchaseDate
            ? _value.purchaseDate
            : purchaseDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        autoRenewing: freezed == autoRenewing
            ? _value.autoRenewing
            : autoRenewing // ignore: cast_nullable_to_non_nullable
                  as bool?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SubscriptionModelImpl implements _SubscriptionModel {
  const _$SubscriptionModelImpl({
    required this.id,
    required this.plan,
    required this.store,
    required this.isActive,
    required this.expiryDate,
    required final List<PremiumFeature> features,
    required this.price,
    required this.currency,
    required this.productId,
    this.originalTransactionId,
    this.purchaseToken,
    this.purchaseDate,
    this.autoRenewing,
  }) : _features = features;

  factory _$SubscriptionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubscriptionModelImplFromJson(json);

  @override
  final String id;
  @override
  final SubscriptionPlan plan;
  @override
  final StoreType store;
  @override
  final bool isActive;
  @override
  final DateTime? expiryDate;
  final List<PremiumFeature> _features;
  @override
  List<PremiumFeature> get features {
    if (_features is EqualUnmodifiableListView) return _features;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_features);
  }

  @override
  final double price;
  @override
  final String currency;
  @override
  final String productId;
  @override
  final String? originalTransactionId;
  @override
  final String? purchaseToken;
  @override
  final DateTime? purchaseDate;
  @override
  final bool? autoRenewing;

  @override
  String toString() {
    return 'SubscriptionModel(id: $id, plan: $plan, store: $store, isActive: $isActive, expiryDate: $expiryDate, features: $features, price: $price, currency: $currency, productId: $productId, originalTransactionId: $originalTransactionId, purchaseToken: $purchaseToken, purchaseDate: $purchaseDate, autoRenewing: $autoRenewing)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubscriptionModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.plan, plan) || other.plan == plan) &&
            (identical(other.store, store) || other.store == store) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.expiryDate, expiryDate) ||
                other.expiryDate == expiryDate) &&
            const DeepCollectionEquality().equals(other._features, _features) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.originalTransactionId, originalTransactionId) ||
                other.originalTransactionId == originalTransactionId) &&
            (identical(other.purchaseToken, purchaseToken) ||
                other.purchaseToken == purchaseToken) &&
            (identical(other.purchaseDate, purchaseDate) ||
                other.purchaseDate == purchaseDate) &&
            (identical(other.autoRenewing, autoRenewing) ||
                other.autoRenewing == autoRenewing));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    plan,
    store,
    isActive,
    expiryDate,
    const DeepCollectionEquality().hash(_features),
    price,
    currency,
    productId,
    originalTransactionId,
    purchaseToken,
    purchaseDate,
    autoRenewing,
  );

  /// Create a copy of SubscriptionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubscriptionModelImplCopyWith<_$SubscriptionModelImpl> get copyWith =>
      __$$SubscriptionModelImplCopyWithImpl<_$SubscriptionModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SubscriptionModelImplToJson(this);
  }
}

abstract class _SubscriptionModel implements SubscriptionModel {
  const factory _SubscriptionModel({
    required final String id,
    required final SubscriptionPlan plan,
    required final StoreType store,
    required final bool isActive,
    required final DateTime? expiryDate,
    required final List<PremiumFeature> features,
    required final double price,
    required final String currency,
    required final String productId,
    final String? originalTransactionId,
    final String? purchaseToken,
    final DateTime? purchaseDate,
    final bool? autoRenewing,
  }) = _$SubscriptionModelImpl;

  factory _SubscriptionModel.fromJson(Map<String, dynamic> json) =
      _$SubscriptionModelImpl.fromJson;

  @override
  String get id;
  @override
  SubscriptionPlan get plan;
  @override
  StoreType get store;
  @override
  bool get isActive;
  @override
  DateTime? get expiryDate;
  @override
  List<PremiumFeature> get features;
  @override
  double get price;
  @override
  String get currency;
  @override
  String get productId;
  @override
  String? get originalTransactionId;
  @override
  String? get purchaseToken;
  @override
  DateTime? get purchaseDate;
  @override
  bool? get autoRenewing;

  /// Create a copy of SubscriptionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubscriptionModelImplCopyWith<_$SubscriptionModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ProductModel _$ProductModelFromJson(Map<String, dynamic> json) {
  return _ProductModel.fromJson(json);
}

/// @nodoc
mixin _$ProductModel {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  String get priceString => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  SubscriptionPlan get plan => throw _privateConstructorUsedError;
  StoreType get store => throw _privateConstructorUsedError;
  List<PremiumFeature> get features => throw _privateConstructorUsedError;
  String? get introductoryPrice => throw _privateConstructorUsedError;
  String? get introductoryPriceString => throw _privateConstructorUsedError;
  int? get introductoryPricePeriod => throw _privateConstructorUsedError;
  String? get subscriptionPeriod => throw _privateConstructorUsedError;

  /// Serializes this ProductModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProductModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductModelCopyWith<ProductModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductModelCopyWith<$Res> {
  factory $ProductModelCopyWith(
    ProductModel value,
    $Res Function(ProductModel) then,
  ) = _$ProductModelCopyWithImpl<$Res, ProductModel>;
  @useResult
  $Res call({
    String id,
    String title,
    String description,
    double price,
    String priceString,
    String currency,
    SubscriptionPlan plan,
    StoreType store,
    List<PremiumFeature> features,
    String? introductoryPrice,
    String? introductoryPriceString,
    int? introductoryPricePeriod,
    String? subscriptionPeriod,
  });
}

/// @nodoc
class _$ProductModelCopyWithImpl<$Res, $Val extends ProductModel>
    implements $ProductModelCopyWith<$Res> {
  _$ProductModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? price = null,
    Object? priceString = null,
    Object? currency = null,
    Object? plan = null,
    Object? store = null,
    Object? features = null,
    Object? introductoryPrice = freezed,
    Object? introductoryPriceString = freezed,
    Object? introductoryPricePeriod = freezed,
    Object? subscriptionPeriod = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            price: null == price
                ? _value.price
                : price // ignore: cast_nullable_to_non_nullable
                      as double,
            priceString: null == priceString
                ? _value.priceString
                : priceString // ignore: cast_nullable_to_non_nullable
                      as String,
            currency: null == currency
                ? _value.currency
                : currency // ignore: cast_nullable_to_non_nullable
                      as String,
            plan: null == plan
                ? _value.plan
                : plan // ignore: cast_nullable_to_non_nullable
                      as SubscriptionPlan,
            store: null == store
                ? _value.store
                : store // ignore: cast_nullable_to_non_nullable
                      as StoreType,
            features: null == features
                ? _value.features
                : features // ignore: cast_nullable_to_non_nullable
                      as List<PremiumFeature>,
            introductoryPrice: freezed == introductoryPrice
                ? _value.introductoryPrice
                : introductoryPrice // ignore: cast_nullable_to_non_nullable
                      as String?,
            introductoryPriceString: freezed == introductoryPriceString
                ? _value.introductoryPriceString
                : introductoryPriceString // ignore: cast_nullable_to_non_nullable
                      as String?,
            introductoryPricePeriod: freezed == introductoryPricePeriod
                ? _value.introductoryPricePeriod
                : introductoryPricePeriod // ignore: cast_nullable_to_non_nullable
                      as int?,
            subscriptionPeriod: freezed == subscriptionPeriod
                ? _value.subscriptionPeriod
                : subscriptionPeriod // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProductModelImplCopyWith<$Res>
    implements $ProductModelCopyWith<$Res> {
  factory _$$ProductModelImplCopyWith(
    _$ProductModelImpl value,
    $Res Function(_$ProductModelImpl) then,
  ) = __$$ProductModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String description,
    double price,
    String priceString,
    String currency,
    SubscriptionPlan plan,
    StoreType store,
    List<PremiumFeature> features,
    String? introductoryPrice,
    String? introductoryPriceString,
    int? introductoryPricePeriod,
    String? subscriptionPeriod,
  });
}

/// @nodoc
class __$$ProductModelImplCopyWithImpl<$Res>
    extends _$ProductModelCopyWithImpl<$Res, _$ProductModelImpl>
    implements _$$ProductModelImplCopyWith<$Res> {
  __$$ProductModelImplCopyWithImpl(
    _$ProductModelImpl _value,
    $Res Function(_$ProductModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProductModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? price = null,
    Object? priceString = null,
    Object? currency = null,
    Object? plan = null,
    Object? store = null,
    Object? features = null,
    Object? introductoryPrice = freezed,
    Object? introductoryPriceString = freezed,
    Object? introductoryPricePeriod = freezed,
    Object? subscriptionPeriod = freezed,
  }) {
    return _then(
      _$ProductModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        price: null == price
            ? _value.price
            : price // ignore: cast_nullable_to_non_nullable
                  as double,
        priceString: null == priceString
            ? _value.priceString
            : priceString // ignore: cast_nullable_to_non_nullable
                  as String,
        currency: null == currency
            ? _value.currency
            : currency // ignore: cast_nullable_to_non_nullable
                  as String,
        plan: null == plan
            ? _value.plan
            : plan // ignore: cast_nullable_to_non_nullable
                  as SubscriptionPlan,
        store: null == store
            ? _value.store
            : store // ignore: cast_nullable_to_non_nullable
                  as StoreType,
        features: null == features
            ? _value._features
            : features // ignore: cast_nullable_to_non_nullable
                  as List<PremiumFeature>,
        introductoryPrice: freezed == introductoryPrice
            ? _value.introductoryPrice
            : introductoryPrice // ignore: cast_nullable_to_non_nullable
                  as String?,
        introductoryPriceString: freezed == introductoryPriceString
            ? _value.introductoryPriceString
            : introductoryPriceString // ignore: cast_nullable_to_non_nullable
                  as String?,
        introductoryPricePeriod: freezed == introductoryPricePeriod
            ? _value.introductoryPricePeriod
            : introductoryPricePeriod // ignore: cast_nullable_to_non_nullable
                  as int?,
        subscriptionPeriod: freezed == subscriptionPeriod
            ? _value.subscriptionPeriod
            : subscriptionPeriod // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProductModelImpl implements _ProductModel {
  const _$ProductModelImpl({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.priceString,
    required this.currency,
    required this.plan,
    required this.store,
    required final List<PremiumFeature> features,
    this.introductoryPrice,
    this.introductoryPriceString,
    this.introductoryPricePeriod,
    this.subscriptionPeriod,
  }) : _features = features;

  factory _$ProductModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductModelImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final double price;
  @override
  final String priceString;
  @override
  final String currency;
  @override
  final SubscriptionPlan plan;
  @override
  final StoreType store;
  final List<PremiumFeature> _features;
  @override
  List<PremiumFeature> get features {
    if (_features is EqualUnmodifiableListView) return _features;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_features);
  }

  @override
  final String? introductoryPrice;
  @override
  final String? introductoryPriceString;
  @override
  final int? introductoryPricePeriod;
  @override
  final String? subscriptionPeriod;

  @override
  String toString() {
    return 'ProductModel(id: $id, title: $title, description: $description, price: $price, priceString: $priceString, currency: $currency, plan: $plan, store: $store, features: $features, introductoryPrice: $introductoryPrice, introductoryPriceString: $introductoryPriceString, introductoryPricePeriod: $introductoryPricePeriod, subscriptionPeriod: $subscriptionPeriod)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.priceString, priceString) ||
                other.priceString == priceString) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.plan, plan) || other.plan == plan) &&
            (identical(other.store, store) || other.store == store) &&
            const DeepCollectionEquality().equals(other._features, _features) &&
            (identical(other.introductoryPrice, introductoryPrice) ||
                other.introductoryPrice == introductoryPrice) &&
            (identical(
                  other.introductoryPriceString,
                  introductoryPriceString,
                ) ||
                other.introductoryPriceString == introductoryPriceString) &&
            (identical(
                  other.introductoryPricePeriod,
                  introductoryPricePeriod,
                ) ||
                other.introductoryPricePeriod == introductoryPricePeriod) &&
            (identical(other.subscriptionPeriod, subscriptionPeriod) ||
                other.subscriptionPeriod == subscriptionPeriod));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    description,
    price,
    priceString,
    currency,
    plan,
    store,
    const DeepCollectionEquality().hash(_features),
    introductoryPrice,
    introductoryPriceString,
    introductoryPricePeriod,
    subscriptionPeriod,
  );

  /// Create a copy of ProductModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductModelImplCopyWith<_$ProductModelImpl> get copyWith =>
      __$$ProductModelImplCopyWithImpl<_$ProductModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductModelImplToJson(this);
  }
}

abstract class _ProductModel implements ProductModel {
  const factory _ProductModel({
    required final String id,
    required final String title,
    required final String description,
    required final double price,
    required final String priceString,
    required final String currency,
    required final SubscriptionPlan plan,
    required final StoreType store,
    required final List<PremiumFeature> features,
    final String? introductoryPrice,
    final String? introductoryPriceString,
    final int? introductoryPricePeriod,
    final String? subscriptionPeriod,
  }) = _$ProductModelImpl;

  factory _ProductModel.fromJson(Map<String, dynamic> json) =
      _$ProductModelImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  double get price;
  @override
  String get priceString;
  @override
  String get currency;
  @override
  SubscriptionPlan get plan;
  @override
  StoreType get store;
  @override
  List<PremiumFeature> get features;
  @override
  String? get introductoryPrice;
  @override
  String? get introductoryPriceString;
  @override
  int? get introductoryPricePeriod;
  @override
  String? get subscriptionPeriod;

  /// Create a copy of ProductModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductModelImplCopyWith<_$ProductModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PurchaseResult _$PurchaseResultFromJson(Map<String, dynamic> json) {
  return _PurchaseResult.fromJson(json);
}

/// @nodoc
mixin _$PurchaseResult {
  PurchaseStatus get status => throw _privateConstructorUsedError;
  String? get productId => throw _privateConstructorUsedError;
  String? get transactionId => throw _privateConstructorUsedError;
  String? get purchaseToken => throw _privateConstructorUsedError;
  DateTime? get purchaseDate => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  SubscriptionModel? get subscription => throw _privateConstructorUsedError;

  /// Serializes this PurchaseResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PurchaseResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PurchaseResultCopyWith<PurchaseResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PurchaseResultCopyWith<$Res> {
  factory $PurchaseResultCopyWith(
    PurchaseResult value,
    $Res Function(PurchaseResult) then,
  ) = _$PurchaseResultCopyWithImpl<$Res, PurchaseResult>;
  @useResult
  $Res call({
    PurchaseStatus status,
    String? productId,
    String? transactionId,
    String? purchaseToken,
    DateTime? purchaseDate,
    String? error,
    SubscriptionModel? subscription,
  });

  $SubscriptionModelCopyWith<$Res>? get subscription;
}

/// @nodoc
class _$PurchaseResultCopyWithImpl<$Res, $Val extends PurchaseResult>
    implements $PurchaseResultCopyWith<$Res> {
  _$PurchaseResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PurchaseResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? productId = freezed,
    Object? transactionId = freezed,
    Object? purchaseToken = freezed,
    Object? purchaseDate = freezed,
    Object? error = freezed,
    Object? subscription = freezed,
  }) {
    return _then(
      _value.copyWith(
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as PurchaseStatus,
            productId: freezed == productId
                ? _value.productId
                : productId // ignore: cast_nullable_to_non_nullable
                      as String?,
            transactionId: freezed == transactionId
                ? _value.transactionId
                : transactionId // ignore: cast_nullable_to_non_nullable
                      as String?,
            purchaseToken: freezed == purchaseToken
                ? _value.purchaseToken
                : purchaseToken // ignore: cast_nullable_to_non_nullable
                      as String?,
            purchaseDate: freezed == purchaseDate
                ? _value.purchaseDate
                : purchaseDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
            subscription: freezed == subscription
                ? _value.subscription
                : subscription // ignore: cast_nullable_to_non_nullable
                      as SubscriptionModel?,
          )
          as $Val,
    );
  }

  /// Create a copy of PurchaseResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SubscriptionModelCopyWith<$Res>? get subscription {
    if (_value.subscription == null) {
      return null;
    }

    return $SubscriptionModelCopyWith<$Res>(_value.subscription!, (value) {
      return _then(_value.copyWith(subscription: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PurchaseResultImplCopyWith<$Res>
    implements $PurchaseResultCopyWith<$Res> {
  factory _$$PurchaseResultImplCopyWith(
    _$PurchaseResultImpl value,
    $Res Function(_$PurchaseResultImpl) then,
  ) = __$$PurchaseResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    PurchaseStatus status,
    String? productId,
    String? transactionId,
    String? purchaseToken,
    DateTime? purchaseDate,
    String? error,
    SubscriptionModel? subscription,
  });

  @override
  $SubscriptionModelCopyWith<$Res>? get subscription;
}

/// @nodoc
class __$$PurchaseResultImplCopyWithImpl<$Res>
    extends _$PurchaseResultCopyWithImpl<$Res, _$PurchaseResultImpl>
    implements _$$PurchaseResultImplCopyWith<$Res> {
  __$$PurchaseResultImplCopyWithImpl(
    _$PurchaseResultImpl _value,
    $Res Function(_$PurchaseResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PurchaseResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? productId = freezed,
    Object? transactionId = freezed,
    Object? purchaseToken = freezed,
    Object? purchaseDate = freezed,
    Object? error = freezed,
    Object? subscription = freezed,
  }) {
    return _then(
      _$PurchaseResultImpl(
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as PurchaseStatus,
        productId: freezed == productId
            ? _value.productId
            : productId // ignore: cast_nullable_to_non_nullable
                  as String?,
        transactionId: freezed == transactionId
            ? _value.transactionId
            : transactionId // ignore: cast_nullable_to_non_nullable
                  as String?,
        purchaseToken: freezed == purchaseToken
            ? _value.purchaseToken
            : purchaseToken // ignore: cast_nullable_to_non_nullable
                  as String?,
        purchaseDate: freezed == purchaseDate
            ? _value.purchaseDate
            : purchaseDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
        subscription: freezed == subscription
            ? _value.subscription
            : subscription // ignore: cast_nullable_to_non_nullable
                  as SubscriptionModel?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PurchaseResultImpl implements _PurchaseResult {
  const _$PurchaseResultImpl({
    required this.status,
    required this.productId,
    required this.transactionId,
    required this.purchaseToken,
    required this.purchaseDate,
    this.error,
    this.subscription,
  });

  factory _$PurchaseResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$PurchaseResultImplFromJson(json);

  @override
  final PurchaseStatus status;
  @override
  final String? productId;
  @override
  final String? transactionId;
  @override
  final String? purchaseToken;
  @override
  final DateTime? purchaseDate;
  @override
  final String? error;
  @override
  final SubscriptionModel? subscription;

  @override
  String toString() {
    return 'PurchaseResult(status: $status, productId: $productId, transactionId: $transactionId, purchaseToken: $purchaseToken, purchaseDate: $purchaseDate, error: $error, subscription: $subscription)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PurchaseResultImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.transactionId, transactionId) ||
                other.transactionId == transactionId) &&
            (identical(other.purchaseToken, purchaseToken) ||
                other.purchaseToken == purchaseToken) &&
            (identical(other.purchaseDate, purchaseDate) ||
                other.purchaseDate == purchaseDate) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.subscription, subscription) ||
                other.subscription == subscription));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    status,
    productId,
    transactionId,
    purchaseToken,
    purchaseDate,
    error,
    subscription,
  );

  /// Create a copy of PurchaseResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PurchaseResultImplCopyWith<_$PurchaseResultImpl> get copyWith =>
      __$$PurchaseResultImplCopyWithImpl<_$PurchaseResultImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PurchaseResultImplToJson(this);
  }
}

abstract class _PurchaseResult implements PurchaseResult {
  const factory _PurchaseResult({
    required final PurchaseStatus status,
    required final String? productId,
    required final String? transactionId,
    required final String? purchaseToken,
    required final DateTime? purchaseDate,
    final String? error,
    final SubscriptionModel? subscription,
  }) = _$PurchaseResultImpl;

  factory _PurchaseResult.fromJson(Map<String, dynamic> json) =
      _$PurchaseResultImpl.fromJson;

  @override
  PurchaseStatus get status;
  @override
  String? get productId;
  @override
  String? get transactionId;
  @override
  String? get purchaseToken;
  @override
  DateTime? get purchaseDate;
  @override
  String? get error;
  @override
  SubscriptionModel? get subscription;

  /// Create a copy of PurchaseResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PurchaseResultImplCopyWith<_$PurchaseResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
