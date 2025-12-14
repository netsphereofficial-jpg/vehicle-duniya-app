import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../shared/domain/entities/bid.dart';
import '../bloc/bidding_bloc.dart';

class MyBidsPage extends StatelessWidget {
  const MyBidsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<BiddingBloc>()..add(const BiddingLoadRequested()),
      child: const _MyBidsView(),
    );
  }
}

class _MyBidsView extends StatelessWidget {
  const _MyBidsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.myBids),
      ),
      body: BlocBuilder<BiddingBloc, BiddingState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: AppLoading());
          }

          if (state.hasError) {
            return AppError(
              message: state.errorMessage ?? AppStrings.somethingWentWrong,
              onRetry: () {
                context.read<BiddingBloc>().add(const BiddingLoadRequested());
              },
            );
          }

          if (state.myBids.isEmpty) {
            return const AppEmptyState(
              title: 'No Bids Yet',
              subtitle: 'Start bidding on auctions to see your bids here',
              icon: Icons.gavel_outlined,
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<BiddingBloc>().add(const BiddingLoadRequested());
            },
            child: ListView.builder(
              itemCount: state.myBids.length,
              itemBuilder: (context, index) {
                final bid = state.myBids[index];
                return ListTile(
                  title: Text(bid.formattedAmount),
                  subtitle: Text('Auction: ${bid.auctionId}'),
                  trailing: Text(BidStatusX(bid.status).displayName),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
