import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

/// Professional shimmer loading widgets for skeleton screens
class AppShimmer extends StatelessWidget {
  final Widget child;

  const AppShimmer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      period: const Duration(milliseconds: 1200),
      child: child,
    );
  }
}

/// Shimmer box placeholder
class ShimmerBox extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = AppSizes.radiusMd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.shimmerBase,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Shimmer circle placeholder
class ShimmerCircle extends StatelessWidget {
  final double size;

  const ShimmerCircle({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.shimmerBase,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Auction card shimmer skeleton
class AuctionCardShimmer extends StatelessWidget {
  const AuctionCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        width: AppSizes.auctionCardWidth,
        margin: const EdgeInsets.only(right: AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            ShimmerBox(
              height: AppSizes.auctionCardImageHeight,
              borderRadius: AppSizes.radiusLg,
            ),
            Padding(
              padding: AppSizes.cardPaddingCompact,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  const ShimmerBox(width: 180, height: 20),
                  const SizedBox(height: AppSizes.sm),
                  // Subtitle
                  const ShimmerBox(width: 120, height: 14),
                  const SizedBox(height: AppSizes.md),
                  // Price row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const ShimmerBox(width: 100, height: 24),
                      ShimmerBox(
                        width: 60,
                        height: 28,
                        borderRadius: AppSizes.radiusSm,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Vehicle list item shimmer skeleton
class VehicleItemShimmer extends StatelessWidget {
  const VehicleItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.md),
        padding: AppSizes.cardPaddingCompact,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: Row(
          children: [
            // Image
            ShimmerBox(
              width: 100,
              height: 80,
              borderRadius: AppSizes.radiusSm,
            ),
            const SizedBox(width: AppSizes.md),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerBox(width: double.infinity, height: 18),
                  const SizedBox(height: AppSizes.sm),
                  const ShimmerBox(width: 150, height: 14),
                  const SizedBox(height: AppSizes.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const ShimmerBox(width: 80, height: 20),
                      ShimmerBox(
                        width: 50,
                        height: 24,
                        borderRadius: AppSizes.radiusSm,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Home page shimmer skeleton
class HomePageShimmer extends StatelessWidget {
  const HomePageShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSizes.screenPadding,
      child: AppShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome banner
            ShimmerBox(
              height: 160,
              borderRadius: AppSizes.radiusLg,
            ),
            const SizedBox(height: AppSizes.lg),

            // Quick actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                4,
                (_) => Column(
                  children: [
                    const ShimmerCircle(size: 56),
                    const SizedBox(height: AppSizes.sm),
                    const ShimmerBox(width: 50, height: 12),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.xl),

            // Section header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const ShimmerBox(width: 120, height: 22),
                ShimmerBox(
                  width: 60,
                  height: 18,
                  borderRadius: AppSizes.radiusSm,
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),

            // Auction cards
            SizedBox(
              height: 320,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                itemBuilder: (_, __) => const AuctionCardShimmer(),
              ),
            ),
            const SizedBox(height: AppSizes.xl),

            // Another section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const ShimmerBox(width: 140, height: 22),
                ShimmerBox(
                  width: 60,
                  height: 18,
                  borderRadius: AppSizes.radiusSm,
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),

            // List items
            ...List.generate(3, (_) => const VehicleItemShimmer()),
          ],
        ),
      ),
    );
  }
}

/// Profile shimmer skeleton
class ProfileShimmer extends StatelessWidget {
  const ProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSizes.screenPadding,
      child: AppShimmer(
        child: Column(
          children: [
            const SizedBox(height: AppSizes.lg),
            // Avatar
            const ShimmerCircle(size: 100),
            const SizedBox(height: AppSizes.md),
            // Name
            const ShimmerBox(width: 150, height: 24),
            const SizedBox(height: AppSizes.sm),
            // Phone
            const ShimmerBox(width: 120, height: 16),
            const SizedBox(height: AppSizes.xl),
            // Menu items
            ...List.generate(
              5,
              (_) => Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.md),
                child: ShimmerBox(
                  height: 56,
                  borderRadius: AppSizes.radiusMd,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
