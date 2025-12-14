import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/bid.dart';

/// Bid data model for Firestore
class BidModel extends Bid {
  const BidModel({
    required super.id,
    required super.auctionId,
    super.vehicleId,
    super.propertyId,
    required super.type,
    required super.userId,
    super.userName,
    super.userPhone,
    required super.amount,
    super.status,
    super.isWinning,
    required super.timestamp,
    super.createdAt,
  });

  factory BidModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return BidModel.fromMap(doc.id, data);
  }

  factory BidModel.fromMap(String id, Map<String, dynamic> data) {
    return BidModel(
      id: id,
      auctionId: data['auctionId'] as String? ?? '',
      vehicleId: data['vehicleId'] as String?,
      propertyId: data['propertyId'] as String?,
      type: BidTypeX.fromString(data['type'] as String?),
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String?,
      userPhone: data['userPhone'] as String?,
      amount: _parseDouble(data['amount']),
      status: BidStatusX.fromString(data['status'] as String?),
      isWinning: data['isWinning'] as bool? ?? false,
      timestamp: _parseDateTime(data['timestamp']) ?? DateTime.now(),
      createdAt: _parseDateTime(data['createdAt']),
    );
  }

  factory BidModel.fromEntity(Bid entity) {
    return BidModel(
      id: entity.id,
      auctionId: entity.auctionId,
      vehicleId: entity.vehicleId,
      propertyId: entity.propertyId,
      type: entity.type,
      userId: entity.userId,
      userName: entity.userName,
      userPhone: entity.userPhone,
      amount: entity.amount,
      status: entity.status,
      isWinning: entity.isWinning,
      timestamp: entity.timestamp,
      createdAt: entity.createdAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'auctionId': auctionId,
      'vehicleId': vehicleId,
      'propertyId': propertyId,
      'type': type.name,
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'amount': amount,
      'status': status.name,
      'isWinning': isWinning,
      'timestamp': timestamp,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}
