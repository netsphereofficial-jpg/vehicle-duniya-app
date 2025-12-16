import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../bloc/vehicle_auction_bloc.dart';

class VehicleFilterBar extends StatelessWidget {
  final VehicleFilter currentFilter;
  final String searchQuery;
  final List<String> availableMakes;
  final List<String> availableCities;
  final List<String> availableFuelTypes;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<VehicleFilter> onFilterChanged;

  const VehicleFilterBar({
    super.key,
    required this.currentFilter,
    required this.searchQuery,
    required this.availableMakes,
    required this.availableCities,
    required this.availableFuelTypes,
    required this.onSearchChanged,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        _buildSearchBar(context),
        const SizedBox(height: 12),

        // Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // Make Filter
              if (availableMakes.isNotEmpty)
                _buildFilterDropdown(
                  context,
                  label: 'Make',
                  value: currentFilter.make,
                  items: availableMakes,
                  onSelected: (value) {
                    onFilterChanged(currentFilter.copyWith(
                      make: value,
                      clearMake: value == null,
                    ));
                  },
                ),

              // City Filter
              if (availableCities.isNotEmpty) ...[
                const SizedBox(width: 8),
                _buildFilterDropdown(
                  context,
                  label: 'City',
                  value: currentFilter.yardCity,
                  items: availableCities,
                  onSelected: (value) {
                    onFilterChanged(currentFilter.copyWith(
                      yardCity: value,
                      clearYardCity: value == null,
                    ));
                  },
                ),
              ],

              // Fuel Type Filter
              if (availableFuelTypes.isNotEmpty) ...[
                const SizedBox(width: 8),
                _buildFilterDropdown(
                  context,
                  label: 'Fuel',
                  value: currentFilter.fuelType,
                  items: availableFuelTypes,
                  onSelected: (value) {
                    onFilterChanged(currentFilter.copyWith(
                      fuelType: value,
                      clearFuelType: value == null,
                    ));
                  },
                ),
              ],

              // Price Filter
              const SizedBox(width: 8),
              _buildPriceFilterChip(context),

              // Clear All
              if (!currentFilter.isEmpty) ...[
                const SizedBox(width: 8),
                _buildClearAllChip(context),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: AppColors.softShadow,
      ),
      child: TextField(
        onChanged: onSearchChanged,
        style: GoogleFonts.inter(
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Search by make, model, RC...',
          hintStyle: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.textHint,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.textTertiary,
            size: 20,
          ),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.clear,
                    color: AppColors.textTertiary,
                    size: 18,
                  ),
                  onPressed: () => onSearchChanged(''),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterDropdown(
    BuildContext context, {
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onSelected,
  }) {
    final isActive = value != null;

    return PopupMenuButton<String?>(
      onSelected: onSelected,
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) => [
        PopupMenuItem<String?>(
          value: null,
          child: Text(
            'All ${label}s',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const PopupMenuDivider(),
        ...items.map((item) => PopupMenuItem<String>(
              value: item,
              child: Row(
                children: [
                  if (value == item)
                    const Icon(
                      Icons.check,
                      size: 16,
                      color: AppColors.accent,
                    ),
                  if (value == item) const SizedBox(width: 8),
                  Text(
                    item,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: value == item
                          ? AppColors.accent
                          : AppColors.textPrimary,
                      fontWeight:
                          value == item ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            )),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.accentSurface : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.accent : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value ?? label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: isActive ? AppColors.accent : AppColors.textSecondary,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: isActive ? AppColors.accent : AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceFilterChip(BuildContext context) {
    final hasPrice =
        currentFilter.minPrice != null || currentFilter.maxPrice != null;

    String label = 'Price';
    if (currentFilter.minPrice != null && currentFilter.maxPrice != null) {
      label =
          '${_formatPrice(currentFilter.minPrice!)} - ${_formatPrice(currentFilter.maxPrice!)}';
    } else if (currentFilter.minPrice != null) {
      label = '> ${_formatPrice(currentFilter.minPrice!)}';
    } else if (currentFilter.maxPrice != null) {
      label = '< ${_formatPrice(currentFilter.maxPrice!)}';
    }

    return GestureDetector(
      onTap: () => _showPriceFilterDialog(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: hasPrice ? AppColors.accentSurface : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hasPrice ? AppColors.accent : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: hasPrice ? AppColors.accent : AppColors.textSecondary,
                fontWeight: hasPrice ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.tune,
              size: 14,
              color: hasPrice ? AppColors.accent : AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClearAllChip(BuildContext context) {
    return GestureDetector(
      onTap: () => onFilterChanged(const VehicleFilter()),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.errorLight,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.close,
              size: 14,
              color: AppColors.error,
            ),
            const SizedBox(width: 4),
            Text(
              'Clear',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPriceFilterDialog(BuildContext context) {
    double? minPrice = currentFilter.minPrice;
    double? maxPrice = currentFilter.maxPrice;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  Text(
                    'Price Range',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Quick Price Buttons
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildQuickPriceButton(
                        context,
                        label: 'Under 5L',
                        onTap: () {
                          setState(() {
                            minPrice = null;
                            maxPrice = 500000;
                          });
                        },
                        isSelected: maxPrice == 500000 && minPrice == null,
                      ),
                      _buildQuickPriceButton(
                        context,
                        label: '5L - 10L',
                        onTap: () {
                          setState(() {
                            minPrice = 500000;
                            maxPrice = 1000000;
                          });
                        },
                        isSelected: minPrice == 500000 && maxPrice == 1000000,
                      ),
                      _buildQuickPriceButton(
                        context,
                        label: '10L - 20L',
                        onTap: () {
                          setState(() {
                            minPrice = 1000000;
                            maxPrice = 2000000;
                          });
                        },
                        isSelected: minPrice == 1000000 && maxPrice == 2000000,
                      ),
                      _buildQuickPriceButton(
                        context,
                        label: 'Above 20L',
                        onTap: () {
                          setState(() {
                            minPrice = 2000000;
                            maxPrice = null;
                          });
                        },
                        isSelected: minPrice == 2000000 && maxPrice == null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Manual Input
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Min Price',
                            prefixText: '₹ ',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          controller: TextEditingController(
                            text: minPrice?.toStringAsFixed(0) ?? '',
                          ),
                          onChanged: (value) {
                            minPrice = double.tryParse(value);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Max Price',
                            prefixText: '₹ ',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          controller: TextEditingController(
                            text: maxPrice?.toStringAsFixed(0) ?? '',
                          ),
                          onChanged: (value) {
                            maxPrice = double.tryParse(value);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            onFilterChanged(currentFilter.copyWith(
                              clearMinPrice: true,
                              clearMaxPrice: true,
                            ));
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Clear',
                            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {
                            onFilterChanged(currentFilter.copyWith(
                              minPrice: minPrice,
                              maxPrice: maxPrice,
                              clearMinPrice: minPrice == null,
                              clearMaxPrice: maxPrice == null,
                            ));
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Apply Filter',
                            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickPriceButton(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySurface : AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    if (price >= 10000000) {
      return '${(price / 10000000).toStringAsFixed(1)}Cr';
    } else if (price >= 100000) {
      return '${(price / 100000).toStringAsFixed(0)}L';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)}K';
    }
    return '₹${price.toStringAsFixed(0)}';
  }
}
