import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../shared/domain/entities/auction.dart';
import '../bloc/vehicle_auction_bloc.dart';

class VehicleAuctionPage extends StatelessWidget {
  const VehicleAuctionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<VehicleAuctionBloc>()..add(const VehicleAuctionLoadRequested()),
      child: const _VehicleAuctionView(),
    );
  }
}

class _VehicleAuctionView extends StatelessWidget {
  const _VehicleAuctionView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.vehicles),
      ),
      body: BlocBuilder<VehicleAuctionBloc, VehicleAuctionState>(
        builder: (context, state) {
          if (state.isLoading && state.auctions.isEmpty) {
            return const Center(child: AppLoading());
          }

          if (state.hasError) {
            return AppError(
              message: state.errorMessage ?? AppStrings.somethingWentWrong,
              onRetry: () {
                context.read<VehicleAuctionBloc>().add(const VehicleAuctionLoadRequested());
              },
            );
          }

          if (state.auctions.isEmpty) {
            return const AppEmptyState(
              title: 'No Auctions',
              subtitle: 'No vehicle auctions available at the moment',
              icon: Icons.directions_car_outlined,
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<VehicleAuctionBloc>().add(const VehicleAuctionLoadRequested());
            },
            child: ListView.builder(
              padding: AppSizes.screenPadding,
              itemCount: state.auctions.length,
              itemBuilder: (context, index) {
                final auction = state.auctions[index];
                return AppCard(
                  margin: const EdgeInsets.only(bottom: AppSizes.md),
                  onTap: () {
                    // TODO: Navigate to auction detail
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              auction.name,
                              style: Theme.of(context).textTheme.titleMedium,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          StatusBadge(
                            text: AuctionStatusX(auction.status).displayName.toUpperCase(),
                            backgroundColor: auction.isLive
                                ? AppColors.live
                                : auction.isUpcoming
                                    ? AppColors.upcoming
                                    : AppColors.ended,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.sm),
                      Row(
                        children: [
                          const Icon(
                            Icons.directions_car_outlined,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${auction.vehicleCount} vehicles',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                          const SizedBox(width: AppSizes.md),
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            EventTypeX(auction.eventType).displayName,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
