import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';

class TermsPrivacyPage extends StatelessWidget {
  const TermsPrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      appBar: AppBar(
        title: const Text(
          'Yasal Bilgiler',
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
            // Terms of Use Section
            _buildSection(
              'Kullanım Koşulları',
              Icons.description,
              [
                'Bu uygulama kamu sınavlarına hazırlık için tasarlanmıştır.',
                'Uygulamayı kullanarak aşağıdaki koşulları kabul etmiş olursunuz:',
                '',
                '1. Uygulama sadece eğitim amaçlıdır',
                '2. Telif hakkı ihlali yapmamalısınız',
                '3. Uygulamayı kötüye kullanmamalısınız',
                '4. Premium abonelikler otomatik yenilenir',
                '5. İptal işlemi App Store ayarlarından yapılır',
                '',
                'Detaylı bilgi için: https://www.apple.com/legal/internet-services/itunes/dev/stdeula/',
              ],
              onTap: () => _launchURL('https://www.apple.com/legal/internet-services/itunes/dev/stdeula/'),
            ),
            
            const SizedBox(height: 24),
            
            // Privacy Policy Section
            _buildSection(
              'Gizlilik Politikası',
              Icons.privacy_tip,
              [
                'Kişisel verilerinizin korunması bizim için önemlidir:',
                '',
                '1. E-posta adresiniz sadece hesap yönetimi için kullanılır',
                '2. Performans verileriniz sadece sizin hesabınızda saklanır',
                '3. Verileriniz üçüncü taraflarla paylaşılmaz',
                '4. Verilerinizi istediğiniz zaman silebilirsiniz',
                '5. Firebase servisleri veri güvenliği sağlar',
                '',
                'Detaylı bilgi için: https://sites.google.com/view/cyben-privacy/',
              ],
              onTap: () => _launchURL('https://sites.google.com/view/cyben-privacy/'),
            ),
            
            const SizedBox(height: 24),
            
            // Subscription Details Section
            _buildSection(
              'Abonelik Detayları',
              Icons.subscriptions,
              [
                'Premium abonelikler hakkında önemli bilgiler:',
                '',
                '• Abonelikler otomatik olarak yenilenir',
                '• Abonelik süresi ve fiyatları yukarıda belirtilmiştir',
                '• Aboneliklerinizi App Store ayarlarından yönetebilirsiniz',
                '• İptal işlemi App Store ayarlarından yapılır',
                '• Apple\'ın standart Kullanım Koşulları geçerlidir',
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Apple's Standard Terms Notice
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue[700],
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Apple\'ın standart Kullanım Koşulları geçerlidir. Abonelikler otomatik olarak yenilenir.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
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

  Widget _buildSection(String title, IconData icon, List<String> content, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: AppTheme.primaryNavyBlue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryNavyBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...content.map((line) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                line,
                style: TextStyle(
                  fontSize: 14,
                  color: line.isEmpty ? Colors.transparent : AppTheme.darkGrey,
                  height: 1.4,
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }
}