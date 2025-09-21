import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/models/user_preferences.dart';
import '../../../../core/models/user_statistics.dart';
import '../../../../core/providers/auth_providers.dart';
import '../../../subscription/presentation/widgets/ad_banner_widget.dart';

class ProfileSettingsPage extends ConsumerStatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  ConsumerState<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends ConsumerState<ProfileSettingsPage> {
  double fontSize = 16.0;
  bool notificationsEnabled = true;
  bool darkModeEnabled = false;
  bool soundEnabled = true;
  String selectedLanguage = 'Turkish';

  @override
  void initState() {
    super.initState();
    _loadUserPreferences();
  }

  void _loadUserPreferences() {
    final currentUser = ref.read(currentUserProfileProvider);
    currentUser.whenData((user) {
      if (user != null && user.preferences != null) {
        setState(() {
          fontSize = user.preferences!.fontSize;
          notificationsEnabled = user.preferences!.notificationsEnabled;
          darkModeEnabled = user.preferences!.darkModeEnabled;
          soundEnabled = user.preferences!.soundEnabled;
          selectedLanguage = user.preferences!.language == 'tr' ? 'Turkish' : 'English';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProfileProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Settings'),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Section
                _buildProfileSection(user),
                const SizedBox(height: 24),
                
                // Statistics Section
                _buildStatisticsSection(user),
                const SizedBox(height: 24),
                
                // Preferences Section
                _buildPreferencesSection(),
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
            
            // Profession and Subscription
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildInfoChip(
                  _getProfessionDisplayName(user.profession),
                  Icons.work,
                  Colors.blue,
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  _getSubscriptionDisplayName(user.subscriptionStatus),
                  Icons.star,
                  user.subscriptionStatus == SubscriptionStatus.premium
                      ? Colors.amber
                      : Colors.grey,
                ),
              ],
            ),
            
            if (user.subscriptionStatus == SubscriptionStatus.premium && user.subscriptionExpiryDate != null) ...[
              const SizedBox(height: 8),
              Text(
                'Premium expires: ${_formatDate(user.subscriptionExpiryDate!)}',
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

  String _getProfessionDisplayName(UserProfession profession) {
    switch (profession) {
      case UserProfession.electricalElectronicEngineer:
        return 'Electrical Engineer';
      case UserProfession.constructionEngineer:
        return 'Construction Engineer';
      case UserProfession.computerTechnician:
        return 'Computer Technician';
      case UserProfession.machineTechnician:
        return 'Machine Technician';
      case UserProfession.generalRegulations:
        return 'General Regulations';
    }
  }

  String _getSubscriptionDisplayName(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.free:
        return 'Free';
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
              'Your Statistics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Questions Solved',
                    '${statistics.totalQuestionsAnswered}',
                    Icons.quiz,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Accuracy',
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
                    'Study Streak',
                    '${statistics.currentStreak} days',
                    Icons.local_fire_department,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Study Time',
                    '${(statistics.totalStudyTimeMinutes / 60).toStringAsFixed(1)}h',
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

  Widget _buildPreferencesSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preferences',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Font Size
            _buildFontSizeSlider(),
            const Divider(),
            
            // Notifications
            _buildSwitchTile(
              'Notifications',
              'Receive study reminders and updates',
              Icons.notifications,
              notificationsEnabled,
              (value) => setState(() => notificationsEnabled = value),
            ),
            
            // Dark Mode
            _buildSwitchTile(
              'Dark Mode',
              'Switch to dark theme',
              Icons.dark_mode,
              darkModeEnabled,
              (value) => setState(() => darkModeEnabled = value),
            ),
            
            // Sound
            _buildSwitchTile(
              'Sound Effects',
              'Enable sound feedback',
              Icons.volume_up,
              soundEnabled,
              (value) => setState(() => soundEnabled = value),
            ),
            
            const Divider(),
            
            // Language
            _buildLanguageSelector(),
          ],
        ),
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
              'Account',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            if (user.subscriptionStatus != SubscriptionStatus.premium) ...[
              _buildActionTile(
                'Upgrade to Premium',
                'Unlock all features and remove ads',
                Icons.star,
                Colors.amber,
                _upgradeToPremium,
              ),
              const Divider(),
            ],
            
            _buildActionTile(
              'Change Password',
              'Update your account password',
              Icons.lock,
              Colors.blue,
              _changePassword,
            ),
            
            _buildActionTile(
              'Privacy Settings',
              'Manage your privacy preferences',
              Icons.privacy_tip,
              Colors.green,
              _privacySettings,
            ),
            
            _buildActionTile(
              'Delete Account',
              'Permanently delete your account',
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
              'Support',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildActionTile(
              'Help Center',
              'Find answers to common questions',
              Icons.help,
              Colors.blue,
              _helpCenter,
            ),
            
            _buildActionTile(
              'Contact Support',
              'Get help from our support team',
              Icons.support_agent,
              Colors.green,
              _contactSupport,
            ),
            
            _buildActionTile(
              'Rate App',
              'Rate us on the App Store',
              Icons.star_rate,
              Colors.amber,
              _rateApp,
            ),
            
            _buildActionTile(
              'Sign Out',
              'Sign out of your account',
              Icons.logout,
              Colors.red,
              _signOut,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFontSizeSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Font Size',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text('A', style: TextStyle(fontSize: 12)),
            Expanded(
              child: Slider(
                value: fontSize,
                min: 12.0,
                max: 24.0,
                divisions: 6,
                label: fontSize.round().toString(),
                onChanged: (value) => setState(() => fontSize = value),
              ),
            ),
            const Text('A', style: TextStyle(fontSize: 20)),
          ],
        ),
      ],
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, IconData icon, bool value, ValueChanged<bool> onChanged) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.lightTheme.primaryColor),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildLanguageSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Language',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedLanguage,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: const [
            DropdownMenuItem(value: 'Turkish', child: Text('Turkish')),
            DropdownMenuItem(value: 'English', child: Text('English')),
          ],
          onChanged: (value) => setState(() => selectedLanguage = value!),
        ),
      ],
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
    // TODO: Navigate to edit profile page
  }

  void _upgradeToPremium() {
    // TODO: Navigate to subscription page
  }

  void _changePassword() {
    // TODO: Navigate to change password page
  }

  void _privacySettings() {
    // TODO: Navigate to privacy settings page
  }

  void _deleteAccount() {
    // TODO: Show delete account confirmation dialog
  }

  void _helpCenter() {
    // TODO: Navigate to help center
  }

  void _contactSupport() {
    // TODO: Navigate to contact support
  }

  void _rateApp() {
    // TODO: Open app store rating
  }

  void _signOut() async {
    final authNotifier = ref.read(authNotifierProvider.notifier);
    await authNotifier.signOut();
  }
}