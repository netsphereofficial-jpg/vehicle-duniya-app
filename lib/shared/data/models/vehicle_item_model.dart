import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/vehicle_item.dart';

/// Vehicle item data model for Firestore
class VehicleItemModel extends VehicleItem {
  const VehicleItemModel({
    required super.id,
    required super.auctionId,
    super.contractNo,
    super.rcNo,
    super.make,
    super.model,
    super.engineNo,
    super.chassisNo,
    super.yom,
    super.fuelType,
    super.ppt,
    super.yardName,
    super.yardCity,
    super.yardState,
    super.basePrice,
    super.bidIncrement,
    super.multipleAmount,
    super.currentBid,
    super.winnerId,
    super.winningBid,
    super.images,
    super.vahanUrl,
    super.contactPerson,
    super.contactNumber,
    super.remark,
    super.rcAvailable,
    super.repoDate,
    super.startDate,
    super.endDate,
    super.status,
    super.isActive,
    super.createdAt,
    super.updatedAt,
  });

  factory VehicleItemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return VehicleItemModel.fromMap(doc.id, data);
  }

  factory VehicleItemModel.fromMap(String id, Map<String, dynamic> data) {
    return VehicleItemModel(
      id: id,
      auctionId: data['auctionId'] as String? ?? '',
      contractNo: data['contractNo'] as String?,
      rcNo: data['rcNo'] as String?,
      make: data['make'] as String?,
      model: data['model'] as String?,
      engineNo: data['engineNo'] as String?,
      chassisNo: data['chassisNo'] as String?,
      yom: _parseInt(data['yom']),
      fuelType: data['fuelType'] as String?,
      ppt: data['ppt'] as String?,
      yardName: data['yardName'] as String?,
      yardCity: data['yardCity'] as String?,
      yardState: data['yardState'] as String?,
      basePrice: _parseDouble(data['basePrice']),
      bidIncrement: _parseDouble(data['bidIncrement']),
      multipleAmount: _parseDouble(data['multipleAmount']),
      currentBid: _parseDouble(data['currentBid']),
      winnerId: data['winnerId'] as String?,
      winningBid: _parseDouble(data['winningBid']),
      images: _parseStringList(data['images']),
      vahanUrl: data['vahanUrl'] as String?,
      contactPerson: data['contactPerson'] as String?,
      contactNumber: data['contactNumber'] as String?,
      remark: data['remark'] as String?,
      rcAvailable: data['rcAvailable'] as bool? ?? false,
      repoDate: _parseDateTime(data['repoDate']),
      startDate: _parseDateTime(data['startDate']),
      endDate: _parseDateTime(data['endDate']),
      status: data['status'] as String? ?? 'upcoming',
      isActive: data['isActive'] as bool? ?? true,
      createdAt: _parseDateTime(data['createdAt']),
      updatedAt: _parseDateTime(data['updatedAt']),
    );
  }

  factory VehicleItemModel.fromEntity(VehicleItem entity) {
    return VehicleItemModel(
      id: entity.id,
      auctionId: entity.auctionId,
      contractNo: entity.contractNo,
      rcNo: entity.rcNo,
      make: entity.make,
      model: entity.model,
      engineNo: entity.engineNo,
      chassisNo: entity.chassisNo,
      yom: entity.yom,
      fuelType: entity.fuelType,
      ppt: entity.ppt,
      yardName: entity.yardName,
      yardCity: entity.yardCity,
      yardState: entity.yardState,
      basePrice: entity.basePrice,
      bidIncrement: entity.bidIncrement,
      multipleAmount: entity.multipleAmount,
      currentBid: entity.currentBid,
      winnerId: entity.winnerId,
      winningBid: entity.winningBid,
      images: entity.images,
      vahanUrl: entity.vahanUrl,
      contactPerson: entity.contactPerson,
      contactNumber: entity.contactNumber,
      remark: entity.remark,
      rcAvailable: entity.rcAvailable,
      repoDate: entity.repoDate,
      startDate: entity.startDate,
      endDate: entity.endDate,
      status: entity.status,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'auctionId': auctionId,
      'contractNo': contractNo,
      'rcNo': rcNo,
      'make': make,
      'model': model,
      'engineNo': engineNo,
      'chassisNo': chassisNo,
      'yom': yom,
      'fuelType': fuelType,
      'ppt': ppt,
      'yardName': yardName,
      'yardCity': yardCity,
      'yardState': yardState,
      'basePrice': basePrice,
      'bidIncrement': bidIncrement,
      'multipleAmount': multipleAmount,
      'currentBid': currentBid,
      'winnerId': winnerId,
      'winningBid': winningBid,
      'images': images,
      'vahanUrl': vahanUrl,
      'contactPerson': contactPerson,
      'contactNumber': contactNumber,
      'remark': remark,
      'rcAvailable': rcAvailable,
      'repoDate': repoDate,
      'startDate': startDate,
      'endDate': endDate,
      'status': status,
      'isActive': isActive,
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

  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
