import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/domain/entities/bid.dart';

class BidHistoryPreview extends StatelessWidget {
  final List<Bid> bids;
  final int maxItems;
  final VoidCallback? onViewAll;

  const BidHistoryPreview({
    super.key,
    required this.bids,
    this.maxItems = 3,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    if (bids.isEmpty) {
      return _buildEmptyState();
    }

    final displayBids = bids.take(maxItems).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Bids',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            if (bids.length > maxItems && onViewAll != null)
              GestureDetector(
                onTap: onViewAll,
                child: Text(
                  'View All (${bids.length})',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.accent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // Bid List
        ...displayBids.asMap().entries.map((entry) {
          final index = entry.key;
          final bid = entry.value;
          return _buildBidItem(bid, isTop: index == 0);
        }),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.gavel_outlined,
              color: AppColors.textTertiary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No bids yet',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  'Be the first to place a bid!',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBidItem(Bid bid, {bool isTop = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isTop ? AppColors.successLight : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isTop ? AppColors.success.withValues(alpha: 0.3) : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          // Position Badge
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isTop ? AppColors.success : AppColors.background,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isTop
                  ? const Icon(
                      Icons.emoji_events,
                      size: 14,
                      color: Colors.white,
                    )
                  : Text(
                      bid.userName?.substring(0, 1).toUpperCase() ?? 'U',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 10),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _maskName(bid.userName ?? 'User'),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isTop ? AppColors.successDark : AppColors.textPrimary,
                      ),
                    ),
                    if (bid.isWinning || isTop) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Highest',
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  timeago.format(bid.timestamp),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),

          // Amount
          Text(
            bid.formattedAmount,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isTop ? AppColors.success : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _maskName(String name) {
    if (name.length <= 3) return name;
    final parts = name.split(' ');
    if (parts.length > 1) {
      // Mask last name
      return '${parts[0]} ${parts[1].substring(0, 1)}***';
    }
    // Mask single name
    return '${name.substring(0, 3)}***';
  }
}

/// Compact version for inline display
class BidHistoryCompact extends StatelessWidget {
  final List<Bid> bids;

  const BidHistoryCompact({
    super.key,
    required this.bids,
  });

  @override
  Widget build(BuildContext context) {
    if (bids.isEmpty) {
      return Text(
        'No bids yet',
        style: GoogleFonts.inter(
          fontSize: 12,
          color: AppColors.textTertiary,
        ),
      );
    }

    final topBid = bids.first;

    return Row(
      children: [
        const Icon(
          Icons.trending_up,
          size: 14,
          color: AppColors.success,
        ),
        const SizedBox(width: 4),
        Text(
          '${bids.length} bids',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 4,
          height: 4,
          decoration: const BoxDecoration(
            color: AppColors.textTertiary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Highest: ${topBid.formattedAmount}',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.success,
          ),
        ),
      ],
    );
  }
}
