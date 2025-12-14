import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

/// Bid type (vehicle or property)
enum BidType { vehicle, property }

extension BidTypeX on BidType {
  String get displayName => switch (this) {
        BidType.vehicle => 'Vehicle',
        BidType.property => 'Property',
      };

  static BidType fromString(String? value) {
    return BidType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => BidType.vehicle,
    );
  }
}

/// Bid status
enum BidStatus { active, outbid, winning, won, lost }

extension BidStatusX on BidStatus {
  String get label => switch (this) {
        BidStatus.active => 'Active',
        BidStatus.outbid => 'Outbid',
        BidStatus.winning => 'Winning',
        BidStatus.won => 'Won',
        BidStatus.lost => 'Lost',
      };

  String get displayName => label;

  static BidStatus fromString(String? value) {
    return BidStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => BidStatus.active,
    );
  }
}

/// Bid entity
class Bid extends Equatable {
  final String id;
  final String auctionId;
  final String? vehicleId; // For vehicle auctions
  final String? propertyId; // For property auctions
  final BidType type;
  final String userId;
  final String? userName;
  final String? userPhone;
  final double amount;
  final BidStatus status;
  final bool isWinning;
  final DateTime timestamp;
  final DateTime? createdAt;

  const Bid({
    required this.id,
    required this.auctionId,
    this.vehicleId,
    this.propertyId,
    required this.type,
    required this.userId,
    this.userName,
    this.userPhone,
    required this.amount,
    this.status = BidStatus.active,
    this.isWinning = false,
    required this.timestamp,
    this.createdAt,
  });

  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  String get formattedAmount => _currencyFormat.format(amount);

  String get itemId => type == BidType.vehicle ? vehicleId ?? '' : propertyId ?? '';

  bool get isVehicleBid => type == BidType.vehicle;
  bool get isPropertyBid => type == BidType.property;

  bool get isActiveBid =>
      status == BidStatus.active || status == BidStatus.winning;

  Bid copyWith({
    String? id,
    String? auctionId,
    String? vehicleId,
    String? propertyId,
    BidType? type,
    String? userId,
    String? userName,
    String? userPhone,
    double? amount,
    BidStatus? status,
    bool? isWinning,
    DateTime? timestamp,
    DateTime? createdAt,
  }) {
    return Bid(
      id: id ?? this.id,
      auctionId: auctionId ?? this.auctionId,
      vehicleId: vehicleId ?? this.vehicleId,
      propertyId: propertyId ?? this.propertyId,
      type: type ?? this.type,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhone: userPhone ?? this.userPhone,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      isWinning: isWinning ?? this.isWinning,
      timestamp: timestamp ?? this.timestamp,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        auctionId,
        vehicleId,
        propertyId,
        type,
        userId,
        userName,
        userPhone,
        amount,
        status,
        isWinning,
        timestamp,
        createdAt,
      ];
}
