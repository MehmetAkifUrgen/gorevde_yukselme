import 'dart:convert';
import 'package:http/http.dart' as http;

class ReceiptValidationService {
  static const String _productionUrl = 'https://buy.itunes.apple.com/verifyReceipt';
  static const String _sandboxUrl = 'https://sandbox.itunes.apple.com/verifyReceipt';
  
  Future<bool> validateReceipt(String receiptData) async {
    // Önce production'da dene
    final bool isValidInProduction = await _validateWithUrl(receiptData, _productionUrl);
    
    if (!isValidInProduction) {
      // Production'da geçersizse sandbox'ta dene
      return await _validateWithUrl(receiptData, _sandboxUrl);
    }
    
    return isValidInProduction;
  }

  Future<bool> _validateWithUrl(String receiptData, String url) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode({
          'receipt-data': receiptData,
          'password': 'YOUR_SHARED_SECRET', // App Store Connect'ten alınacak
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final status = responseData['status'];
        
        // Status 0 başarılı demektir
        if (status == 0) {
          return true;
        }
        
        // Status 21007 sandbox receipt'in production'da kullanıldığını gösterir
        if (status == 21007 && url == _productionUrl) {
          return false; // Sandbox'ta tekrar denenecek
        }
      }
      
      print('[ReceiptValidationService] Validation failed: ${response.body}');
      return false;
    } catch (e) {
      print('[ReceiptValidationService] Error: $e');
      return false;
    }
  }
}