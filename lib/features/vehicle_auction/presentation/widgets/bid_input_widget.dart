import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';

class BidInputWidget extends StatefulWidget {
  final double currentBid;
  final double minimumBid;
  final double bidIncrement;
  final ValueChanged<double> onBidChanged;
  final bool enabled;

  const BidInputWidget({
    super.key,
    required this.currentBid,
    required this.minimumBid,
    required this.bidIncrement,
    required this.onBidChanged,
    this.enabled = true,
  });

  @override
  State<BidInputWidget> createState() => _BidInputWidgetState();
}

class _BidInputWidgetState extends State<BidInputWidget> {
  late TextEditingController _controller;
  late double _bidAmount;

  @override
  void initState() {
    super.initState();
    _bidAmount = widget.minimumBid;
    _controller = TextEditingController(text: _formatValue(_bidAmount));
  }

  @override
  void didUpdateWidget(BidInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.minimumBid != widget.minimumBid) {
      _bidAmount = widget.minimumBid;
      _controller.text = _formatValue(_bidAmount);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatValue(double value) {
    return value.toStringAsFixed(0);
  }

  String _formatDisplay(double value) {
    if (value >= 10000000) {
      return '₹${(value / 10000000).toStringAsFixed(2)} Cr';
    } else if (value >= 100000) {
      return '₹${(value / 100000).toStringAsFixed(2)} L';
    } else if (value >= 1000) {
      return '₹${(value / 1000).toStringAsFixed(1)}K';
    }
    return '₹${value.toStringAsFixed(0)}';
  }

  void _increment() {
    if (!widget.enabled) return;
    setState(() {
      _bidAmount += widget.bidIncrement;
      _controller.text = _formatValue(_bidAmount);
    });
    widget.onBidChanged(_bidAmount);
    HapticFeedback.lightImpact();
  }

  void _decrement() {
    if (!widget.enabled) return;
    if (_bidAmount - widget.bidIncrement >= widget.minimumBid) {
      setState(() {
        _bidAmount -= widget.bidIncrement;
        _controller.text = _formatValue(_bidAmount);
      });
      widget.onBidChanged(_bidAmount);
      HapticFeedback.lightImpact();
    }
  }

  void _onTextChanged(String value) {
    final parsed = double.tryParse(value);
    if (parsed != null && parsed >= widget.minimumBid) {
      _bidAmount = parsed;
      widget.onBidChanged(_bidAmount);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Text(
            'Your Bid Amount',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),

          // Input Row
          Row(
            children: [
              // Decrement Button
              _buildControlButton(
                icon: Icons.remove,
                onTap: _decrement,
                enabled: widget.enabled && _bidAmount > widget.minimumBid,
              ),
              const SizedBox(width: 12),

              // Input Field
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '₹',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          enabled: widget.enabled,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: _onTextChanged,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Increment Button
              _buildControlButton(
                icon: Icons.add,
                onTap: _increment,
                enabled: widget.enabled,
                isPrimary: true,
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Info Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Min: ${_formatDisplay(widget.minimumBid)}',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.textTertiary,
                ),
              ),
              Text(
                '+${_formatDisplay(widget.bidIncrement)} per tap',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    bool enabled = true,
    bool isPrimary = false,
  }) {
    final color = !enabled
        ? AppColors.textTertiary
        : isPrimary
            ? AppColors.accent
            : AppColors.textSecondary;

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isPrimary
              ? AppColors.accentSurface
              : AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: enabled ? color : AppColors.border,
          ),
        ),
        child: Icon(
          icon,
          color: color,
          size: 22,
        ),
      ),
    );
  }
}

/// Compact version for quick actions
class BidQuickButtons extends StatelessWidget {
  final double bidIncrement;
  final ValueChanged<double> onQuickBid;
  final bool enabled;

  const BidQuickButtons({
    super.key,
    required this.bidIncrement,
    required this.onQuickBid,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final quickAmounts = [
      bidIncrement,
      bidIncrement * 2,
      bidIncrement * 5,
      bidIncrement * 10,
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: quickAmounts.map((amount) {
        return _buildQuickButton(amount);
      }).toList(),
    );
  }

  Widget _buildQuickButton(double amount) {
    String label;
    if (amount >= 100000) {
      label = '+${(amount / 100000).toStringAsFixed(0)}L';
    } else if (amount >= 1000) {
      label = '+${(amount / 1000).toStringAsFixed(0)}K';
    } else {
      label = '+${amount.toStringAsFixed(0)}';
    }

    return GestureDetector(
      onTap: enabled ? () => onQuickBid(amount) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: enabled ? AppColors.primarySurface : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: enabled ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: enabled ? AppColors.primary : AppColors.textTertiary,
          ),
        ),
      ),
    );
  }
}
