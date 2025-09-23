import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/models/user_statistics.dart';
import '../../../../core/providers/auth_providers.dart';
import '../../../subscription/presentation/widgets/ad_banner_widget.dart';
import '../../../../core/widgets/support_dialog.dart';
import '../widgets/change_password_dialog.dart';
import '../widgets/delete_account_dialog.dart';

class ProfileSettingsPage extends ConsumerStatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  ConsumerState<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends ConsumerState<ProfileSettingsPage> {

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProfileProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil ve Ayarlar'),
        backgroundColor: AppTheme.lightTheme.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editProfile,
          ),
        ],
      ),
      body: currentUser.when(
        data: (user) {
          if (user == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Profil bilgilerini görmek için giriş yapın'),
                ],
              ),
            );
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Section
                _buildProfileSection(user),
                const SizedBox(height: 24),
                
                // Statistics Section
                _buildStatisticsSection(user),
                const SizedBox(height: 24),
                

                
                // Account Section
                _buildAccountSection(user),
                const SizedBox(height: 24),
                
                // Support Section
                _buildSupportSection(),
                const SizedBox(height: 24),
                
                // Ad Banner for non-premium users
                if (user.subscriptionStatus != SubscriptionStatus.premium)
                  const AdBannerWidget(),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Hata: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(currentUserProfileProvider),
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection(User user) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Picture
            CircleAvatar(
              radius: 50,
              backgroundColor: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
              child: user.profileImageUrl != null
                  ? ClipOval(
                      child: Image.network(
                        user.profileImageUrl!,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(
                      Icons.person,
                      size: 50,
                      color: AppTheme.lightTheme.primaryColor,
                    ),
            ),
            const SizedBox(height: 16),
            
            // User Info
            Text(
              user.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user.email,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            
            // Subscription
            _buildInfoChip(
              _getSubscriptionDisplayName(user.subscriptionStatus),
              Icons.star,
              user.subscriptionStatus == SubscriptionStatus.premium
                  ? Colors.amber
                  : Colors.grey,
            ),
            
            if (user.subscriptionStatus == SubscriptionStatus.premium && user.subscriptionExpiryDate != null) ...[
              const SizedBox(height: 8),
              Text(
                'Premium süresi: ${_formatDate(user.subscriptionExpiryDate!)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }



  String _getSubscriptionDisplayName(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.free:
        return 'Ücretsiz';
      case SubscriptionStatus.premium:
        return 'Premium';
    }
  }

  Widget _buildInfoChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(User user) {
    final statistics = user.statistics ?? const UserStatistics(
      totalQuestionsAnswered: 0,
      correctAnswers: 0,
      totalExamsTaken: 0,
      averageScore: 0.0,
      totalStudyTimeMinutes: 0,
      currentStreak: 0,
      longestStreak: 0,
    );

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'İstatistikleriniz',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Çözülen Sorular',
                    '${statistics.totalQuestionsAnswered}',
                    Icons.quiz,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Doğruluk Oranı',
                    '${statistics.averageScore.toStringAsFixed(1)}%',
                    Icons.track_changes,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Çalışma Serisi',
                    '${statistics.currentStreak} gün',
                    Icons.local_fire_department,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Çalışma Süresi',
                    '${(statistics.totalStudyTimeMinutes / 60).toStringAsFixed(1)}s',
                    Icons.timer,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }



  Widget _buildAccountSection(User user) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hesap',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            if (user.subscriptionStatus != SubscriptionStatus.premium) ...[
              _buildActionTile(
                'Premium\'a Yükselt',
                'Tüm özelliklerin kilidini aç ve reklamları kaldır',
                Icons.star,
                Colors.amber,
                _upgradeToPremium,
              ),
              const Divider(),
            ],
            
            _buildActionTile(
              'Şifre Değiştir',
              'Hesap şifrenizi güncelleyin',
              Icons.lock,
              Colors.blue,
              _changePassword,
            ),
            

            _buildActionTile(
              'Hesabı Sil',
              'Hesabınızı kalıcı olarak silin',
              Icons.delete_forever,
              Colors.red,
              _deleteAccount,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Destek',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            

            _buildActionTile(
              'Destek ile İletişim',
              'Destek ekibimizden yardım alın',
              Icons.support_agent,
              Colors.green,
              _contactSupport,
            ),
            
            _buildActionTile(
                'Uygulamayı Değerlendir',
                'App Store\'da bizi değerlendirin',
                Icons.star_rate,
                Colors.amber,
                _rateApp,
              ),
            
            _buildActionTile(
              'Çıkış Yap',
              'Hesabınızdan çıkış yapın',
              Icons.logout,
              Colors.red,
              _signOut,
            ),
          ],
        ),
      ),
    );
  }





  Widget _buildActionTile(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _editProfile() {
    context.push('/profile/edit');
  }

  void _upgradeToPremium() {
    context.push('/subscription');
  }

  void _changePassword() {
    showDialog(
      context: context,
      builder: (context) => const ChangePasswordDialog(),
    );
  }

  void _privacySettings() {
    context.push('/privacy');
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (context) => const DeleteAccountDialog(),
    );
  }

  void _helpCenter() {
    context.push('/help');
  }

  void _contactSupport() {
    final userProfile = ref.read(currentUserProfileProvider).value;
    if (userProfile != null) {
      showDialog(
        context: context,
        builder: (context) => SupportDialog(userProfile: userProfile),
      );
    }
  }

  void _rateApp() {
    // App Store rating - will be implemented when app is published
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Uygulama henüz yayınlanmadı. Yayınlandıktan sonra değerlendirebilirsiniz.'),
      ),
    );
  }

  void _signOut() async {
    final authNotifier = ref.read(authNotifierProvider.notifier);
    await authNotifier.signOut();
  }
}