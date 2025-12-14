import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Countdown timer widget for auctions
class CountdownTimer extends StatefulWidget {
  final DateTime endTime;
  final TextStyle? textStyle;
  final VoidCallback? onEnd;
  final bool showLabel;
  final bool compact;

  const CountdownTimer({
    super.key,
    required this.endTime,
    this.textStyle,
    this.onEnd,
    this.showLabel = true,
    this.compact = false,
  });

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Timer _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _calculateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _calculateRemaining();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _calculateRemaining() {
    final now = DateTime.now();
    final diff = widget.endTime.difference(now);

    if (diff.isNegative) {
      _remaining = Duration.zero;
      _timer.cancel();
      widget.onEnd?.call();
    } else {
      _remaining = diff;
    }

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_remaining == Duration.zero) {
      return Text(
        'Ended',
        style: widget.textStyle ??
            Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
      );
    }

    if (widget.compact) {
      return Text(
        _formatCompact(),
        style: widget.textStyle ?? Theme.of(context).textTheme.bodyMedium,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showLabel)
          Text(
            'Ends in',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_remaining.inDays > 0) ...[
              _TimeBox(value: _remaining.inDays, label: 'd'),
              const SizedBox(width: 4),
            ],
            _TimeBox(value: _remaining.inHours.remainder(24), label: 'h'),
            const SizedBox(width: 4),
            _TimeBox(value: _remaining.inMinutes.remainder(60), label: 'm'),
            const SizedBox(width: 4),
            _TimeBox(
              value: _remaining.inSeconds.remainder(60),
              label: 's',
              highlight: _remaining.inHours == 0,
            ),
          ],
        ),
      ],
    );
  }

  String _formatCompact() {
    final days = _remaining.inDays;
    final hours = _remaining.inHours.remainder(24);
    final minutes = _remaining.inMinutes.remainder(60);
    final seconds = _remaining.inSeconds.remainder(60);

    if (days > 0) {
      return '${days}d ${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}

class _TimeBox extends StatelessWidget {
  final int value;
  final String label;
  final bool highlight;

  const _TimeBox({
    required this.value,
    required this.label,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.error.withValues(alpha: 0.1)
            : AppColors.primaryLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value.toString().padLeft(2, '0'),
            style: TextStyle(
              color: highlight ? AppColors.error : AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: highlight
                  ? AppColors.error.withValues(alpha: 0.7)
                  : AppColors.primary.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Auction timer that shows either countdown or "Starting in"
class AuctionTimer extends StatelessWidget {
  final DateTime? startTime;
  final DateTime? endTime;
  final String status;

  const AuctionTimer({
    super.key,
    this.startTime,
    this.endTime,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    if (status == 'live' && endTime != null) {
      return CountdownTimer(endTime: endTime!);
    }

    if (status == 'upcoming' && startTime != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Starts in',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 4),
          CountdownTimer(
            endTime: startTime!,
            showLabel: false,
          ),
        ],
      );
    }

    return Text(
      'Auction Ended',
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
    );
  }
}
