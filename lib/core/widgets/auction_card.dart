import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../utils/currency_formatter.dart';
import 'app_image.dart';
import 'countdown_timer.dart';

/// Professional auction card with visual hierarchy
/// Optimized for readability and quick scanning
class AuctionCard extends StatelessWidget {
  final String id;
  final String name;
  final String? categoryName;
  final String? imageUrl;
  final int vehicleCount;
  final String status; // live, upcoming, ended
  final DateTime? startDate;
  final DateTime? endDate;
  final VoidCallback? onTap;

  const AuctionCard({
    super.key,
    required this.id,
    required this.name,
    this.categoryName,
    this.imageUrl,
    required this.vehicleCount,
    required this.status,
    this.startDate,
    this.endDate,
    this.onTap,
  });

  bool get isLive => status == 'live';
  bool get isUpcoming => status == 'upcoming';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppSizes.auctionCardWidth,
        margin: const EdgeInsets.only(right: AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          boxShadow: AppColors.cardShadow,
          border: isLive
              ? Border.all(color: AppColors.live.withValues(alpha: 0.3), width: 2)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with status badge
            _buildImageSection(),
            // Content
            _buildContentSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Stack(
      children: [
        // Image
        ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppSizes.radiusLg),
          ),
          child: AppImage(
            imageUrl: imageUrl,
            width: double.infinity,
            height: AppSizes.auctionCardImageHeight,
            fit: BoxFit.cover,
          ),
        ),
        // Gradient overlay for text readability
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.6),
                ],
              ),
            ),
          ),
        ),
        // Status badge
        Positioned(
          top: AppSizes.sm,
          left: AppSizes.sm,
          child: _buildStatusBadge(),
        ),
        // Vehicle count
        Positioned(
          bottom: AppSizes.sm,
          right: AppSizes.sm,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.sm,
              vertical: AppSizes.xs,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.directions_car_rounded,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '$vehicleCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: AppSizes.fontSm,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    Color bgColor;
    Color textColor = Colors.white;
    String text;
    IconData? icon;

    if (isLive) {
      bgColor = AppColors.live;
      text = 'LIVE';
      icon = Icons.circle;
    } else if (isUpcoming) {
      bgColor = AppColors.upcoming;
      text = 'UPCOMING';
    } else {
      bgColor = AppColors.ended;
      text = 'ENDED';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm,
        vertical: AppSizes.xs,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        boxShadow: isLive
            ? [
                BoxShadow(
                  color: AppColors.live.withValues(alpha: 0.4),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null && isLive) ...[
            Icon(icon, color: textColor, size: 8)
                .animate(onPlay: (c) => c.repeat())
                .fade(duration: 800.ms, begin: 0.3, end: 1)
                .then()
                .fade(duration: 800.ms, begin: 1, end: 0.3),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection(BuildContext context) {
    return Padding(
      padding: AppSizes.cardPaddingCompact,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Auction name - Large & Bold
          Text(
            name,
            style: const TextStyle(
              fontSize: AppSizes.fontLg,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSizes.xs),
          // Category
          if (categoryName != null)
            Text(
              categoryName!,
              style: const TextStyle(
                fontSize: AppSizes.fontSm,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          const SizedBox(height: AppSizes.md),
          // Timer or Date
          if (isLive && endDate != null)
            _buildLiveTimer()
          else if (isUpcoming && startDate != null)
            _buildUpcomingInfo()
          else
            _buildEndedInfo(),
        ],
      ),
    );
  }

  Widget _buildLiveTimer() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm,
        vertical: AppSizes.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.live.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        border: Border.all(
          color: AppColors.live.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.timer_outlined,
            color: AppColors.live,
            size: 20,
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ends in',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                CountdownTimer(
                  endTime: endDate!,
                  compact: true,
                  textStyle: const TextStyle(
                    fontSize: AppSizes.fontMd,
                    fontWeight: FontWeight.w700,
                    color: AppColors.live,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm,
        vertical: AppSizes.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.upcomingLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.schedule_rounded,
            color: AppColors.upcoming,
            size: 20,
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Starts in',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                CountdownTimer(
                  endTime: startDate!,
                  compact: true,
                  textStyle: const TextStyle(
                    fontSize: AppSizes.fontMd,
                    fontWeight: FontWeight.w700,
                    color: AppColors.upcoming,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEndedInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm,
        vertical: AppSizes.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.endedLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: AppColors.ended,
            size: 20,
          ),
          SizedBox(width: AppSizes.sm),
          Text(
            'Auction Ended',
            style: TextStyle(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w600,
              color: AppColors.ended,
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact vehicle item card for lists
class VehicleItemCard extends StatelessWidget {
  final String id;
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final double basePrice;
  final double currentBid;
  final String status;
  final bool isLive;
  final VoidCallback? onTap;

  const VehicleItemCard({
    super.key,
    required this.id,
    required this.title,
    this.subtitle,
    this.imageUrl,
    required this.basePrice,
    required this.currentBid,
    required this.status,
    this.isLive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.md),
        padding: AppSizes.cardPaddingCompact,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          boxShadow: AppColors.softShadow,
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              child: AppImage(
                imageUrl: imageUrl,
                width: 100,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: AppSizes.md),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: AppSizes.fontMd,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: AppSizes.fontSm,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: AppSizes.sm),
                  // Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentBid > 0 ? 'Current Bid' : 'Base Price',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textTertiary,
                            ),
                          ),
                          Text(
                            CurrencyFormatter.formatCompact(
                              currentBid > 0 ? currentBid : basePrice,
                            ),
                            style: TextStyle(
                              fontSize: AppSizes.fontLg,
                              fontWeight: FontWeight.w700,
                              color: isLive ? AppColors.accent : AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      if (isLive)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.sm,
                            vertical: AppSizes.xs,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppColors.accentGradient,
                            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                          ),
                          child: const Text(
                            'BID NOW',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
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
