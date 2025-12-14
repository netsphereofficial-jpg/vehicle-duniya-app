import 'package:equatable/equatable.dart';

/// Vehicle item entity (individual vehicle in an auction)
class VehicleItem extends Equatable {
  final String id;
  final String auctionId;
  final String? contractNo;
  final String? rcNo;
  final String? make;
  final String? model;
  final String? engineNo;
  final String? chassisNo;
  final int? yom; // Year of manufacture
  final String? fuelType;
  final String? ppt;
  final String? yardName;
  final String? yardCity;
  final String? yardState;
  final double basePrice;
  final double bidIncrement;
  final double? multipleAmount;
  final double currentBid;
  final String? winnerId;
  final double? winningBid;
  final List<String> images;
  final String? vahanUrl;
  final String? contactPerson;
  final String? contactNumber;
  final String? remark;
  final bool rcAvailable;
  final DateTime? repoDate;
  final DateTime? startDate;
  final DateTime? endDate;
  final String status;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const VehicleItem({
    required this.id,
    required this.auctionId,
    this.contractNo,
    this.rcNo,
    this.make,
    this.model,
    this.engineNo,
    this.chassisNo,
    this.yom,
    this.fuelType,
    this.ppt,
    this.yardName,
    this.yardCity,
    this.yardState,
    this.basePrice = 0,
    this.bidIncrement = 0,
    this.multipleAmount,
    this.currentBid = 0,
    this.winnerId,
    this.winningBid,
    this.images = const [],
    this.vahanUrl,
    this.contactPerson,
    this.contactNumber,
    this.remark,
    this.rcAvailable = false,
    this.repoDate,
    this.startDate,
    this.endDate,
    this.status = 'upcoming',
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  String get fullDescription {
    final parts = <String>[];
    if (make != null && make!.isNotEmpty) parts.add(make!);
    if (model != null && model!.isNotEmpty) parts.add(model!);
    if (yom != null) parts.add('($yom)');
    return parts.isNotEmpty ? parts.join(' ') : 'Vehicle';
  }

  String get location {
    final parts = <String>[];
    if (yardCity != null && yardCity!.isNotEmpty) parts.add(yardCity!);
    if (yardState != null && yardState!.isNotEmpty) parts.add(yardState!);
    return parts.isNotEmpty ? parts.join(', ') : '-';
  }

  bool get hasWinner => winnerId != null && winnerId!.isNotEmpty;
  bool get hasImages => images.isNotEmpty;
  int get imageCount => images.length;
  String? get primaryImage => hasImages ? images.first : null;

  double get minimumBid =>
      currentBid > 0 ? currentBid + bidIncrement : basePrice;

  bool get isLive => status == 'live';
  bool get isUpcoming => status == 'upcoming';
  bool get isEnded => status == 'ended';

  VehicleItem copyWith({
    String? id,
    String? auctionId,
    String? contractNo,
    String? rcNo,
    String? make,
    String? model,
    String? engineNo,
    String? chassisNo,
    int? yom,
    String? fuelType,
    String? ppt,
    String? yardName,
    String? yardCity,
    String? yardState,
    double? basePrice,
    double? bidIncrement,
    double? multipleAmount,
    double? currentBid,
    String? winnerId,
    double? winningBid,
    List<String>? images,
    String? vahanUrl,
    String? contactPerson,
    String? contactNumber,
    String? remark,
    bool? rcAvailable,
    DateTime? repoDate,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VehicleItem(
      id: id ?? this.id,
      auctionId: auctionId ?? this.auctionId,
      contractNo: contractNo ?? this.contractNo,
      rcNo: rcNo ?? this.rcNo,
      make: make ?? this.make,
      model: model ?? this.model,
      engineNo: engineNo ?? this.engineNo,
      chassisNo: chassisNo ?? this.chassisNo,
      yom: yom ?? this.yom,
      fuelType: fuelType ?? this.fuelType,
      ppt: ppt ?? this.ppt,
      yardName: yardName ?? this.yardName,
      yardCity: yardCity ?? this.yardCity,
      yardState: yardState ?? this.yardState,
      basePrice: basePrice ?? this.basePrice,
      bidIncrement: bidIncrement ?? this.bidIncrement,
      multipleAmount: multipleAmount ?? this.multipleAmount,
      currentBid: currentBid ?? this.currentBid,
      winnerId: winnerId ?? this.winnerId,
      winningBid: winningBid ?? this.winningBid,
      images: images ?? this.images,
      vahanUrl: vahanUrl ?? this.vahanUrl,
      contactPerson: contactPerson ?? this.contactPerson,
      contactNumber: contactNumber ?? this.contactNumber,
      remark: remark ?? this.remark,
      rcAvailable: rcAvailable ?? this.rcAvailable,
      repoDate: repoDate ?? this.repoDate,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        auctionId,
        contractNo,
        rcNo,
        make,
        model,
        engineNo,
        chassisNo,
        yom,
        fuelType,
        ppt,
        yardName,
        yardCity,
        yardState,
        basePrice,
        bidIncrement,
        multipleAmount,
        currentBid,
        winnerId,
        winningBid,
        images,
        vahanUrl,
        contactPerson,
        contactNumber,
        remark,
        rcAvailable,
        repoDate,
        startDate,
        endDate,
        status,
        isActive,
        createdAt,
        updatedAt,
      ];
}
