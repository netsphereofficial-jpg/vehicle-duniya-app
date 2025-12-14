import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/auction.dart';

/// Auction data model for Firestore
class AuctionModel extends Auction {
  const AuctionModel({
    required super.id,
    required super.name,
    super.category,
    super.categoryName,
    super.imageUrl,
    super.startDate,
    super.endDate,
    super.status,
    super.mode,
    super.eventType,
    super.bidReportUrl,
    super.imagesZipUrl,
    super.vehicleIds,
    super.createdBy,
    super.createdAt,
    super.updatedAt,
  });

  factory AuctionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AuctionModel.fromMap(doc.id, data);
  }

  factory AuctionModel.fromMap(String id, Map<String, dynamic> data) {
    return AuctionModel(
      id: id,
      name: data['name'] as String? ?? '',
      category: data['category'] as String?,
      categoryName: data['categoryName'] as String?,
      imageUrl: data['imageUrl'] as String?,
      startDate: _parseDateTime(data['startDate']),
      endDate: _parseDateTime(data['endDate']),
      status: AuctionStatusX.fromString(data['status'] as String?),
      mode: AuctionModeX.fromString(data['mode'] as String?),
      eventType: EventTypeX.fromString(data['eventType'] as String?),
      bidReportUrl: data['bidReportUrl'] as String?,
      imagesZipUrl: data['imagesZipUrl'] as String?,
      vehicleIds: _parseStringList(data['vehicleIds']),
      createdBy: data['createdBy'] as String?,
      createdAt: _parseDateTime(data['createdAt']),
      updatedAt: _parseDateTime(data['updatedAt']),
    );
  }

  factory AuctionModel.fromEntity(Auction entity) {
    return AuctionModel(
      id: entity.id,
      name: entity.name,
      category: entity.category,
      categoryName: entity.categoryName,
      imageUrl: entity.imageUrl,
      startDate: entity.startDate,
      endDate: entity.endDate,
      status: entity.status,
      mode: entity.mode,
      eventType: entity.eventType,
      bidReportUrl: entity.bidReportUrl,
      imagesZipUrl: entity.imagesZipUrl,
      vehicleIds: entity.vehicleIds,
      createdBy: entity.createdBy,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'category': category,
      'categoryName': categoryName,
      'imageUrl': imageUrl,
      'startDate': startDate,
      'endDate': endDate,
      'status': status.name,
      'mode': mode.name,
      'eventType': eventType.name,
      'bidReportUrl': bidReportUrl,
      'imagesZipUrl': imagesZipUrl,
      'vehicleIds': vehicleIds,
      'createdBy': createdBy,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }
}
