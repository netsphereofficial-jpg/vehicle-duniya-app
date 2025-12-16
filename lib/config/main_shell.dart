import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import '../core/constants/app_colors.dart';
import 'routes.dart';

/// Main shell widget with modern bottom navigation using Salomon Bottom Bar
class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({
    super.key,
    required this.child,
  });

  int _getCurrentIndex(String location) {
    if (location.startsWith(AppRoutes.vehicles)) return 1;
    if (location.startsWith(AppRoutes.properties)) return 2;
    if (location.startsWith(AppRoutes.more)) return 3;
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
        break;
      case 1:
        context.go(AppRoutes.vehicles);
        break;
      case 2:
        context.go(AppRoutes.properties);
        break;
      case 3:
        context.go(AppRoutes.more);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _getCurrentIndex(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SalomonBottomBar(
              currentIndex: currentIndex,
              onTap: (index) => _onItemTapped(context, index),
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.textTertiary,
              selectedColorOpacity: 0.12,
              itemPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              margin: const EdgeInsets.symmetric(horizontal: 8),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              items: [
                SalomonBottomBarItem(
                  icon: const Icon(Icons.home_outlined, size: 24),
                  activeIcon: const Icon(Icons.home_rounded, size: 24),
                  title: Text(
                    'Home',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SalomonBottomBarItem(
                  icon: const Icon(Icons.directions_car_outlined, size: 24),
                  activeIcon: const Icon(Icons.directions_car_rounded, size: 24),
                  title: Text(
                    'Vehicles',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SalomonBottomBarItem(
                  icon: const Icon(Icons.home_work_outlined, size: 24),
                  activeIcon: const Icon(Icons.home_work_rounded, size: 24),
                  title: Text(
                    'Properties',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SalomonBottomBarItem(
                  icon: const Icon(Icons.person_outline, size: 24),
                  activeIcon: const Icon(Icons.person_rounded, size: 24),
                  title: Text(
                    'Profile',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
