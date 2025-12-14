import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/firebase_service.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../shared/domain/entities/car_bazaar.dart';

part 'car_bazaar_event.dart';
part 'car_bazaar_state.dart';

class CarBazaarBloc extends Bloc<CarBazaarEvent, CarBazaarState> {
  final FirebaseService _firebaseService;

  CarBazaarBloc({required FirebaseService firebaseService})
      : _firebaseService = firebaseService,
        super(const CarBazaarState()) {
    on<CarBazaarLoadRequested>(_onLoadRequested);
  }

  Future<void> _onLoadRequested(
    CarBazaarLoadRequested event,
    Emitter<CarBazaarState> emit,
  ) async {
    AppLogger.blocEvent('CarBazaarBloc', 'LoadRequested');
    emit(state.copyWith(status: CarBazaarStatus.loading));

    try {
      // TODO: Implement actual data fetching
      emit(state.copyWith(
        status: CarBazaarStatus.loaded,
        listings: [],
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CarBazaarStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
