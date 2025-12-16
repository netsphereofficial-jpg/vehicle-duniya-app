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
    if (location.startsWith(AppRoutes.myBids) ||
        location.startsWith(AppRoutes.profile) ||
        location.startsWith(AppRoutes.carBazaar)) {
      return 3;
    }
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
        _showMoreMenu(context);
        break;
    }
  }

  void _showMoreMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const _MoreMenuSheet(),
    );
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
                  icon: const Icon(Icons.grid_view_outlined, size: 24),
                  activeIcon: const Icon(Icons.grid_view_rounded, size: 24),
                  title: Text(
                    'More',
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

class _MoreMenuSheet extends StatelessWidget {
  const _MoreMenuSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.apps_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'More Options',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _MoreMenuItem(
            icon: Icons.storefront_rounded,
            label: 'Car Bazaar',
            subtitle: 'Buy & sell cars directly',
            color: AppColors.success,
            onTap: () {
              Navigator.pop(context);
              context.push('/car-bazaar');
            },
          ),
          _MoreMenuItem(
            icon: Icons.gavel_rounded,
            label: 'My Bids',
            subtitle: 'Track your bidding activity',
            color: AppColors.warning,
            onTap: () {
              Navigator.pop(context);
              context.go('/my-bids');
            },
          ),
          _MoreMenuItem(
            icon: Icons.person_rounded,
            label: 'Profile',
            subtitle: 'Manage your account',
            color: AppColors.info,
            onTap: () {
              Navigator.pop(context);
              context.go('/profile');
            },
          ),
          _MoreMenuItem(
            icon: Icons.notifications_rounded,
            label: 'Notifications',
            subtitle: 'View all notifications',
            color: AppColors.accent,
            onTap: () {
              Navigator.pop(context);
              context.push('/notifications');
            },
          ),
          _MoreMenuItem(
            icon: Icons.help_outline_rounded,
            label: 'Help & Support',
            subtitle: 'Get help with your queries',
            color: AppColors.textSecondary,
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to help
            },
          ),
          const SizedBox(height: 12),
          SafeArea(
            top: false,
            child: const SizedBox(height: 8),
          ),
        ],
      ),
    );
  }
}

class _MoreMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _MoreMenuItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.textTertiary,
                  size: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
