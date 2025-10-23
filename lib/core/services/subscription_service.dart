import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_purchase/in_app_purchase.dart' hide PurchaseStatus;
import 'package:in_app_purchase/in_app_purchase.dart' as iap show PurchaseStatus;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/subscription_model.dart';
import 'premium_code_service.dart';

/// Service for handling platform-specific in-app purchases
class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal() {
    // Start listening to purchase updates as early as possible
    // This ensures we don't miss any purchase updates from previous app sessions
    _subscription = _inAppPurchase.purchaseStream.listen(
      _handlePurchaseUpdates,
      onDone: () => debugPrint('Purchase stream done'),
      onError: (error) => debugPrint('Purchase stream error: $error'),
    );
  }

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
  
  // Apple's receipt verification URLs
  static const String _appleProductionUrl = 'https://buy.itunes.apple.com/verifyReceipt';
  static const String _appleSandboxUrl = 'https://sandbox.itunes.apple.com/verifyReceipt';
  Map<String, dynamic>? _lastIOSVerification;
  
  // Storage keys
  static const String _subscriptionKey = 'current_subscription';

  /// Initialize the subscription service
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
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

      // Purchase stream listener is already set up in constructor

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
      debugPrint('Loading products from store...');
      
      final Set<String> productIds = ProductIds.getProductIds(currentStore).toSet();
      
      if (productIds.isEmpty) {
        debugPrint('No product IDs for current platform');
        _productsController.add([]);
        return;
      }

      debugPrint('Product IDs to load: $productIds');

      // Query products with timeout to prevent hanging
      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(productIds).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Product query timed out');
        },
      );

      debugPrint('Product query response: ${response.notFoundIDs}');
      debugPrint('Found products: ${response.productDetails.length}');

      if (response.error != null) {
        debugPrint('Error loading products: ${response.error}');
        throw Exception('Product query failed: ${response.error}');
      }

      if (response.productDetails.isEmpty) {
        debugPrint('No products returned. Check App Store/Play Console status, Paid Apps Agreement, and product IDs.');
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
      _productsController.add([]);
      
      // Add error to purchase stream
      _purchaseController.add(PurchaseResult(
        status: PurchaseStatus.failed,
        productId: null,
        transactionId: null,
        purchaseToken: null,
        purchaseDate: null,
        error: 'Ürünler yüklenirken hata oluştu: ${e.toString()}',
      ));
    }
  }

  /// Public method to reload products on demand
  Future<void> reloadProducts() async {
    try {
      await _loadProducts();
    } catch (e) {
      debugPrint('Failed to reload products: $e');
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

      // Purchase subscription - buyNonConsumable works for both subscriptions and non-consumables
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
      if (purchaseDetails.status == iap.PurchaseStatus.pending) {
        // Handle pending purchase - inform user that purchase is being processed
        _purchaseController.add(PurchaseResult(
          status: PurchaseStatus.pending,
          productId: purchaseDetails.productID,
          transactionId: purchaseDetails.purchaseID,
          purchaseToken: _getPurchaseToken(purchaseDetails),
          purchaseDate: DateTime.now(),
          subscription: null,
        ));
        debugPrint('Purchase is pending for: ${purchaseDetails.productID}');
        return; // Don't complete pending purchases
      }
      
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
      } else if (purchaseDetails.status == iap.PurchaseStatus.canceled) {
        _purchaseController.add(PurchaseResult(
          status: PurchaseStatus.canceled,
          productId: purchaseDetails.productID,
          transactionId: purchaseDetails.purchaseID,
          purchaseToken: null,
          purchaseDate: null,
          error: 'Purchase was canceled by user',
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

  /// Verify iOS purchase with Apple's mandatory server flow
  Future<bool> _verifyIOSReceipt(PurchaseDetails purchaseDetails) async {
    try {
      debugPrint('Verifying iOS purchase with server for product: ${purchaseDetails.productID}');
      
      // Pending purchases cannot be finalized yet
      if (purchaseDetails.status == iap.PurchaseStatus.pending) {
        debugPrint('iOS purchase pending; awaiting completion');
        return false;
      }
      
      // Ensure purchase is completed or restored
      if (purchaseDetails.status != iap.PurchaseStatus.purchased && 
          purchaseDetails.status != iap.PurchaseStatus.restored) {
        debugPrint('iOS purchase not in valid state: ${purchaseDetails.status}');
        return false;
      }

      // Get receipt data (this is a simplified approach - in real app you'd get from Bundle.main.appStoreReceiptURL)
      final receiptData = purchaseDetails.verificationData.serverVerificationData;
      if (receiptData.isEmpty) {
        debugPrint('No receipt data available');
        return false;
      }

      // Apple's MANDATORY flow: production first, then sandbox on 21007
      final verificationResult = await _verifyReceiptWithApple(receiptData);
      
      if (verificationResult['success'] == true) {
        // Store server response for subscription creation
        _lastIOSVerification = verificationResult['data'];
        debugPrint('iOS receipt verified successfully');
        return true;
      } else {
        debugPrint('iOS receipt verification failed: ${verificationResult['error']}');
        return false;
      }
      
    } catch (e) {
      debugPrint('iOS receipt verification error: $e');
      return false;
    }
  }

  /// Apple's mandatory receipt verification flow
  Future<Map<String, dynamic>> _verifyReceiptWithApple(String receiptData) async {
    try {
      // Step 1: Try production first (Apple's requirement)
      final productionResult = await _sendReceiptToApple(receiptData, isProduction: true);
      
      if (productionResult['status'] == 0) {
        // Success in production
        return {
          'success': true,
          'data': productionResult,
          'environment': 'production'
        };
      } else if (productionResult['status'] == 21007) {
        // Sandbox receipt sent to production - redirect to sandbox (MANDATORY)
        debugPrint('21007 detected: Redirecting to sandbox environment');
        final sandboxResult = await _sendReceiptToApple(receiptData, isProduction: false);
        
        if (sandboxResult['status'] == 0) {
          return {
            'success': true,
            'data': sandboxResult,
            'environment': 'sandbox'
          };
        } else {
          return {
            'success': false,
            'error': 'Sandbox verification failed with status: ${sandboxResult['status']}',
            'status': sandboxResult['status']
          };
        }
      } else if (productionResult['status'] == 21008) {
        // Production receipt sent to sandbox - this shouldn't happen in our flow
        debugPrint('21008 detected: Production receipt in sandbox call (unexpected)');
        return {
          'success': false,
          'error': 'Unexpected 21008 status in production call',
          'status': 21008
        };
      } else {
        // Other errors (21002, 21009, etc.)
        return {
          'success': false,
          'error': _getAppleErrorMessage(productionResult['status']),
          'status': productionResult['status']
        };
      }
      
    } catch (e) {
      debugPrint('Network error during receipt verification: $e');
      return {
        'success': false,
        'error': 'Ağ bağlantısı hatası. Lütfen tekrar deneyin.',
        'networkError': true
      };
    }
  }

  /// Send receipt to Apple's servers
  Future<Map<String, dynamic>> _sendReceiptToApple(String receiptData, {required bool isProduction}) async {
    final url = isProduction 
        ? _appleProductionUrl  // Production
        : _appleSandboxUrl;    // Sandbox
    
    debugPrint('Sending receipt to ${isProduction ? 'production' : 'sandbox'} Apple server');
    
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'receipt-data': receiptData,
          'password': 'a55a592fc20e46c997ede96f18572bd7',
          'exclude-old-transactions': true,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body) as Map<String, dynamic>;
        debugPrint('Apple server response status: ${result['status']}');
        return result;
      } else {
        debugPrint('HTTP error: ${response.statusCode}');
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error sending receipt to Apple: $e');
      rethrow;
    }
  }

  /// Get user-friendly error message for Apple status codes
  String _getAppleErrorMessage(int status) {
    switch (status) {
      case 21002:
        return 'Makbuz bozuk. Lütfen tekrar deneyin.';
      case 21009:
        return 'Bu hesap yasaklanmış. Lütfen Apple destek ile iletişime geçin.';
      case 21000:
        return 'App Store geçici olarak kullanılamıyor. Lütfen daha sonra tekrar deneyin.';
      case 21003:
        return 'Makbuz doğrulanamadı. Lütfen tekrar deneyin.';
      case 21004:
        return 'Paylaşılan gizli anahtar eşleşmiyor.';
      case 21005:
        return 'Makbuz sunucusu geçici olarak kullanılamıyor.';
      case 21006:
        return 'Makbuz geçerli ancak abonelik süresi dolmuş.';
      case 21010:
        return 'Bu makbuz işlenemez.';
      default:
        return 'Satın alma doğrulanamadı (Kod: $status). Lütfen tekrar deneyin.';
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
    // Use generic purchaseID since we removed platform-specific imports
    return purchaseDetails.purchaseID;
  }

  /// Get purchase token (platform-specific)
  String? _getPurchaseToken(PurchaseDetails purchaseDetails) {
    // Return null since we can't access platform-specific token without imports
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