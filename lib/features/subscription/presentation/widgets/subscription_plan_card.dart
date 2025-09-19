import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/subscription_model.dart';

class SubscriptionPlanCard extends StatelessWidget {
  final ProductModel product;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onPurchase;

  const SubscriptionPlanCard({
    super.key,
    required this.product,
    required this.isSelected,
    required this.onTap,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    final isYearly = product.plan == SubscriptionPlan.yearly;
    final monthlyPrice = isYearly ? (product.price / 12) : product.price;
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.accentGold : AppTheme.mediumGrey,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isSelected ? 0.15 : 0.1),
              blurRadius: isSelected ? 12 : 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          isYearly ? 'Yıllık Plan' : 'Aylık Plan',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryNavyBlue,
                          ),
                        ),
                        if (isYearly) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.successGreen,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              '%60 İNDİRİM',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isYearly ? 'En popüler seçenek' : 'Esnek ödeme',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.darkGrey,
                      ),
                    ),
                  ],
                ),
                Radio<bool>(
                  value: true,
                  groupValue: isSelected,
                  onChanged: (_) => onTap(),
                  activeColor: AppTheme.accentGold,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₺${product.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryNavyBlue,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  isYearly ? '/yıl' : '/ay',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.darkGrey,
                  ),
                ),
              ],
            ),
            if (isYearly) ...[
              const SizedBox(height: 4),
              Text(
                'Aylık ₺${monthlyPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.darkGrey,
                ),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPurchase,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected 
                      ? AppTheme.accentGold 
                      : AppTheme.primaryNavyBlue,
                  foregroundColor: isSelected 
                      ? AppTheme.primaryNavyBlue 
                      : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Satın Al',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}