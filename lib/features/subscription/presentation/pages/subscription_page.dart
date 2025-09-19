import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/models/subscription_model.dart';
import '../widgets/subscription_plan_card.dart';
import '../widgets/premium_features_list.dart';
import '../widgets/purchase_loading_dialog.dart';

class SubscriptionPage extends ConsumerStatefulWidget {
  const SubscriptionPage({super.key});

  @override
  ConsumerState<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends ConsumerState<SubscriptionPage> {
  SubscriptionPlan? selectedPlan;

  @override
  void initState() {
    super.initState();
    // Listen to purchase results
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listen<PurchaseResult?>(purchaseResultProvider, (previous, next) {
        if (next != null) {
          _handlePurchaseResult(next);
        }
      });
    });
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
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const PurchaseLoadingDialog(),
    );

    // Initiate purchase
    await ref.read(subscriptionProvider.notifier).purchaseSubscription(product.id);
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
      body: SingleChildScrollView(
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
            
            // Terms and Privacy
            _buildTermsAndPrivacy(),
          ],
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
        ...products.map((product) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
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
        )),
      ],
    );
  }

  Widget _buildRestorePurchasesButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () async {
          // TODO: Implement restore purchases
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Satın alımlar geri yükleniyor...'),
            ),
          );
        },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(color: AppTheme.primaryNavyBlue),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Satın Alımları Geri Yükle',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryNavyBlue,
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
              onPressed: () {
                // TODO: Open terms of service
              },
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
              onPressed: () {
                // TODO: Open privacy policy
              },
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}