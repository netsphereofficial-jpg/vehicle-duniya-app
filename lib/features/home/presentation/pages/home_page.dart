import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/auction_card.dart';
import '../../../../core/widgets/shimmer_widgets.dart';
import '../../../../shared/domain/entities/auction.dart';
import '../bloc/home_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<HomeBloc>()..add(const HomeLoadRequested()),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            // Show shimmer skeleton while loading initially
            if (state.isLoading && state.liveAuctions.isEmpty) {
              return const HomePageShimmer();
            }

            if (state.hasError && state.liveAuctions.isEmpty) {
              return AppError(
                message: state.errorMessage ?? AppStrings.somethingWentWrong,
                onRetry: () {
                  context.read<HomeBloc>().add(const HomeLoadRequested());
                },
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<HomeBloc>().add(const HomeRefreshRequested());
                // Wait for update
                await Future.delayed(const Duration(milliseconds: 500));
              },
              color: AppColors.primary,
              backgroundColor: AppColors.card,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  // Custom App Bar
                  _buildAppBar(context),

                  // Content
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Welcome Banner with animation
                        _WelcomeBanner().animate().fadeIn(duration: 400.ms).slideY(
                              begin: -0.1,
                              end: 0,
                              duration: 400.ms,
                              curve: Curves.easeOut,
                            ),

                        const SizedBox(height: AppSizes.lg),

                        // Quick Actions with staggered animation
                        const _QuickActionsSection(),

                        const SizedBox(height: AppSizes.xl),

                        // Live Auctions Section
                        _AuctionsSection(
                          title: AppStrings.liveAuctions,
                          subtitle: 'Bid now on active auctions',
                          auctions: state.liveAuctions,
                          isLive: true,
                          emptyTitle: 'No Live Auctions',
                          emptySubtitle: 'Check back later for live auctions',
                          emptyIcon: Icons.gavel_rounded,
                          onViewAll: () => context.push('/vehicle-auction'),
                        ),

                        const SizedBox(height: AppSizes.xl),

                        // Upcoming Auctions Section
                        _AuctionsSection(
                          title: AppStrings.upcomingAuctions,
                          subtitle: 'Get ready to bid',
                          auctions: state.upcomingAuctions,
                          isLive: false,
                          emptyTitle: 'No Upcoming Auctions',
                          emptySubtitle: 'New auctions coming soon',
                          emptyIcon: Icons.schedule_rounded,
                          onViewAll: () => context.push('/vehicle-auction'),
                        ),

                        const SizedBox(height: AppSizes.xxl),

                        // Featured Categories
                        const _CategoriesSection(),

                        const SizedBox(height: AppSizes.xxxl),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: AppColors.scaffoldBackground,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: AppSizes.appBarHeight,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: const Icon(
              Icons.directions_car_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.appName,
                style: TextStyle(
                  fontSize: AppSizes.fontXl,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Auction Platform',
                style: TextStyle(
                  fontSize: AppSizes.fontXs,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        // Search Button
        IconButton(
          onPressed: () {
            // TODO: Navigate to search
          },
          icon: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              boxShadow: AppColors.softShadow,
            ),
            child: const Icon(
              Icons.search_rounded,
              color: AppColors.textPrimary,
              size: 22,
            ),
          ),
        ),
        // Notifications Button
        IconButton(
          onPressed: () => context.push('/notifications'),
          icon: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  boxShadow: AppColors.softShadow,
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.textPrimary,
                  size: 22,
                ),
              ),
              // Notification badge
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.card, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSizes.sm),
      ],
    );
  }
}

/// Professional Welcome Banner
class _WelcomeBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: AppSizes.screenPaddingHorizontal,
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome Back!',
                  style: TextStyle(
                    fontSize: AppSizes.fontXxl,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                Text(
                  'Discover amazing deals on vehicles and properties',
                  style: TextStyle(
                    fontSize: AppSizes.fontMd,
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppSizes.md),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.md,
                    vertical: AppSizes.sm,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppSizes.radiusRound),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.local_fire_department_rounded,
                        color: AppColors.accent,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Live Auctions Available',
                        style: TextStyle(
                          fontSize: AppSizes.fontSm,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
            child: const Icon(
              Icons.gavel_rounded,
              color: Colors.white,
              size: 48,
            ),
          ),
        ],
      ),
    );
  }
}

/// Quick Actions Grid
class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection();

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickAction(
        icon: Icons.directions_car_rounded,
        label: 'Vehicles',
        color: AppColors.primary,
        route: '/vehicle-auction',
      ),
      _QuickAction(
        icon: Icons.home_work_rounded,
        label: 'Properties',
        color: AppColors.accent,
        route: '/property-auction',
      ),
      _QuickAction(
        icon: Icons.storefront_rounded,
        label: 'Car Bazaar',
        color: AppColors.success,
        route: '/car-bazaar',
      ),
      _QuickAction(
        icon: Icons.gavel_rounded,
        label: 'My Bids',
        color: AppColors.upcoming,
        route: '/bidding',
      ),
    ];

    return Padding(
      padding: AppSizes.screenPaddingHorizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: actions.asMap().entries.map((entry) {
          final index = entry.key;
          final action = entry.value;
          return Expanded(
            child: _QuickActionItem(action: action)
                .animate()
                .fadeIn(
                  duration: 300.ms,
                  delay: (100 * index).ms,
                )
                .slideY(
                  begin: 0.2,
                  end: 0,
                  duration: 300.ms,
                  delay: (100 * index).ms,
                  curve: Curves.easeOut,
                ),
          );
        }).toList(),
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final String route;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.route,
  });
}

class _QuickActionItem extends StatelessWidget {
  final _QuickAction action;

  const _QuickActionItem({required this.action});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(action.route),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: action.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              border: Border.all(
                color: action.color.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: Icon(
              action.icon,
              color: action.color,
              size: 28,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            action.label,
            style: TextStyle(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Auctions Section with horizontal scroll
class _AuctionsSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Auction> auctions;
  final bool isLive;
  final String emptyTitle;
  final String emptySubtitle;
  final IconData emptyIcon;
  final VoidCallback onViewAll;

  const _AuctionsSection({
    required this.title,
    required this.subtitle,
    required this.auctions,
    required this.isLive,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.emptyIcon,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: AppSizes.screenPaddingHorizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (isLive) ...[
                        Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: AppColors.live,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.live.withValues(alpha: 0.4),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        )
                            .animate(onPlay: (c) => c.repeat())
                            .fade(duration: 1000.ms, begin: 0.5, end: 1)
                            .then()
                            .fade(duration: 1000.ms, begin: 1, end: 0.5),
                      ],
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: AppSizes.fontXl,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: AppSizes.fontSm,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: onViewAll,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.md,
                    vertical: AppSizes.sm,
                  ),
                  backgroundColor: AppColors.primarySurface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusRound),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppStrings.viewAll,
                      style: TextStyle(
                        fontSize: AppSizes.fontSm,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSizes.md),

        // Auctions List
        if (auctions.isEmpty)
          Padding(
            padding: AppSizes.screenPaddingHorizontal,
            child: _EmptyAuctionsCard(
              title: emptyTitle,
              subtitle: emptySubtitle,
              icon: emptyIcon,
            ),
          )
        else
          SizedBox(
            height: 320,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: AppSizes.screenPaddingHorizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: auctions.length,
              itemBuilder: (context, index) {
                final auction = auctions[index];
                return AuctionCard(
                  id: auction.id,
                  name: auction.name,
                  categoryName: auction.categoryName,
                  imageUrl: auction.imageUrl,
                  vehicleCount: auction.vehicleCount,
                  status: auction.status.name,
                  startDate: auction.startDate,
                  endDate: auction.endDate,
                  onTap: () => context.push('/auction/${auction.id}'),
                ).animate().fadeIn(
                      duration: 300.ms,
                      delay: (50 * index).ms,
                    );
              },
            ),
          ),
      ],
    );
  }
}

/// Empty state card for auctions
class _EmptyAuctionsCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _EmptyAuctionsCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.xl),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.shimmerBase,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 40,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            title,
            style: TextStyle(
              fontSize: AppSizes.fontLg,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: AppSizes.fontSm,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Categories Section
class _CategoriesSection extends StatelessWidget {
  const _CategoriesSection();

  @override
  Widget build(BuildContext context) {
    final categories = [
      _CategoryItem(
        name: 'Cars',
        icon: Icons.directions_car_rounded,
        color: AppColors.primary,
        count: '120+',
      ),
      _CategoryItem(
        name: 'Bikes',
        icon: Icons.two_wheeler_rounded,
        color: AppColors.accent,
        count: '80+',
      ),
      _CategoryItem(
        name: 'Trucks',
        icon: Icons.local_shipping_rounded,
        color: AppColors.success,
        count: '45+',
      ),
      _CategoryItem(
        name: 'Properties',
        icon: Icons.apartment_rounded,
        color: AppColors.upcoming,
        count: '30+',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: AppSizes.screenPaddingHorizontal,
          child: Text(
            'Browse Categories',
            style: TextStyle(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: AppSizes.md),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: AppSizes.screenPaddingHorizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Container(
                width: 100,
                margin: const EdgeInsets.only(right: AppSizes.md),
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  border: Border.all(
                    color: category.color.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      category.icon,
                      color: category.color,
                      size: 32,
                    ),
                    const SizedBox(height: AppSizes.sm),
                    Text(
                      category.name,
                      style: TextStyle(
                        fontSize: AppSizes.fontSm,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      category.count,
                      style: TextStyle(
                        fontSize: AppSizes.fontXs,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(
                    duration: 300.ms,
                    delay: (80 * index).ms,
                  );
            },
          ),
        ),
      ],
    );
  }
}

class _CategoryItem {
  final String name;
  final IconData icon;
  final Color color;
  final String count;

  const _CategoryItem({
    required this.name,
    required this.icon,
    required this.color,
    required this.count,
  });
}
