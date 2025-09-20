import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/models/user_preferences.dart';
import '../../../../core/models/user_statistics.dart';
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
  
  // Mock user data
  final User mockUser = User(
    id: '1',
    email: 'user@example.com',
    name: 'John Doe',
    profession: UserProfession.electricalElectronicEngineer,
    subscriptionStatus: SubscriptionStatus.premium,
    subscriptionExpiryDate: DateTime.now().add(const Duration(days: 30)),
    createdAt: DateTime.now().subtract(const Duration(days: 90)),
    lastLoginAt: DateTime.now(),
    isEmailVerified: true,
    profileImageUrl: null,
    preferences: const UserPreferences(
      fontSize: 16.0,
      notificationsEnabled: true,
      darkModeEnabled: false,
      soundEnabled: true,
      language: 'tr',
    ),
    statistics: const UserStatistics(
      totalQuestionsAnswered: 1247,
      correctAnswers: 967,
      totalExamsTaken: 23,
      averageScore: 77.6,
      totalStudyTimeMinutes: 2712,
      currentStreak: 12,
      longestStreak: 18,
    ),
  );

  @override
  void initState() {
    super.initState();
    _loadUserPreferences();
  }

  void _loadUserPreferences() {
    setState(() {
      fontSize = mockUser.preferences.fontSize;
      notificationsEnabled = mockUser.preferences.notificationsEnabled;
      darkModeEnabled = mockUser.preferences.darkModeEnabled;
      soundEnabled = mockUser.preferences.soundEnabled;
      selectedLanguage = mockUser.preferences.language == 'tr' ? 'Turkish' : 'English';
    });
  }

  @override
  Widget build(BuildContext context) {
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            _buildProfileSection(),
            const SizedBox(height: 24),
            
            // Statistics Section
            _buildStatisticsSection(),
            const SizedBox(height: 24),
            
            // Preferences Section
            _buildPreferencesSection(),
            const SizedBox(height: 24),
            
            // Account Section
            _buildAccountSection(),
            const SizedBox(height: 24),
            
            // Support Section
            _buildSupportSection(),
            const SizedBox(height: 24),
            
            // Ad Banner for non-premium users
            if (mockUser.subscriptionStatus != SubscriptionStatus.premium)
              const AdBannerWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
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
              child: mockUser.profileImageUrl != null
                  ? ClipOval(
                      child: Image.network(
                        mockUser.profileImageUrl!,
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
              mockUser.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              mockUser.email,
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
                  mockUser.profession.displayName,
                  Icons.work,
                  Colors.blue,
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  mockUser.subscriptionType.displayName,
                  Icons.star,
                  mockUser.subscriptionType == SubscriptionType.premium
                      ? Colors.amber
                      : Colors.grey,
                ),
              ],
            ),
            
            if (mockUser.subscriptionType == SubscriptionType.premium) ...[
              const SizedBox(height: 8),
              Text(
                'Premium expires: ${_formatDate(mockUser.subscriptionExpiryDate!)}',
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

  Widget _buildStatisticsSection() {
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
                    '${mockUser.statistics.totalQuestionsAnswered}',
                    Icons.quiz,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Accuracy',
                    '${mockUser.statistics.averageScore.toStringAsFixed(1)}%',
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
                    '${mockUser.statistics.currentStreak} days',
                    Icons.local_fire_department,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Study Time',
                    '${(mockUser.statistics.totalStudyTimeMinutes / 60).toStringAsFixed(1)}h',
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
            const Divider(),
            
            // Dark Mode
            _buildSwitchTile(
              'Dark Mode',
              'Use dark theme for better night reading',
              Icons.dark_mode,
              darkModeEnabled,
              (value) => setState(() => darkModeEnabled = value),
            ),
            const Divider(),
            
            // Sound
            _buildSwitchTile(
              'Sound Effects',
              'Play sounds for interactions',
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

  Widget _buildFontSizeSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.text_fields, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Text(
              'Font Size',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            Text(
              '${fontSize.round()}px',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: fontSize,
          min: 12.0,
          max: 24.0,
          divisions: 12,
          onChanged: (value) => setState(() => fontSize = value),
        ),
        Text(
          'Sample text with current font size',
          style: TextStyle(fontSize: fontSize),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, IconData icon, bool value, Function(bool) onChanged) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.lightTheme.primaryColor,
        ),
      ],
    );
  }

  Widget _buildLanguageSelector() {
    return Row(
      children: [
        Icon(Icons.language, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Language',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                'Choose your preferred language',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        DropdownButton<String>(
          value: selectedLanguage,
          items: ['Turkish', 'English'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() => selectedLanguage = newValue);
            }
          },
        ),
      ],
    );
  }

  Widget _buildAccountSection() {
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
            _buildAccountTile(
              'Change Password',
              'Update your account password',
              Icons.lock,
              () => _showChangePasswordDialog(),
            ),
            const Divider(),
            _buildAccountTile(
              'Subscription',
              'Manage your subscription plan',
              Icons.card_membership,
              () => _navigateToSubscription(),
            ),
            const Divider(),
            _buildAccountTile(
              'Export Data',
              'Download your study data',
              Icons.download,
              () => _exportData(),
            ),
            const Divider(),
            _buildAccountTile(
              'Delete Account',
              'Permanently delete your account',
              Icons.delete_forever,
              () => _showDeleteAccountDialog(),
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountTile(String title, String subtitle, IconData icon, VoidCallback onTap, {bool isDestructive = false}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? Colors.red : Colors.grey[600],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isDestructive ? Colors.red : null,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
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
            _buildAccountTile(
              'Help Center',
              'Find answers to common questions',
              Icons.help,
              () => _openHelpCenter(),
            ),
            const Divider(),
            _buildAccountTile(
              'Contact Support',
              'Get help from our support team',
              Icons.support_agent,
              () => _contactSupport(),
            ),
            const Divider(),
            _buildAccountTile(
              'Rate App',
              'Rate us on the App Store',
              Icons.star_rate,
              () => _rateApp(),
            ),
            const Divider(),
            _buildAccountTile(
              'About',
              'App version and legal information',
              Icons.info,
              () => _showAboutDialog(),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _editProfile() {
    // TODO: Navigate to edit profile page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit profile functionality coming soon')),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: const Text('Password change functionality will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  void _navigateToSubscription() {
    // TODO: Navigate to subscription page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Subscription management coming soon')),
    );
  }

  void _exportData() {
    // TODO: Implement data export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data export functionality coming soon')),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement account deletion
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _openHelpCenter() {
    // TODO: Open help center
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Help center coming soon')),
    );
  }

  void _contactSupport() {
    // TODO: Open contact support
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contact support coming soon')),
    );
  }

  void _rateApp() {
    // TODO: Open app store rating
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('App rating coming soon')),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Görevde Yükselme',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2024 Görevde Yükselme. All rights reserved.',
      children: [
        const Text('A comprehensive exam preparation app for professional advancement.'),
      ],
    );
  }
}