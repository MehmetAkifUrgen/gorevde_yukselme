import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/questions/presentation/pages/question_pool_page.dart';
import '../../features/questions/presentation/pages/starred_questions_page.dart';
import '../../features/performance/presentation/pages/performance_analysis_page.dart';
import '../../features/profile/presentation/pages/profile_settings_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../providers/auth_providers.dart';

class MainNavigation extends ConsumerStatefulWidget {
  final int initialIndex;
  
  const MainNavigation({
    super.key,
    this.initialIndex = 0,
  });

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> {
  late int _selectedIndex;
  late PageController _pageController;

  List<Widget> _buildPages(bool isAuthenticated) {
    return [
      const HomePage(),
      const QuestionPoolPage(),
      const StarredQuestionsPage(),
      const PerformanceAnalysisPage(),
      isAuthenticated ? const ProfileSettingsPage() : const LoginPage(),
    ];
  }

  List<BottomNavigationBarItem> _buildNavItems(bool isAuthenticated) => [
    BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home),
      label: 'Ana Sayfa',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.quiz_outlined),
      activeIcon: Icon(Icons.quiz),
      label: 'Sorular',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.star_outline),
      activeIcon: Icon(Icons.star),
      label: 'Favoriler',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.analytics_outlined),
      activeIcon: Icon(Icons.analytics),
      label: 'Performans',
    ),
    BottomNavigationBarItem(
      icon: const Icon(Icons.person_outline),
      activeIcon: const Icon(Icons.person),
      label: isAuthenticated ? 'Profil' : 'Giriş Yap',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    int targetIndex = index;
    final isAuthenticated = ref.read(isAuthenticatedProvider);
    // If Favorites tab (index 2) tapped without auth, warn and go to Login tab (index 4)
    if (index == 2 && !isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Favoriler için lütfen giriş yapın.')),
      );
      targetIndex = 4;
    }
    if (_selectedIndex != targetIndex) {
      setState(() {
        _selectedIndex = targetIndex;
      });
      _pageController.animateToPage(
        targetIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final pages = _buildPages(isAuthenticated);
    final navItems = _buildNavItems(isAuthenticated);
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.secondaryWhite,
        selectedItemColor: AppTheme.primaryNavyBlue,
        unselectedItemColor: AppTheme.darkGrey,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        elevation: 8,
        items: navItems,
      ),
    );
  }
}

// Provider for current navigation index
final navigationIndexProvider = StateProvider<int>((ref) => 0);