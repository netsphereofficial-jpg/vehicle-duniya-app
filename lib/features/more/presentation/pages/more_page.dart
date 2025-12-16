import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _MoreView();
  }
}

class _MoreView extends StatelessWidget {
  const _MoreView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            final user = authState.user;

            return CustomScrollView(
              slivers: [
                // Custom App Bar
                SliverToBoxAdapter(
                  child: _buildAppBar(context),
                ),

                // Profile Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: _ProfileHeader(
                      name: user?.name ?? 'Complete Profile',
                      email: user?.email ?? user?.formattedPhone ?? '',
                      phone: user?.formattedPhone ?? '',
                      imageUrl: user?.profileImage,
                      isKycVerified: user?.isKycVerified ?? false,
                      onEditPressed: () => context.push('/more/edit-profile'),
                    ),
                  ),
                ),

                // Membership Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: _MembershipCard(
                      onViewDetails: () => context.push('/more/membership'),
                    ),
                  ),
                ),

                // Quick Actions
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: _QuickActions(
                      isKycVerified: user?.isKycVerified ?? false,
                    ),
                  ),
                ),

                // Menu Sections
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Auction Services Section
                        _MenuSection(
                          title: 'Auction Services',
                          items: [
                            _MenuItemData(
                              icon: Icons.dashboard_rounded,
                              title: 'Auction Dashboard',
                              subtitle: 'View your auction activity',
                              color: AppColors.primary,
                              onTap: () => context.push('/more/auction-dashboard'),
                            ),
                            _MenuItemData(
                              icon: Icons.card_membership_rounded,
                              title: 'Register for Membership',
                              subtitle: 'Get premium access',
                              color: AppColors.warning,
                              onTap: () => context.push('/more/membership-register'),
                            ),
                            _MenuItemData(
                              icon: Icons.home_work_rounded,
                              title: 'Join Property Auction',
                              subtitle: 'Bid on real estate',
                              color: AppColors.accent,
                              onTap: () => context.go('/properties'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Listings Section
                        _MenuSection(
                          title: 'Listings',
                          items: [
                            _MenuItemData(
                              icon: Icons.sell_rounded,
                              title: 'Seller Listing',
                              subtitle: 'List your items for auction',
                              color: AppColors.success,
                              onTap: () => context.push('/more/seller-listing'),
                            ),
                            _MenuItemData(
                              icon: Icons.shopping_bag_rounded,
                              title: 'Buyer Listing',
                              subtitle: 'Browse available items',
                              color: AppColors.info,
                              onTap: () => context.push('/more/buyer-listing'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Account Section
                        _MenuSection(
                          title: 'Account',
                          items: [
                            _MenuItemData(
                              icon: Icons.account_balance_rounded,
                              title: 'Bank Details & QR Code',
                              subtitle: 'Manage payment info',
                              color: AppColors.primaryLight,
                              onTap: () => context.push('/more/bank-details'),
                            ),
                            _MenuItemData(
                              icon: Icons.verified_user_rounded,
                              title: 'KYC Documents',
                              subtitle: 'Verify your identity',
                              color: AppColors.accent,
                              onTap: () => context.push('/more/kyc'),
                            ),
                            _MenuItemData(
                              icon: Icons.notifications_rounded,
                              title: 'Notifications',
                              subtitle: 'Manage your alerts',
                              color: AppColors.warning,
                              onTap: () => context.push('/notifications'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Share & Invite
                        _SingleMenuItem(
                          icon: Icons.share_rounded,
                          title: 'Share & Invite',
                          subtitle: 'Invite friends & earn rewards',
                          color: AppColors.success,
                          onTap: () => _shareApp(context),
                        ),
                        const SizedBox(height: 16),

                        // Support & Info Section
                        _MenuSection(
                          title: 'Support & Info',
                          items: [
                            _MenuItemData(
                              icon: Icons.info_rounded,
                              title: 'About Us & Contact',
                              subtitle: 'Learn more about us',
                              color: AppColors.primary,
                              onTap: () => context.push('/more/about'),
                            ),
                            _MenuItemData(
                              icon: Icons.help_rounded,
                              title: 'Help & Support',
                              subtitle: 'Get assistance',
                              color: AppColors.info,
                              onTap: () => context.push('/more/help'),
                            ),
                            _MenuItemData(
                              icon: Icons.feedback_rounded,
                              title: 'Complaint Box',
                              subtitle: 'Report issues',
                              color: AppColors.error,
                              onTap: () => context.push('/more/complaint'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Legal Section
                        _MenuSection(
                          title: 'Legal',
                          items: [
                            _MenuItemData(
                              icon: Icons.currency_rupee_rounded,
                              title: 'Refund Policy',
                              subtitle: 'View refund terms',
                              color: AppColors.textSecondary,
                              onTap: () => context.push('/more/policy/refund'),
                            ),
                            _MenuItemData(
                              icon: Icons.privacy_tip_rounded,
                              title: 'Privacy Policy',
                              subtitle: 'Your data protection',
                              color: AppColors.textSecondary,
                              onTap: () => context.push('/more/policy/privacy'),
                            ),
                            _MenuItemData(
                              icon: Icons.description_rounded,
                              title: 'Terms & Conditions',
                              subtitle: 'Service agreement',
                              color: AppColors.textSecondary,
                              onTap: () => context.push('/more/policy/terms'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Logout
                        _LogoutButton(
                          onTap: () => _showLogoutDialog(context),
                        ),
                        const SizedBox(height: 24),

                        // Version Info
                        Center(
                          child: Text(
                            'Vehicle Duniya v1.0.0',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Account',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Manage your profile & settings',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.settings_outlined),
              color: AppColors.textSecondary,
              onPressed: () {
                // TODO: Navigate to settings
              },
            ),
          ),
        ],
      ),
    );
  }

  void _shareApp(BuildContext context) {
    Share.share(
      'Check out Vehicle Duniya - The best platform for vehicle auctions! Download now: https://vehicleduniya.com/app',
      subject: 'Vehicle Duniya App',
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Logout',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AuthBloc>().add(const AuthSignOutRequested());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Logout',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Profile Header Widget
class _ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String phone;
  final String? imageUrl;
  final bool isKycVerified;
  final VoidCallback onEditPressed;

  const _ProfileHeader({
    required this.name,
    required this.email,
    required this.phone,
    this.imageUrl,
    required this.isKycVerified,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile Image
          Stack(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: imageUrl == null ? AppColors.primaryGradient : null,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    width: 3,
                  ),
                ),
                child: imageUrl != null
                    ? ClipOval(
                        child: Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildInitials(),
                        ),
                      )
                    : _buildInitials(),
              ),
              if (isKycVerified)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),

          // Profile Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                if (email.isNotEmpty)
                  Text(
                    email,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                if (phone.isNotEmpty && phone != email)
                  Text(
                    phone,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                const SizedBox(height: 8),
                if (isKycVerified)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified,
                          size: 14,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'KYC Verified',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Edit Button
          Container(
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: onEditPressed,
              icon: const Icon(
                Icons.edit_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitials() {
    final initials = name.isNotEmpty
        ? name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : 'U';
    return Center(
      child: Text(
        initials,
        style: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

// Membership Card Widget
class _MembershipCard extends StatelessWidget {
  final VoidCallback onViewDetails;

  const _MembershipCard({required this.onViewDetails});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667eea).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Membership Icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),

          // Membership Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'FREE PLAN',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Upgrade to Premium',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Get exclusive benefits',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),

          // View Details Button
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: onViewDetails,
              icon: const Icon(
                Icons.arrow_forward_rounded,
                color: Color(0xFF667eea),
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Quick Actions Widget
class _QuickActions extends StatelessWidget {
  final bool isKycVerified;

  const _QuickActions({required this.isKycVerified});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _QuickActionCard(
            icon: Icons.verified_user_rounded,
            label: 'KYC Status',
            status: isKycVerified ? 'Verified' : 'Pending',
            statusColor: isKycVerified ? AppColors.success : AppColors.warning,
            color: AppColors.accent,
            onTap: () => context.push('/more/kyc'),
          ),
          const SizedBox(width: 12),
          _QuickActionCard(
            icon: Icons.account_balance_rounded,
            label: 'Bank Details',
            status: 'Add Now',
            statusColor: AppColors.info,
            color: AppColors.primary,
            onTap: () => context.push('/more/bank-details'),
          ),
          const SizedBox(width: 12),
          _QuickActionCard(
            icon: Icons.gavel_rounded,
            label: 'My Bids',
            status: 'View All',
            statusColor: AppColors.textSecondary,
            color: AppColors.warning,
            onTap: () => context.go('/my-bids'),
          ),
          const SizedBox(width: 12),
          _QuickActionCard(
            icon: Icons.notifications_rounded,
            label: 'Alerts',
            status: 'Manage',
            statusColor: AppColors.textSecondary,
            color: AppColors.error,
            onTap: () => context.push('/notifications'),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String status;
  final Color statusColor;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.status,
    required this.statusColor,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              status,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: statusColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Menu Section Widget
class _MenuItemData {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _MenuItemData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
}

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItemData> items;

  const _MenuSection({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  _MenuItem(
                    icon: item.icon,
                    title: item.title,
                    subtitle: item.subtitle,
                    color: item.color,
                    onTap: item.onTap,
                  ),
                  if (index < items.length - 1)
                    Divider(
                      height: 1,
                      indent: 70,
                      color: AppColors.border.withValues(alpha: 0.5),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
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
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SingleMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _SingleMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: _MenuItem(
        icon: icon,
        title: title,
        subtitle: subtitle,
        color: color,
        onTap: onTap,
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;

  const _LogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.logout_rounded,
                  color: AppColors.error,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Text(
                  'Logout',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
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
