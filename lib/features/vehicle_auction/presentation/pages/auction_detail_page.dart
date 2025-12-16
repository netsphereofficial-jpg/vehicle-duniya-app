import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../shared/domain/entities/vehicle_item.dart';
import '../bloc/vehicle_auction_bloc.dart';
import '../widgets/auction_header.dart';
import '../widgets/quick_bid_bottom_sheet.dart';
import '../widgets/vehicle_card.dart';
import '../widgets/vehicle_filter_bar.dart';

class AuctionDetailPage extends StatefulWidget {
  final String auctionId;

  const AuctionDetailPage({
    super.key,
    required this.auctionId,
  });

  @override
  State<AuctionDetailPage> createState() => _AuctionDetailPageState();
}

class _AuctionDetailPageState extends State<AuctionDetailPage> {
  late VehicleAuctionBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = getIt<VehicleAuctionBloc>();
    _loadAuction();
  }

  void _loadAuction() {
    _bloc.add(VehicleAuctionDetailRequested(widget.auctionId));
  }

  @override
  void dispose() {
    // Stop real-time updates when leaving the page
    _bloc.add(const VehicleAuctionStopRealtime());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(context),
        body: BlocConsumer<VehicleAuctionBloc, VehicleAuctionState>(
          listener: (context, state) {
            // Start real-time updates for live auctions
            if (state.selectedAuction != null &&
                state.selectedAuction!.isLive &&
                !state.isRealtimeActive) {
              _bloc.add(VehicleAuctionStartRealtime(widget.auctionId));
            }
          },
          builder: (context, state) {
            if (state.isLoading && state.selectedAuction == null) {
              return _buildLoadingState();
            }

            if (state.hasError && state.selectedAuction == null) {
              return _buildErrorState(state.errorMessage);
            }

            if (state.selectedAuction == null) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              onRefresh: () async => _loadAuction(),
              color: AppColors.primary,
              child: CustomScrollView(
                slivers: [
                  // Auction Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: AuctionHeader(
                        auction: state.selectedAuction!,
                        vehicleCount: state.vehicleCount,
                        filteredCount: state.filteredVehicleCount,
                        isRealtimeActive: state.isRealtimeActive,
                      ),
                    ),
                  ),

                  // Filter Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: VehicleFilterBar(
                        currentFilter: state.filter,
                        searchQuery: state.searchQuery,
                        availableMakes: state.availableMakes,
                        availableCities: state.availableCities,
                        availableFuelTypes: state.availableFuelTypes,
                        onSearchChanged: (query) {
                          _bloc.add(VehicleSearchRequested(query));
                        },
                        onFilterChanged: (filter) {
                          _bloc.add(VehicleFilterRequested(filter));
                        },
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: 16),
                  ),

                  // Vehicle Grid
                  _buildVehicleGrid(state),

                  // Bottom Padding
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 20),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded),
        color: AppColors.textPrimary,
        onPressed: () => context.pop(),
      ),
      title: BlocBuilder<VehicleAuctionBloc, VehicleAuctionState>(
        builder: (context, state) {
          return Text(
            state.selectedAuction?.name ?? 'Auction',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
        },
      ),
      centerTitle: true,
      actions: [
        BlocBuilder<VehicleAuctionBloc, VehicleAuctionState>(
          builder: (context, state) {
            if (state.isRealtimeActive) {
              return Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'LIVE',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }

  Widget _buildErrorState(String? message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message ?? 'Unable to load auction details',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadAuction,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'Auction not found',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleGrid(VehicleAuctionState state) {
    final vehicles = state.displayVehicles;

    if (vehicles.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.directions_car_outlined,
                  size: 48,
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                state.searchQuery.isNotEmpty || !state.filter.isEmpty
                    ? 'No vehicles match your filters'
                    : 'No vehicles in this auction',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              if (state.searchQuery.isNotEmpty || !state.filter.isEmpty) ...[
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () {
                    _bloc.add(const VehicleSearchRequested(''));
                    _bloc.add(const VehicleFilterRequested(VehicleFilter()));
                  },
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear Filters'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final vehicle = vehicles[index];
            return VehicleCard(
              vehicle: vehicle,
              isInWatchlist: state.isInWatchlist(vehicle.id),
              onTap: () => _openBidSheet(vehicle, state),
              onWatchlistTap: () {
                _bloc.add(VehicleWatchlistToggled(vehicle.id));
              },
            );
          },
          childCount: vehicles.length,
        ),
      ),
    );
  }

  void _openBidSheet(VehicleItem vehicle, VehicleAuctionState state) {
    // Load bids for this vehicle
    _bloc.add(VehicleBidsHistoryRequested(vehicle.id));

    QuickBidBottomSheet.show(
      context,
      vehicle: vehicle,
      bids: state.vehicleBids,
      isInWatchlist: state.isInWatchlist(vehicle.id),
      onWatchlistToggle: () {
        _bloc.add(VehicleWatchlistToggled(vehicle.id));
      },
    );
  }
}
