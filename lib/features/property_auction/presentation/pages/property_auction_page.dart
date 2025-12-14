import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../bloc/property_auction_bloc.dart';

class PropertyAuctionPage extends StatelessWidget {
  const PropertyAuctionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PropertyAuctionBloc>()..add(const PropertyAuctionLoadRequested()),
      child: const _PropertyAuctionView(),
    );
  }
}

class _PropertyAuctionView extends StatelessWidget {
  const _PropertyAuctionView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.properties),
      ),
      body: BlocBuilder<PropertyAuctionBloc, PropertyAuctionState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: AppLoading());
          }

          if (state.hasError) {
            return AppError(
              message: state.errorMessage ?? AppStrings.somethingWentWrong,
              onRetry: () {
                context.read<PropertyAuctionBloc>().add(const PropertyAuctionLoadRequested());
              },
            );
          }

          return const AppEmptyState(
            title: 'Coming Soon',
            subtitle: 'Property auctions will be available soon',
            icon: Icons.home_work_outlined,
          );
        },
      ),
    );
  }
}
