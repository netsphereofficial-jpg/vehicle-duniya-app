import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/domain/entities/vehicle_item.dart';

class VehicleCard extends StatelessWidget {
  final VehicleItem vehicle;
  final VoidCallback onTap;
  final bool isInWatchlist;
  final VoidCallback? onWatchlistTap;

  const VehicleCard({
    super.key,
    required this.vehicle,
    required this.onTap,
    this.isInWatchlist = false,
    this.onWatchlistTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: AppColors.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            _buildImageSection(),

            // Content Section
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Make/Model
                  Text(
                    vehicle.fullDescription,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // RC Number
                  if (vehicle.rcNo != null && vehicle.rcNo!.isNotEmpty) ...[
                    Text(
                      vehicle.rcNo!,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],

                  // Yard City
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 12,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          vehicle.yardCity ?? '-',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppColors.textTertiary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Price Section
                  _buildPriceSection(),
                  const SizedBox(height: 8),

                  // Bid Button
                  _buildBidButton(),
                ],
              ),
            ),
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
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          child: AspectRatio(
            aspectRatio: 1.4,
            child: vehicle.hasImages
                ? CachedNetworkImage(
                    imageUrl: vehicle.primaryImage!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.shimmerBase,
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => _buildPlaceholder(),
                  )
                : _buildPlaceholder(),
          ),
        ),

        // Status Badge
        Positioned(
          top: 8,
          left: 8,
          child: _buildStatusBadge(),
        ),

        // Image Count Badge
        if (vehicle.imageCount > 1)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.photo_library_outlined,
                    size: 10,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${vehicle.imageCount}',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Watchlist Button
        if (onWatchlistTap != null)
          Positioned(
            bottom: 8,
            right: 8,
            child: GestureDetector(
              onTap: onWatchlistTap,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Icon(
                  isInWatchlist ? Icons.bookmark : Icons.bookmark_border,
                  size: 16,
                  color: isInWatchlist ? AppColors.warning : AppColors.textSecondary,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.shimmerBase,
      child: Center(
        child: Icon(
          Icons.directions_car_outlined,
          size: 40,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color badgeColor;
    String statusText;

    switch (vehicle.status) {
      case 'live':
        badgeColor = AppColors.live;
        statusText = 'LIVE';
        break;
      case 'upcoming':
        badgeColor = AppColors.upcoming;
        statusText = 'UPCOMING';
        break;
      case 'ended':
        badgeColor = AppColors.ended;
        statusText = 'ENDED';
        break;
      default:
        badgeColor = AppColors.textSecondary;
        statusText = vehicle.status.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (vehicle.isLive) ...[
            Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            statusText,
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection() {
    final hasCurrentBid = vehicle.currentBid > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Base Price
        Row(
          children: [
            Text(
              'Base: ',
              style: GoogleFonts.inter(
                fontSize: 10,
                color: AppColors.textTertiary,
              ),
            ),
            Text(
              _formatPrice(vehicle.basePrice),
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
                decoration: hasCurrentBid ? TextDecoration.lineThrough : null,
              ),
            ),
          ],
        ),

        // Current Bid
        if (hasCurrentBid) ...[
          const SizedBox(height: 2),
          Row(
            children: [
              Text(
                'Bid: ',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: AppColors.accent,
                ),
              ),
              Text(
                _formatPrice(vehicle.currentBid),
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildBidButton() {
    final isLive = vehicle.isLive;
    final buttonColor = isLive ? AppColors.success : AppColors.primary;
    final buttonText = isLive ? 'Bid Now' : 'View';

    return SizedBox(
      width: double.infinity,
      height: 32,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        child: Text(
          buttonText,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    if (price >= 10000000) {
      return '₹${(price / 10000000).toStringAsFixed(2)} Cr';
    } else if (price >= 100000) {
      return '₹${(price / 100000).toStringAsFixed(2)} L';
    } else if (price >= 1000) {
      return '₹${(price / 1000).toStringAsFixed(1)}K';
    }
    return '₹${price.toStringAsFixed(0)}';
  }
}
