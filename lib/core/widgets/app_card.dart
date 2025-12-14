import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

/// Base card widget
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? borderRadius;
  final Color? color;
  final VoidCallback? onTap;
  final List<BoxShadow>? boxShadow;
  final Border? border;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.color,
    this.onTap,
    this.boxShadow,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? AppColors.card,
        borderRadius: BorderRadius.circular(borderRadius ?? AppSizes.radiusMd),
        boxShadow: boxShadow ?? AppColors.cardShadow,
        border: border,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius:
              BorderRadius.circular(borderRadius ?? AppSizes.radiusMd),
          child: Padding(
            padding: padding ?? AppSizes.cardPadding,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Status badge widget
class StatusBadge extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;
  final double? fontSize;

  const StatusBadge({
    super.key,
    required this.text,
    required this.backgroundColor,
    this.textColor = Colors.white,
    this.icon,
    this.fontSize,
  });

  factory StatusBadge.live() {
    return const StatusBadge(
      text: 'LIVE',
      backgroundColor: AppColors.live,
      icon: Icons.circle,
    );
  }

  factory StatusBadge.upcoming() {
    return const StatusBadge(
      text: 'UPCOMING',
      backgroundColor: AppColors.upcoming,
    );
  }

  factory StatusBadge.ended() {
    return const StatusBadge(
      text: 'ENDED',
      backgroundColor: AppColors.ended,
    );
  }

  factory StatusBadge.sold() {
    return const StatusBadge(
      text: 'SOLD',
      backgroundColor: AppColors.sold,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 8,
              color: textColor,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: fontSize ?? 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Info row widget for details
class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.labelStyle,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 16,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: labelStyle ??
                  Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: valueStyle ?? Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

/// Price widget with label
class PriceWidget extends StatelessWidget {
  final String label;
  final String price;
  final bool highlight;
  final TextStyle? labelStyle;
  final TextStyle? priceStyle;

  const PriceWidget({
    super.key,
    required this.label,
    required this.price,
    this.highlight = false,
    this.labelStyle,
    this.priceStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: labelStyle ??
              Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
        ),
        const SizedBox(height: 4),
        Text(
          price,
          style: priceStyle ??
              Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: highlight ? AppColors.accent : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
        ),
      ],
    );
  }
}
