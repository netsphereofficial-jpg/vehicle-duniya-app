part of 'car_bazaar_bloc.dart';

abstract class CarBazaarEvent extends Equatable {
  const CarBazaarEvent();

  @override
  List<Object?> get props => [];
}

class CarBazaarLoadRequested extends CarBazaarEvent {
  const CarBazaarLoadRequested();
}
