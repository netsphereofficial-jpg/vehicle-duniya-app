part of 'car_bazaar_bloc.dart';

enum CarBazaarStatus { initial, loading, loaded, error }

class CarBazaarState extends Equatable {
  final CarBazaarStatus status;
  final List<CarBazaarListing> listings;
  final CarBazaarListing? selectedListing;
  final String? errorMessage;

  const CarBazaarState({
    this.status = CarBazaarStatus.initial,
    this.listings = const [],
    this.selectedListing,
    this.errorMessage,
  });

  bool get isLoading => status == CarBazaarStatus.loading;
  bool get hasError => status == CarBazaarStatus.error;

  CarBazaarState copyWith({
    CarBazaarStatus? status,
    List<CarBazaarListing>? listings,
    CarBazaarListing? selectedListing,
    String? errorMessage,
  }) {
    return CarBazaarState(
      status: status ?? this.status,
      listings: listings ?? this.listings,
      selectedListing: selectedListing ?? this.selectedListing,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, listings, selectedListing, errorMessage];
}
