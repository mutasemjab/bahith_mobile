import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/app_settings_service.dart';
import '../theme/app_colors.dart';

/// Bottom navigation shell — wraps the four primary tabs and keeps each
/// tab's navigation stack alive via [StatefulShellRoute.indexedStack].
class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const AppShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final showCommerce = AppSettingsScope.of(context).showCommerce;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: BottomNavigationBar(
          currentIndex: navigationShell.currentIndex,
          onTap: (index) => navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          ),
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'الرئيسية',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.menu_book_outlined),
              activeIcon: const Icon(Icons.menu_book_rounded),
              label: showCommerce ? 'الدورات' : 'دوراتي',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.quiz_outlined),
              activeIcon: const Icon(Icons.quiz_rounded),
              label: showCommerce ? 'الاختبارات' : 'اختباراتي',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.campaign_outlined),
              activeIcon: Icon(Icons.campaign_rounded),
              label: 'الإعلانات',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'حسابي',
            ),
          ],
        ),
      ),
    );
  }
}
