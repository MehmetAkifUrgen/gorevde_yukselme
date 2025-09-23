import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/models/subscription_model.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/purchase_loading_dialog.dart';
import '../widgets/generic_loading_dialog.dart';
import '../widgets/subscription_plan_card.dart';
import '../widgets/premium_features_list.dart';
import '../widgets/premium_code_dialog.dart';

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
    
    // Listen to purchase results
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listen<PurchaseResult?>(purchaseResultProvider, (previous, next) {
        if (next != null) {
          _handlePurchaseResult(next);
        }
      });
    });
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
        String errorMessage = 'Satın alma işlemi başarısız oldu';
        
        if (e.toString().contains('network')) {
          errorMessage = 'İnternet bağlantınızı kontrol edin';
        } else if (e.toString().contains('store')) {
          errorMessage = 'Mağaza bağlantısında sorun var';
        } else if (e.toString().contains('payment')) {
          errorMessage = 'Ödeme işlemi başarısız oldu';
        }
        
        _showErrorDialog(errorMessage);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentSubscription = ref.watch(subscriptionProvider);
    final availableProducts = ref.watch(availableProductsProvider);
    final isPremium = ref.watch(isPremiumUserProvider);

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
                 _buildSubscriptionPlans(availableProducts),
                
                const SizedBox(height: 24),
                
                // Restore Purchases Button
                _buildRestorePurchasesButton(),
                
                const SizedBox(height: 16),
                
                // Premium Code Button
                _buildPremiumCodeButton(),
                
                const SizedBox(height: 24),
                
                // Terms and Privacy
                _buildTermsAndPrivacy(),
                
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
              subscription.plan == SubscriptionPlan.monthly ? 'Aylık Plan' : 'Yıllık Plan',
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

  Widget _buildRestorePurchasesButton() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: OutlinedButton.icon(
              onPressed: () async {
          final currentContext = context;
          // Show loading dialog
          showDialog(
            context: currentContext,
            barrierDismissible: false,
            builder: (context) => const GenericLoadingDialog(
              title: 'Geri Yükleniyor',
              message: 'Satın alımlar geri yükleniyor...',
              subtitle: 'Bu işlem birkaç saniye sürebilir.\nLütfen bekleyin.',
            ),
          );

          try {
            // Restore purchases with timeout
            await ref.read(subscriptionProvider.notifier).restorePurchases()
                .timeout(
                  const Duration(seconds: 30),
                  onTimeout: () {
                    throw TimeoutException('İşlem zaman aşımına uğradı', const Duration(seconds: 30));
                  },
                );
            
            // Close loading dialog
            if (context.mounted) Navigator.of(context).pop();
            
            // Show success message
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Satın alımlar başarıyla geri yüklendi'),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          } on TimeoutException catch (_) {
            // Close loading dialog
            if (!context.mounted) return;
            Navigator.of(context).pop();
            
            // Show timeout error
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.error, color: Colors.white),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text('İşlem zaman aşımına uğradı. Lütfen tekrar deneyin.'),
                    ),
                  ],
                ),
                backgroundColor: Colors.orange,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 4),
              ),
            );
          } catch (e) {
            // Close loading dialog
            if (!context.mounted) return;
            Navigator.of(context).pop();
            
            // Show error message with better formatting
            String errorMessage = 'Bilinmeyen bir hata oluştu';
            
            if (e.toString().contains('network')) {
              errorMessage = 'İnternet bağlantınızı kontrol edin';
            } else if (e.toString().contains('store')) {
              errorMessage = 'Mağaza bağlantısında sorun var';
            } else if (e.toString().contains('purchase')) {
              errorMessage = 'Satın alma bilgileri alınamadı';
            }
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(errorMessage),
                    ),
                  ],
                ),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 4),
                action: SnackBarAction(
                  label: 'Tekrar Dene',
                  textColor: Colors.white,
                  onPressed: () {
                    // Retry the operation
                    // This will call the same onPressed function again
                  },
                ),
              ),
            );
          }
        },
               icon: const Icon(Icons.restore),
               label: const Text('Satın Alımları Geri Yükle'),
               style: OutlinedButton.styleFrom(
                 padding: const EdgeInsets.symmetric(vertical: 12),
                 side: BorderSide(color: Theme.of(context).primaryColor),
                 foregroundColor: Theme.of(context).primaryColor,
               ),
             ),
           ),
         );
       },
     );
   }

  Widget _buildPremiumCodeButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: OutlinedButton.icon(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const PremiumCodeDialog(),
          );
        },
        icon: const Icon(Icons.card_giftcard),
        label: const Text('Premium Kod Kullan'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          side: BorderSide(color: AppTheme.accentGold),
          foregroundColor: AppTheme.accentGold,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildTermsAndPrivacy() {
    return Column(
      children: [
        Text(
          'Satın alma işlemi ile Kullanım Şartları ve Gizlilik Politikası\'nı kabul etmiş olursunuz.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.darkGrey,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: _openTermsOfService,
              child: Text(
                'Kullanım Şartları',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.primaryNavyBlue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            Text(
              ' • ',
              style: TextStyle(
                color: AppTheme.darkGrey,
              ),
            ),
            TextButton(
              onPressed: _openPrivacyPolicy,
              child: Text(
                'Gizlilik Politikası',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.primaryNavyBlue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _openTermsOfService() async {
    const url = 'https://gorevdeyukselme.com/terms-of-service';
    
    if (!context.mounted) return;
    
    try {
      final canLaunch = await canLaunchUrl(Uri.parse(url));
      if (!context.mounted) return;
      
      if (canLaunch) {
        await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kullanım şartları sayfası açılamadı'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: \${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _openPrivacyPolicy() async {
    const url = 'https://gorevdeyukselme.com/privacy-policy';
    
    if (!context.mounted) return;
    
    try {
      final canLaunch = await canLaunchUrl(Uri.parse(url));
      if (!context.mounted) return;
      
      if (canLaunch) {
        await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gizlilik politikası sayfası açılamadı'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: \${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}