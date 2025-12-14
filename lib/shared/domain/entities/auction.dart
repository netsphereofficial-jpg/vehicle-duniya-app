import 'package:equatable/equatable.dart';

/// Auction mode
enum AuctionMode { openAuction, online }

extension AuctionModeX on AuctionMode {
  String get displayName => switch (this) {
        AuctionMode.openAuction => 'Open Auction',
        AuctionMode.online => 'Online',
      };

  static AuctionMode fromString(String? value) {
    return AuctionMode.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AuctionMode.online,
    );
  }
}

/// Auction event type
// ignore: constant_identifier_names
enum EventType { LNT, TCF, MNBAF, HDBF, CWCF, other }

extension EventTypeX on EventType {
  String get label => switch (this) {
        EventType.LNT => 'LNT',
        EventType.TCF => 'TCF',
        EventType.MNBAF => 'MNBAF',
        EventType.HDBF => 'HDBF',
        EventType.CWCF => 'CWCF',
        EventType.other => 'Other',
      };

  String get displayName => label;

  static EventType fromString(String? value) {
    return EventType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => EventType.other,
    );
  }
}

/// Auction status
enum AuctionStatus { upcoming, live, ended }

extension AuctionStatusX on AuctionStatus {
  String get label => switch (this) {
        AuctionStatus.upcoming => 'Upcoming',
        AuctionStatus.live => 'Live',
        AuctionStatus.ended => 'Ended',
      };

  String get displayName => label;

  static AuctionStatus fromString(String? value) {
    return AuctionStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AuctionStatus.upcoming,
    );
  }
}

/// Auction entity (Vehicle Auctions)
class Auction extends Equatable {
  final String id;
  final String name;
  final String? category;
  final String? categoryName;
  final String? imageUrl;
  final DateTime? startDate;
  final DateTime? endDate;
  final AuctionStatus status;
  final AuctionMode mode;
  final EventType eventType;
  final String? bidReportUrl;
  final String? imagesZipUrl;
  final List<String> vehicleIds;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Auction({
    required this.id,
    required this.name,
    this.category,
    this.categoryName,
    this.imageUrl,
    this.startDate,
    this.endDate,
    this.status = AuctionStatus.upcoming,
    this.mode = AuctionMode.online,
    this.eventType = EventType.other,
    this.bidReportUrl,
    this.imagesZipUrl,
    this.vehicleIds = const [],
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  bool get isLive => status == AuctionStatus.live;
  bool get isUpcoming => status == AuctionStatus.upcoming;
  bool get isEnded => status == AuctionStatus.ended;

  bool get hasStarted {
    if (startDate == null) return false;
    return DateTime.now().isAfter(startDate!);
  }

  bool get hasEnded {
    if (endDate == null) return false;
    return DateTime.now().isAfter(endDate!);
  }

  int get vehicleCount => vehicleIds.length;

  Duration? get duration {
    if (startDate == null || endDate == null) return null;
    return endDate!.difference(startDate!);
  }

  /// Calculate actual status based on dates
  AuctionStatus get calculatedStatus {
    final now = DateTime.now();
    if (startDate == null || endDate == null) return status;

    if (now.isBefore(startDate!)) return AuctionStatus.upcoming;
    if (now.isAfter(endDate!)) return AuctionStatus.ended;
    return AuctionStatus.live;
  }

  Auction copyWith({
    String? id,
    String? name,
    String? category,
    String? categoryName,
    String? imageUrl,
    DateTime? startDate,
    DateTime? endDate,
    AuctionStatus? status,
    AuctionMode? mode,
    EventType? eventType,
    String? bidReportUrl,
    String? imagesZipUrl,
    List<String>? vehicleIds,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Auction(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      categoryName: categoryName ?? this.categoryName,
      imageUrl: imageUrl ?? this.imageUrl,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      mode: mode ?? this.mode,
      eventType: eventType ?? this.eventType,
      bidReportUrl: bidReportUrl ?? this.bidReportUrl,
      imagesZipUrl: imagesZipUrl ?? this.imagesZipUrl,
      vehicleIds: vehicleIds ?? this.vehicleIds,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        category,
        categoryName,
        imageUrl,
        startDate,
        endDate,
        status,
        mode,
        eventType,
        bidReportUrl,
        imagesZipUrl,
        vehicleIds,
        createdBy,
        createdAt,
        updatedAt,
      ];
}
