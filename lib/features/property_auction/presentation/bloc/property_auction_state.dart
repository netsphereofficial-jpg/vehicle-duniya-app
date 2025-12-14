part of 'property_auction_bloc.dart';

enum PropertyAuctionStatus { initial, loading, loaded, error }

class PropertyAuctionState extends Equatable {
  final PropertyAuctionStatus status;
  final List<PropertyAuction> properties;
  final PropertyAuction? selectedProperty;
  final String? errorMessage;

  const PropertyAuctionState({
    this.status = PropertyAuctionStatus.initial,
    this.properties = const [],
    this.selectedProperty,
    this.errorMessage,
  });

  bool get isLoading => status == PropertyAuctionStatus.loading;
  bool get hasError => status == PropertyAuctionStatus.error;

  PropertyAuctionState copyWith({
    PropertyAuctionStatus? status,
    List<PropertyAuction>? properties,
    PropertyAuction? selectedProperty,
    String? errorMessage,
  }) {
    return PropertyAuctionState(
      status: status ?? this.status,
      properties: properties ?? this.properties,
      selectedProperty: selectedProperty ?? this.selectedProperty,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, properties, selectedProperty, errorMessage];
}
