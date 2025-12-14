import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../bloc/car_bazaar_bloc.dart';

class CarBazaarPage extends StatelessWidget {
  const CarBazaarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CarBazaarBloc>()..add(const CarBazaarLoadRequested()),
      child: const _CarBazaarView(),
    );
  }
}

class _CarBazaarView extends StatelessWidget {
  const _CarBazaarView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.carBazaar),
      ),
      body: BlocBuilder<CarBazaarBloc, CarBazaarState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: AppLoading());
          }

          if (state.hasError) {
            return AppError(
              message: state.errorMessage ?? AppStrings.somethingWentWrong,
              onRetry: () {
                context.read<CarBazaarBloc>().add(const CarBazaarLoadRequested());
              },
            );
          }

          return const AppEmptyState(
            title: 'Coming Soon',
            subtitle: 'Car Bazaar listings will be available soon',
            icon: Icons.store_outlined,
          );
        },
      ),
    );
  }
}
