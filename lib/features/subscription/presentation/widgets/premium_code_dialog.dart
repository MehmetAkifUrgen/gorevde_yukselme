import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/premium_code_service.dart';
import '../../../../core/theme/app_theme.dart';

class PremiumCodeDialog extends ConsumerStatefulWidget {
  const PremiumCodeDialog({super.key});

  @override
  ConsumerState<PremiumCodeDialog> createState() => _PremiumCodeDialogState();
}

class _PremiumCodeDialogState extends ConsumerState<PremiumCodeDialog> {
  final TextEditingController _codeController = TextEditingController();
  final FocusNode _codeFocusNode = FocusNode();
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    
    // Listen to premium code results
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final premiumCodeService = PremiumCodeService();
      premiumCodeService.codeResultStream.listen((result) {
        if (mounted) {
          _handleCodeResult(result);
        }
      });
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _codeFocusNode.dispose();
    super.dispose();
  }

  void _handleCodeResult(PremiumCodeResult result) {
    setState(() {
      _isLoading = false;
      if (result.success) {
        _successMessage = result.message;
        _errorMessage = null;
        
        // Close dialog after a short delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      } else {
        _errorMessage = result.message;
        _successMessage = null;
      }
    });
  }

  Future<void> _redeemCode() async {
    final code = _codeController.text.trim();
    
    if (code.isEmpty) {
      setState(() {
        _errorMessage = 'Lütfen bir kod girin';
        _successMessage = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final premiumCodeService = PremiumCodeService();
      await premiumCodeService.redeemCode(code);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Kod kullanılırken bir hata oluştu: ${e.toString()}';
        _successMessage = null;
      });
    }
  }

  void _clearMessages() {
    setState(() {
      _errorMessage = null;
      _successMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.card_giftcard,
                  color: AppTheme.accentGold,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Premium Kod Kullan',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryNavyBlue,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  color: AppTheme.darkGrey,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Description
            Text(
              'Premium kodunuzu girin ve premium özelliklerden yararlanmaya başlayın!',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.darkGrey,
                height: 1.4,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Code input
            TextField(
              controller: _codeController,
              focusNode: _codeFocusNode,
              decoration: InputDecoration(
                labelText: 'Premium Kod',
                hintText: 'Örn: GYUD-MONTHLY-ABC123',
                prefixIcon: const Icon(Icons.vpn_key),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.primaryNavyBlue),
                ),
                errorText: _errorMessage,
              ),
              textCapitalization: TextCapitalization.characters,
              onChanged: (_) => _clearMessages(),
              onSubmitted: (_) => _redeemCode(),
            ),
            
            const SizedBox(height: 16),
            
            // Success message
            if (_successMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _successMessage!,
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 24),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: AppTheme.darkGrey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'İptal',
                      style: TextStyle(color: AppTheme.darkGrey),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _redeemCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryNavyBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          )
                        : const Text('Kodu Kullan'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Help text
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.lightGrey,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppTheme.primaryNavyBlue,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Kod Formatları:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryNavyBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• GYUD-MONTHLY-XXXX (Aylık Premium)\n'
                    '• GYUD-QUARTERLY-XXXX (3 Aylık Premium)\n'
                    '• PROMO-XXXX (Promosyon Kodları)\n'
                    '• GIFT-XXXX (Hediye Kodları)',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.darkGrey,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

