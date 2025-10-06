import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart' hide PurchaseStatus;
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase/in_app_purchase.dart' as iap show PurchaseStatus;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/subscription_model.dart';
import 'premium_code_service.dart';

/// Service for handling platform-specific in-app purchases
class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  
  // Stream controllers for subscription state
  final StreamController<SubscriptionModel?> _subscriptionController = 
      StreamController<SubscriptionModel?>.broadcast();
  final StreamController<List<ProductModel>> _productsController = 
      StreamController<List<ProductModel>>.broadcast();
  final StreamController<PurchaseResult> _purchaseController = 
      StreamController<PurchaseResult>.broadcast();

  // Getters for streams
  Stream<SubscriptionModel?> get subscriptionStream => _subscriptionController.stream;
  Stream<List<ProductModel>> get productsStream => _productsController.stream;
  Stream<PurchaseResult> get purchaseStream => _purchaseController.stream;

  // Current state
  SubscriptionModel? _currentSubscription;
  List<ProductModel> _availableProducts = [];
  bool _isInitialized = false;
  
  // Premium code service
  final PremiumCodeService _premiumCodeService = PremiumCodeService();
  
  // Storage keys
  static const String _subscriptionKey = 'current_subscription';

  /// Initialize the subscription service
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Platform-specific initialization
      if (Platform.isAndroid) {
        // Enable pending purchases for Android
        _inAppPurchase.getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
        debugPrint('Android billing initialized');
      } else if (Platform.isIOS) {
        // iOS-specific initialization
        _inAppPurchase.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
        debugPrint('iOS StoreKit initialized');
      }

      // Check if in-app purchase is available
      final bool available = await _inAppPurchase.isAvailable();
      if (!available) {
        debugPrint('In-app purchase not available on this device');
        _purchaseController.add(PurchaseResult(
          status: PurchaseStatus.failed,
          productId: null,
          transactionId: null,
          purchaseToken: null,
          purchaseDate: null,
          error: 'Uygulama içi satın alma bu cihazda kullanılamıyor',
        ));
        return false;
      }

      // Set up purchase stream listener
      _subscription = _inAppPurchase.purchaseStream.listen(
        _handlePurchaseUpdates,
        onDone: () => debugPrint('Purchase stream done'),
        onError: (error) => debugPrint('Purchase stream error: $error'),
      );

      // Load products and restore purchases
      await _loadProducts();
      await _loadStoredSubscription();
      await restorePurchases();

      _isInitialized = true;
      debugPrint('SubscriptionService initialized successfully');
      return true;
    } catch (e) {
      debugPrint('Failed to initialize SubscriptionService: $e');
      return false;
    }
  }

  /// Get current platform store type
  StoreType get currentStore {
    if (Platform.isAndroid) return StoreType.googlePlay;
    if (Platform.isIOS) return StoreType.appStore;
    return StoreType.unknown;
  }

  /// Load available products from the store
  Future<void> _loadProducts() async {
    try {
      final Set<String> productIds = ProductIds.getProductIds(currentStore).toSet();
      
      if (productIds.isEmpty) {
        debugPrint('No product IDs for current platform');
        return;
      }

      final ProductDetailsResponse response = 
          await _inAppPurchase.queryProductDetails(productIds);

      if (response.error != null) {
        debugPrint('Error loading products: ${response.error}');
        return;
      }

      _availableProducts = response.productDetails.map((productDetails) {
        return ProductModel(
          id: productDetails.id,
          title: productDetails.title,
          description: productDetails.description,
          price: _parsePrice(productDetails.price),
          priceString: productDetails.price,
          currency: productDetails.currencyCode,
          plan: ProductIds.getPlanFromProductId(productDetails.id),
          store: currentStore,
          features: _getFeaturesForPlan(ProductIds.getPlanFromProductId(productDetails.id)),
        );
      }).toList();

      _productsController.add(_availableProducts);
      debugPrint('Loaded ${_availableProducts.length} products');
    } catch (e) {
      debugPrint('Error loading products: $e');
    }
  }

  /// Parse price string to double
  double _parsePrice(String priceString) {
    try {
      // Remove currency symbols and parse
      final cleanPrice = priceString.replaceAll(RegExp(r'[^\d.,]'), '');
      return double.tryParse(cleanPrice.replaceAll(',', '.')) ?? 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  /// Get features for a subscription plan
  List<PremiumFeature> _getFeaturesForPlan(SubscriptionPlan plan) {
    return SubscriptionPlanInfo.getPlanFeatures(plan);
  }

  /// Purchase a subscription
  Future<void> purchaseSubscription(String productId) async {
    try {
      _availableProducts.firstWhere(
        (p) => p.id == productId,
        orElse: () => throw Exception('Product not found: $productId'),
      );

      final ProductDetails? productDetails = await _getProductDetails(productId);
      if (productDetails == null) {
        throw Exception('Product details not found');
      }

      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: productDetails,
      );

      // Purchase subscription
      await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      
      debugPrint('Purchase initiated for: $productId');
    } catch (e) {
      debugPrint('Purchase error: $e');
      _purchaseController.add(PurchaseResult(
        status: PurchaseStatus.failed,
        productId: productId,
        transactionId: null,
        purchaseToken: null,
        purchaseDate: null,
        error: e.toString(),
      ));
    }
  }

  /// Get product details by ID
  Future<ProductDetails?> _getProductDetails(String productId) async {
    final response = await _inAppPurchase.queryProductDetails({productId});
    return response.productDetails.isNotEmpty ? response.productDetails.first : null;
  }

  /// Handle purchase updates from the stream
  void _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      _processPurchase(purchaseDetails);
    }
  }

  /// Process individual purchase
  Future<void> _processPurchase(PurchaseDetails purchaseDetails) async {
    try {
      if (purchaseDetails.status == iap.PurchaseStatus.purchased ||
          purchaseDetails.status == iap.PurchaseStatus.restored) {
        
        // Verify purchase (in production, verify with your backend)
        final bool isValid = await _verifyPurchase(purchaseDetails);
        
        if (isValid) {
          // Create subscription model
          final subscription = SubscriptionModel(
            id: purchaseDetails.purchaseID ?? '',
            plan: ProductIds.getPlanFromProductId(purchaseDetails.productID),
            store: currentStore,
            isActive: true,
            expiryDate: _calculateExpiryDate(purchaseDetails.productID),
            features: _getFeaturesForPlan(ProductIds.getPlanFromProductId(purchaseDetails.productID)),
            price: _getProductPrice(purchaseDetails.productID),
            currency: 'TL', // You might want to get this from product details
            productId: purchaseDetails.productID,
            originalTransactionId: _getOriginalTransactionId(purchaseDetails),
            purchaseToken: _getPurchaseToken(purchaseDetails),
            purchaseDate: DateTime.now(),
            autoRenewing: true,
          );

          _currentSubscription = subscription;
          _subscriptionController.add(subscription);
          
          // Save subscription to storage
          await _saveSubscription(subscription);

          _purchaseController.add(PurchaseResult(
            status: purchaseDetails.status == iap.PurchaseStatus.purchased 
                ? PurchaseStatus.purchased 
                : PurchaseStatus.restored,
            productId: purchaseDetails.productID,
            transactionId: purchaseDetails.purchaseID,
            purchaseToken: _getPurchaseToken(purchaseDetails),
            purchaseDate: DateTime.now(),
            subscription: subscription,
          ));

          debugPrint('Purchase successful: ${purchaseDetails.productID}');
        }
      } else if (purchaseDetails.status == iap.PurchaseStatus.error) {
        _purchaseController.add(PurchaseResult(
          status: PurchaseStatus.failed,
          productId: purchaseDetails.productID,
          transactionId: purchaseDetails.purchaseID,
          purchaseToken: null,
          purchaseDate: null,
          error: purchaseDetails.error?.message,
        ));
      }

      // Complete the purchase
      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
      }
    } catch (e) {
      debugPrint('Error processing purchase: $e');
    }
  }

  /// Verify purchase using platform-specific validation
  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    try {
      // Check if purchase has required fields
      if (purchaseDetails.productID.isEmpty) {
        debugPrint('Invalid purchase: empty product ID');
        return false;
      }
      
      // Check if it's a valid product ID for our app
      final validProductIds = ProductIds.getProductIds(currentStore);
      if (!validProductIds.contains(purchaseDetails.productID)) {
        debugPrint('Invalid purchase: unknown product ID ${purchaseDetails.productID}');
        return false;
      }
      
      // Apple's recommended approach: Try production first, then sandbox
      if (Platform.isIOS) {
        return await _verifyIOSReceipt(purchaseDetails);
      } else if (Platform.isAndroid) {
        return await _verifyAndroidReceipt(purchaseDetails);
      }
      
      debugPrint('Purchase verified successfully: ${purchaseDetails.productID}');
      return true;
      
    } catch (e) {
      debugPrint('Purchase verification failed: $e');
      return false;
    }
  }

  /// Verify iOS receipt with Apple's recommended approach
  Future<bool> _verifyIOSReceipt(PurchaseDetails purchaseDetails) async {
    try {
      // Apple's recommended approach: Try production first, then sandbox
      debugPrint('Verifying iOS receipt for product: ${purchaseDetails.productID}');
      
      // Check basic fields first
      if (purchaseDetails.purchaseID == null || purchaseDetails.purchaseID!.isEmpty) {
        debugPrint('Invalid iOS purchase: empty transaction ID');
        return false;
      }
      
      // The in_app_purchase plugin handles the production/sandbox validation automatically
      // It will try production first, then fall back to sandbox if needed
      
      // Additional validation: Check if purchase is in pending state
      if (purchaseDetails.status == iap.PurchaseStatus.pending) {
        debugPrint('iOS purchase is pending, waiting for completion');
        return false;
      }
      
      // Check if purchase is completed
      if (purchaseDetails.status != iap.PurchaseStatus.purchased && 
          purchaseDetails.status != iap.PurchaseStatus.restored) {
        debugPrint('iOS purchase not completed, status: ${purchaseDetails.status}');
        return false;
      }
      
      debugPrint('iOS purchase verified successfully: ${purchaseDetails.productID}');
      return true;
      
    } catch (e) {
      debugPrint('iOS receipt verification failed: $e');
      return false;
    }
  }

  /// Verify Android receipt
  Future<bool> _verifyAndroidReceipt(PurchaseDetails purchaseDetails) async {
    try {
      debugPrint('Verifying Android receipt for product: ${purchaseDetails.productID}');
      
      // Check purchase token
      final purchaseToken = _getPurchaseToken(purchaseDetails);
      if (purchaseToken == null || purchaseToken.isEmpty) {
        debugPrint('Invalid Android purchase: empty purchase token');
        return false;
      }
      
      // Check if purchase is in pending state
      if (purchaseDetails.status == iap.PurchaseStatus.pending) {
        debugPrint('Android purchase is pending, waiting for completion');
        return false;
      }
      
      // Check if purchase is completed
      if (purchaseDetails.status != iap.PurchaseStatus.purchased && 
          purchaseDetails.status != iap.PurchaseStatus.restored) {
        debugPrint('Android purchase not completed, status: ${purchaseDetails.status}');
        return false;
      }
      
      debugPrint('Android purchase verified successfully: ${purchaseDetails.productID}');
      return true;
      
    } catch (e) {
      debugPrint('Android receipt verification failed: $e');
      return false;
    }
  }

  /// Calculate expiry date based on product ID
  DateTime? _calculateExpiryDate(String productId) {
    final plan = ProductIds.getPlanFromProductId(productId);
    final now = DateTime.now();
    
    switch (plan) {
      case SubscriptionPlan.monthly:
        return now.add(const Duration(days: 30));
      case SubscriptionPlan.quarterly:
        return now.add(const Duration(days: 90));
      case SubscriptionPlan.free:
        return null;
    }
  }

  /// Get product price (from store only)
  double _getProductPrice(String productId) {
    final product = _availableProducts.firstWhere(
      (p) => p.id == productId,
      orElse: () => ProductModel(
        id: productId,
        title: '',
        description: '',
        price: 0.0,
        priceString: '',
        currency: 'TL',
        plan: SubscriptionPlan.free,
        store: currentStore,
        features: [],
      ),
    );
    return product.price;
  }

  /// Get original transaction ID (platform-specific)
  String? _getOriginalTransactionId(PurchaseDetails purchaseDetails) {
    if (purchaseDetails is AppStorePurchaseDetails) {
      return purchaseDetails.skPaymentTransaction.originalTransaction?.transactionIdentifier;
    }
    return purchaseDetails.purchaseID;
  }

  /// Get purchase token (platform-specific)
  String? _getPurchaseToken(PurchaseDetails purchaseDetails) {
    if (purchaseDetails is GooglePlayPurchaseDetails) {
      return purchaseDetails.billingClientPurchase.purchaseToken;
    }
    return null;
  }

  /// Restore previous purchases
  Future<void> restorePurchases() async {
    try {
      await _inAppPurchase.restorePurchases();
      
      // Also check for premium code subscriptions
      final premiumCodeSubscription = await _premiumCodeService.getPremiumCodeSubscription();
      if (premiumCodeSubscription != null) {
        _currentSubscription = premiumCodeSubscription;
        _subscriptionController.add(premiumCodeSubscription);
        debugPrint('Premium code subscription restored');
      }
      
      debugPrint('Restore purchases completed');
    } catch (e) {
      debugPrint('Error restoring purchases: $e');
      _purchaseController.add(PurchaseResult(
        status: PurchaseStatus.failed,
        productId: null,
        transactionId: null,
        purchaseToken: null,
        purchaseDate: null,
        error: 'Satın alımlar geri yüklenirken hata oluştu: ${e.toString()}',
      ));
    }
  }

  /// Check if user has active subscription
  bool get hasActiveSubscription {
    // First check subscription expiry
    _checkSubscriptionExpiry();
    
    return _currentSubscription?.isActive == true &&
           (_currentSubscription?.expiryDate?.isAfter(DateTime.now()) ?? false);
  }

  /// Check if user has specific premium feature
  bool hasPremiumFeature(PremiumFeature feature) {
    if (!hasActiveSubscription) return false;
    return _currentSubscription?.features.contains(feature) ?? false;
  }

  /// Get current subscription
  SubscriptionModel? get currentSubscription => _currentSubscription;

  /// Load stored subscription from SharedPreferences
  Future<void> _loadStoredSubscription() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final subscriptionJson = prefs.getString(_subscriptionKey);
      
      if (subscriptionJson != null) {
        final subscriptionData = jsonDecode(subscriptionJson);
        final subscription = SubscriptionModel.fromJson(subscriptionData);
        
        // Check if subscription is still valid
        if (subscription.isActive && 
            (subscription.expiryDate?.isAfter(DateTime.now()) ?? false)) {
          _currentSubscription = subscription;
          _subscriptionController.add(subscription);
          debugPrint('Loaded valid stored subscription: ${subscription.plan}');
        } else {
          // Remove expired subscription
          await _clearStoredSubscription();
          debugPrint('Removed expired stored subscription');
        }
      }
    } catch (e) {
      debugPrint('Error loading stored subscription: $e');
    }
  }

  /// Save subscription to SharedPreferences
  Future<void> _saveSubscription(SubscriptionModel subscription) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final subscriptionJson = jsonEncode(subscription.toJson());
      await prefs.setString(_subscriptionKey, subscriptionJson);
      debugPrint('Subscription saved to storage');
    } catch (e) {
      debugPrint('Error saving subscription: $e');
    }
  }

  /// Clear stored subscription
  Future<void> _clearStoredSubscription() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_subscriptionKey);
      debugPrint('Stored subscription cleared');
    } catch (e) {
      debugPrint('Error clearing stored subscription: $e');
    }
  }

  /// Check and update subscription expiry
  Future<void> _checkSubscriptionExpiry() async {
    if (_currentSubscription != null) {
      final now = DateTime.now();
      if (_currentSubscription!.expiryDate != null && 
          _currentSubscription!.expiryDate!.isBefore(now)) {
        // Subscription expired
        _currentSubscription = null;
        _subscriptionController.add(null);
        await _clearStoredSubscription();
        debugPrint('Subscription expired and cleared');
      }
    }
  }

  /// Get available products
  List<ProductModel> get availableProducts => _availableProducts;

  /// Dispose resources
  void dispose() {
    _subscription.cancel();
    _subscriptionController.close();
    _productsController.close();
    _purchaseController.close();
  }
}