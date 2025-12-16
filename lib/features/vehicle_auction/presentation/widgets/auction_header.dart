import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/domain/entities/auction.dart';

class AuctionHeader extends StatefulWidget {
  final Auction auction;
  final int vehicleCount;
  final int filteredCount;
  final bool isRealtimeActive;

  const AuctionHeader({
    super.key,
    required this.auction,
    this.vehicleCount = 0,
    this.filteredCount = 0,
    this.isRealtimeActive = false,
  });

  @override
  State<AuctionHeader> createState() => _AuctionHeaderState();
}

class _AuctionHeaderState extends State<AuctionHeader> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _calculateRemaining();
    _startTimer();
  }

  @override
  void didUpdateWidget(AuctionHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.auction.id != widget.auction.id) {
      _calculateRemaining();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _calculateRemaining() {
    final now = DateTime.now();
    final auction = widget.auction;

    if (auction.isLive && auction.endDate != null) {
      _remaining = auction.endDate!.difference(now);
    } else if (auction.isUpcoming && auction.startDate != null) {
      _remaining = auction.startDate!.difference(now);
    } else {
      _remaining = Duration.zero;
    }

    if (_remaining.isNegative) {
      _remaining = Duration.zero;
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _calculateRemaining();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: _getHeaderGradient(),
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Status Badge + Real-time indicator
          Row(
            children: [
              _buildStatusBadge(),
              const Spacer(),
              if (widget.isRealtimeActive) _buildRealtimeIndicator(),
            ],
          ),
          const SizedBox(height: 12),

          // Auction Name
          Text(
            widget.auction.name,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),

          // Info Chips Row
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildInfoChip(
                icon: Icons.category_outlined,
                label: widget.auction.eventType.displayName,
              ),
              _buildInfoChip(
                icon: Icons.wifi_tethering,
                label: widget.auction.mode.displayName,
              ),
              _buildInfoChip(
                icon: Icons.directions_car_outlined,
                label: '${widget.vehicleCount} Vehicles',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Countdown Timer
          _buildCountdownSection(),

          // Filter Status (if filtered)
          if (widget.filteredCount != widget.vehicleCount) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.filter_list,
                    size: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Showing ${widget.filteredCount} of ${widget.vehicleCount}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  LinearGradient _getHeaderGradient() {
    if (widget.auction.isLive) {
      return AppColors.liveGradient;
    } else if (widget.auction.isUpcoming) {
      return AppColors.primaryGradient;
    }
    return AppColors.darkGradient;
  }

  Widget _buildStatusBadge() {
    Color bgColor;
    String label;
    IconData? icon;

    switch (widget.auction.status) {
      case AuctionStatus.live:
        bgColor = Colors.white;
        label = 'LIVE NOW';
        icon = Icons.circle;
        break;
      case AuctionStatus.upcoming:
        bgColor = Colors.white.withValues(alpha: 0.2);
        label = 'UPCOMING';
        break;
      case AuctionStatus.ended:
        bgColor = Colors.white.withValues(alpha: 0.2);
        label = 'ENDED';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null && widget.auction.isLive) ...[
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.3, end: 1.0),
              duration: const Duration(milliseconds: 800),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Icon(
                    icon,
                    size: 8,
                    color: AppColors.error,
                  ),
                );
              },
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: widget.auction.isLive ? AppColors.success : Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRealtimeIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.accentLight,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentLight.withValues(alpha: 0.5),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'LIVE',
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: Colors.white.withValues(alpha: 0.8),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownSection() {
    if (_remaining == Duration.zero && widget.auction.isEnded) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Auction has ended',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      );
    }

    final String label = widget.auction.isLive ? 'Ends in' : 'Starts in';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.access_time_rounded,
            size: 20,
            color: Colors.white.withValues(alpha: 0.8),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _formatDuration(_remaining),
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const Spacer(),
          if (widget.auction.startDate != null || widget.auction.endDate != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (widget.auction.startDate != null)
                  Text(
                    'Start: ${_formatDate(widget.auction.startDate!)}',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                if (widget.auction.endDate != null)
                  Text(
                    'End: ${_formatDate(widget.auction.endDate!)}',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours.remainder(24)}h ${duration.inMinutes.remainder(60)}m';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m ${duration.inSeconds.remainder(60)}s';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds.remainder(60)}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = _getMonthName(date.month);
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final period = date.hour >= 12 ? 'PM' : 'AM';
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day $month, $hour:$minute $period';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}
