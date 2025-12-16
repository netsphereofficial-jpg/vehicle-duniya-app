import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/domain/entities/bid.dart';
import '../../../../shared/domain/entities/vehicle_item.dart';
import '../bloc/vehicle_auction_bloc.dart';
import 'bid_history_preview.dart';
import 'bid_input_widget.dart';

class QuickBidBottomSheet extends StatefulWidget {
  final VehicleItem vehicle;
  final List<Bid> bids;
  final bool isInWatchlist;
  final VoidCallback onWatchlistToggle;

  const QuickBidBottomSheet({
    super.key,
    required this.vehicle,
    required this.bids,
    required this.isInWatchlist,
    required this.onWatchlistToggle,
  });

  static Future<void> show(
    BuildContext context, {
    required VehicleItem vehicle,
    required List<Bid> bids,
    required bool isInWatchlist,
    required VoidCallback onWatchlistToggle,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuickBidBottomSheet(
        vehicle: vehicle,
        bids: bids,
        isInWatchlist: isInWatchlist,
        onWatchlistToggle: onWatchlistToggle,
      ),
    );
  }

  @override
  State<QuickBidBottomSheet> createState() => _QuickBidBottomSheetState();
}

class _QuickBidBottomSheetState extends State<QuickBidBottomSheet> {
  late PageController _pageController;
  late double _bidAmount;
  int _currentImageIndex = 0;
  bool _showSpecs = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _bidAmount = widget.vehicle.minimumBid;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              _buildHandle(),

              // Content
              Expanded(
                child: BlocListener<VehicleAuctionBloc, VehicleAuctionState>(
                  listenWhen: (prev, curr) =>
                      prev.status != curr.status,
                  listener: (context, state) {
                    if (state.isBidSuccess) {
                      _showSuccessSnackbar(state.bidSuccessMessage ?? 'Bid placed!');
                      context.read<VehicleAuctionBloc>().add(const BidStatusReset());
                    } else if (state.isBidError) {
                      _showErrorSnackbar(state.errorMessage ?? 'Failed to place bid');
                      context.read<VehicleAuctionBloc>().add(const BidStatusReset());
                    }
                  },
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image Carousel
                        _buildImageCarousel(),
                        const SizedBox(height: 16),

                        // Vehicle Info
                        _buildVehicleInfo(),
                        const SizedBox(height: 16),

                        // Expandable Specs
                        _buildSpecsSection(),
                        const SizedBox(height: 20),

                        // Current Bid Section
                        _buildCurrentBidSection(),
                        const SizedBox(height: 16),

                        // Bid Input
                        BidInputWidget(
                          currentBid: widget.vehicle.currentBid,
                          minimumBid: widget.vehicle.minimumBid,
                          bidIncrement: widget.vehicle.bidIncrement,
                          onBidChanged: (amount) {
                            setState(() => _bidAmount = amount);
                          },
                          enabled: widget.vehicle.isLive,
                        ),
                        const SizedBox(height: 12),

                        // Quick Bid Buttons
                        BidQuickButtons(
                          bidIncrement: widget.vehicle.bidIncrement,
                          onQuickBid: (amount) {
                            setState(() {
                              _bidAmount += amount;
                            });
                          },
                          enabled: widget.vehicle.isLive,
                        ),
                        const SizedBox(height: 20),

                        // Action Buttons
                        _buildActionButtons(context),
                        const SizedBox(height: 20),

                        // Bid History
                        BidHistoryPreview(bids: widget.bids),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHandle() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.border,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildImageCarousel() {
    final images = widget.vehicle.images;
    if (images.isEmpty) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          color: AppColors.shimmerBase,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Icon(
            Icons.directions_car_outlined,
            size: 64,
            color: AppColors.textTertiary,
          ),
        ),
      );
    }

    return Column(
      children: [
        // Image Carousel
        SizedBox(
          height: 220,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: images.length,
                  onPageChanged: (index) {
                    setState(() => _currentImageIndex = index);
                  },
                  itemBuilder: (context, index) {
                    return CachedNetworkImage(
                      imageUrl: images[index],
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
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.shimmerBase,
                        child: const Icon(
                          Icons.broken_image_outlined,
                          color: AppColors.textTertiary,
                          size: 40,
                        ),
                      ),
                    );
                  },
                ),

                // Status Badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: _buildStatusBadge(),
                ),

                // Watchlist Button
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: widget.onWatchlistToggle,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.isInWatchlist
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        color: widget.isInWatchlist
                            ? AppColors.warning
                            : AppColors.textSecondary,
                        size: 20,
                      ),
                    ),
                  ),
                ),

                // Image Counter
                if (images.length > 1)
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_currentImageIndex + 1}/${images.length}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Dots Indicator
        if (images.length > 1) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(images.length, (index) {
              return Container(
                width: _currentImageIndex == index ? 20 : 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: _currentImageIndex == index
                      ? AppColors.primary
                      : AppColors.border,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusBadge() {
    Color bgColor;
    String label;

    switch (widget.vehicle.status) {
      case 'live':
        bgColor = AppColors.success;
        label = 'LIVE';
        break;
      case 'upcoming':
        bgColor = AppColors.upcoming;
        label = 'UPCOMING';
        break;
      case 'ended':
        bgColor = AppColors.ended;
        label = 'ENDED';
        break;
      default:
        bgColor = AppColors.textSecondary;
        label = widget.vehicle.status.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.vehicle.isLive) ...[
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Make/Model + Year
        Text(
          widget.vehicle.fullDescription,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),

        // Info Row
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            if (widget.vehicle.rcNo != null)
              _buildInfoChip(Icons.badge_outlined, widget.vehicle.rcNo!),
            if (widget.vehicle.yardCity != null)
              _buildInfoChip(
                Icons.location_on_outlined,
                widget.vehicle.location,
              ),
            if (widget.vehicle.fuelType != null)
              _buildInfoChip(
                Icons.local_gas_station_outlined,
                widget.vehicle.fuelType!,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecsSection() {
    return GestureDetector(
      onTap: () => setState(() => _showSpecs = !_showSpecs),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Vehicle Specifications',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _showSpecs
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),

            // Specs Content
            if (_showSpecs)
              Container(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: Column(
                  children: [
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    _buildSpecRow('Engine No', widget.vehicle.engineNo),
                    _buildSpecRow('Chassis No', widget.vehicle.chassisNo),
                    _buildSpecRow('Contract No', widget.vehicle.contractNo),
                    _buildSpecRow('Yard', widget.vehicle.yardName),
                    _buildSpecRow('Year', widget.vehicle.yom?.toString()),
                    _buildSpecRow(
                      'RC Available',
                      widget.vehicle.rcAvailable ? 'Yes' : 'No',
                    ),
                    if (widget.vehicle.remark != null &&
                        widget.vehicle.remark!.isNotEmpty)
                      _buildSpecRow('Remark', widget.vehicle.remark),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textTertiary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentBidSection() {
    final hasCurrentBid = widget.vehicle.currentBid > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Base Price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Base Price',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatPrice(widget.vehicle.basePrice),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    decoration:
                        hasCurrentBid ? TextDecoration.lineThrough : null,
                    decorationColor: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withValues(alpha: 0.2),
          ),

          // Current Bid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        hasCurrentBid ? 'Current Bid' : 'Start Bid',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                      if (hasCurrentBid && widget.vehicle.isLive) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accentLight,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'LIVE',
                            style: GoogleFonts.inter(
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasCurrentBid
                        ? _formatPrice(widget.vehicle.currentBid)
                        : _formatPrice(widget.vehicle.basePrice),
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final isLive = widget.vehicle.isLive;

    return Row(
      children: [
        // Watchlist Button
        Expanded(
          child: OutlinedButton.icon(
            onPressed: widget.onWatchlistToggle,
            icon: Icon(
              widget.isInWatchlist ? Icons.bookmark : Icons.bookmark_border,
              size: 18,
            ),
            label: Text(
              widget.isInWatchlist ? 'Saved' : 'Save',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor:
                  widget.isInWatchlist ? AppColors.warning : AppColors.primary,
              side: BorderSide(
                color: widget.isInWatchlist
                    ? AppColors.warning
                    : AppColors.primary,
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Place Bid Button
        Expanded(
          flex: 2,
          child: BlocBuilder<VehicleAuctionBloc, VehicleAuctionState>(
            builder: (context, state) {
              final isLoading = state.isBidding;

              return ElevatedButton(
                onPressed: isLive && !isLoading
                    ? () => _placeBid(context)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.border,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.gavel, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            isLive
                                ? 'Place Bid ${_formatPrice(_bidAmount)}'
                                : 'Bidding Not Active',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _placeBid(BuildContext context) {
    HapticFeedback.mediumImpact();
    context.read<VehicleAuctionBloc>().add(
          VehicleBidRequested(
            vehicleId: widget.vehicle.id,
            amount: _bidAmount,
          ),
        );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
