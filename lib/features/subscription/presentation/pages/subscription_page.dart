import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/subscription_model.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/providers/auth_providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/purchase_loading_dialog.dart';
import '../widgets/subscription_plan_card.dart';
import '../widgets/premium_features_list.dart';
import '../../../../core/utils/error_utils.dart';

class SubscriptionPage extends ConsumerStatefulWidget {
  const SubscriptionPage({super.key});

  @override
  ConsumerState<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends ConsumerState<SubscriptionPage> 
    with TickerProviderStateMixin {
  SubscriptionPlan? selectedPlan;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    // Start animations
    _fadeController.forward();
    _slideController.forward();
    _pulseController.repeat(reverse: true);
    
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _handlePurchaseResult(PurchaseResult result) {
    Navigator.of(context).pop(); // Close loading dialog if open
    
    switch (result.status) {
      case PurchaseStatus.purchased:
        _showSuccessDialog();
        break;
      case PurchaseStatus.restored:
        _showRestoredDialog();
        break;
      case PurchaseStatus.failed:
        _showErrorDialog(result.error ?? 'Satın alma işlemi başarısız oldu');
        break;
      case PurchaseStatus.canceled:
        // User canceled, no action needed
        break;
      case PurchaseStatus.pending:
        _showPendingDialog();
        break;
    }
    
    // Clear the result
    ref.read(purchaseResultProvider.notifier).clearResult();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Tebrikler!'),
        content: const Text('Premium üyeliğiniz başarıyla aktif edildi. Artık tüm premium özelliklerden yararlanabilirsiniz!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to previous page
            },
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showRestoredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('✅ Geri Yüklendi'),
        content: const Text('Premium üyeliğiniz başarıyla geri yüklendi.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('❌ Hata'),
        content: Text('Satın alma işlemi sırasında bir hata oluştu:\n$error'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showPendingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⏳ İşlem Beklemede'),
        content: const Text('Satın alma işleminiz işleniyor. Lütfen bekleyin.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  Future<void> _purchaseSubscription(ProductModel product) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const PurchaseLoadingDialog(),
      );

      // Initiate purchase with timeout
      await ref.read(subscriptionProvider.notifier).purchaseSubscription(product.id)
          .timeout(
            const Duration(seconds: 60), // Longer timeout for purchases
            onTimeout: () {
              throw TimeoutException('Satın alma işlemi zaman aşımına uğradı', const Duration(seconds: 60));
            },
          );
    } on TimeoutException catch (_) {
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();
      
      // Show timeout error
      if (mounted) {
        _showErrorDialog('Satın alma işlemi zaman aşımına uğradı. Lütfen tekrar deneyin.');
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();
      
      // Show error
      if (mounted) {
        ErrorUtils.showSubscriptionError(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentSubscription = ref.watch(subscriptionProvider);
    final availableProducts = ref.watch(availableProductsProvider);
    final isPremium = ref.watch(isPremiumUserProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    // Listen to purchase results
    ref.listen<PurchaseResult?>(purchaseResultProvider, (previous, next) {
      if (next != null) {
        _handlePurchaseResult(next);
      }
    });

    // Giriş yapmamış kullanıcılar için giriş zorunluluğu
    if (!isAuthenticated) {
      return _buildLoginRequiredView();
    }

    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      appBar: AppBar(
        title: const Text(
          'Premium Üyelik',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primaryNavyBlue,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 // Current Status Card
                 if (isPremium) _buildCurrentStatusCard(currentSubscription),
                 
                 // Header Section
                 _buildHeaderSection(),
                 
                 const SizedBox(height: 24),
                 
                 // Premium Features List
                 const PremiumFeaturesList(),
                 
                 const SizedBox(height: 32),
                 
                 // Subscription Plans
                 Center(
                   child: _buildSubscriptionPlans(availableProducts),
                 ),
                
                const SizedBox(height: 24),
                
                // Terms and Privacy Links
                _buildTermsPrivacyLinks(),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStatusCard(SubscriptionModel? subscription) {
    if (subscription == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.accentGold, AppTheme.accentGold.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.star,
                color: AppTheme.primaryNavyBlue,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Premium Üye',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryNavyBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
              subscription.plan == SubscriptionPlan.monthly ? 'Aylık Plan' : '3 Aylık Plan',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.primaryNavyBlue.withValues(alpha: 0.8),
              ),
            ),
            if (subscription.expiryDate != null) ...[
              const SizedBox(height: 4),
              Text(
                'Bitiş: ${_formatDate(subscription.expiryDate!)}',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.primaryNavyBlue.withValues(alpha: 0.7),
                ),
              ),
            ],
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.workspace_premium,
            size: 64,
            color: AppTheme.accentGold,
          ),
          const SizedBox(height: 16),
          Text(
            'Premium\'a Geçin',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryNavyBlue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sınırsız soru çözme, reklamsız deneyim ve daha fazlası için premium üyeliğe geçin!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.darkGrey,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionPlans(List<ProductModel> products) {
    if (products.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.hourglass_empty,
              size: 48,
              color: AppTheme.darkGrey,
            ),
            const SizedBox(height: 16),
            Text(
              'Planlar Yükleniyor...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.darkGrey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Premium planları yüklüyoruz, lütfen bekleyin.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.darkGrey,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Premium Planları',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryNavyBlue,
          ),
        ),
        const SizedBox(height: 16),
        ...products.asMap().entries.map((entry) {
          final index = entry.key;
          final product = entry.value;
          
          return AnimatedBuilder(
            animation: _slideController,
            builder: (context, child) {
              final delay = index * 0.1;
              final animationValue = Curves.easeOutCubic.transform(
                (_slideController.value - delay).clamp(0.0, 1.0),
              );
              
              return Transform.translate(
                offset: Offset(0, 30 * (1 - animationValue)),
                child: Opacity(
                  opacity: animationValue,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: SubscriptionPlanCard(
                      product: product,
                      isSelected: selectedPlan == product.plan,
                      onTap: () {
                        setState(() {
                          selectedPlan = product.plan;
                        });
                      },
                      onPurchase: () => _purchaseSubscription(product),
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }






  Widget _buildTermsPrivacyLinks() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Yasal Bilgiler',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryNavyBlue,
            ),
          ),
          const SizedBox(height: 12),
          
          // Terms of Use Link
          GestureDetector(
            onTap: () => context.push('/terms-privacy'),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.description,
                    color: AppTheme.primaryNavyBlue,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Kullanım Koşulları ve Gizlilik Politikası',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.primaryNavyBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Subscription Info
          Text(
            'Abonelikler otomatik yenilenir. Apple\'ın standart Kullanım Koşulları geçerlidir.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildLoginRequiredView() {
    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      appBar: AppBar(
        title: const Text(
          'Premium Üyelik',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primaryNavyBlue,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Premium Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.accentGold, AppTheme.accentGold.withValues(alpha: 0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentGold.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.star,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Title
              Text(
                'Premium Üyelik',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryNavyBlue,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Message
              Text(
                'Premium üyelik satın almak için giriş yapmanız gerekmektedir.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Login Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.go('/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryNavyBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  child: const Text(
                    'Giriş Yap',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Register Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    context.go('/register');
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryNavyBlue,
                    side: BorderSide(color: AppTheme.primaryNavyBlue),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Hesap Oluştur',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Premium Features Preview
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Premium Özellikler',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryNavyBlue,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureItem('Sınırsız soru çözme'),
                    _buildFeatureItem('Reklamsız deneyim'),
               
    
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: AppTheme.accentGold,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}