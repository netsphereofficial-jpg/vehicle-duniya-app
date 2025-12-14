import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

/// Property auction status
enum PropertyAuctionStatus { upcoming, live, ended }

extension PropertyAuctionStatusX on PropertyAuctionStatus {
  String get label => switch (this) {
        PropertyAuctionStatus.upcoming => 'Upcoming',
        PropertyAuctionStatus.live => 'Live',
        PropertyAuctionStatus.ended => 'Ended',
      };

  static PropertyAuctionStatus fromString(String? value) {
    return PropertyAuctionStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => PropertyAuctionStatus.upcoming,
    );
  }
}

/// Property auction entity
class PropertyAuction extends Equatable {
  final String id;
  final String? eventType;
  final String? eventNo;
  final String? nitRefNo;
  final String? eventTitle;
  final String? eventBank;
  final String? eventBranch;
  final String? propertyCategory;
  final String? propertySubCategory;
  final String? propertyDescription;
  final String? borrowerName;
  final double reservePrice;
  final double tenderFee;
  final double priceBid;
  final double bidIncrementValue;
  final int? autoExtensionTime;
  final int? noOfAutoExtension;
  final bool dscRequired;
  final double emdAmount;
  final String? emdBankName;
  final String? emdAccountNo;
  final String? emdIfscCode;
  final DateTime? pressReleaseDate;
  final DateTime? inspectionDateFrom;
  final DateTime? inspectionDateTo;
  final DateTime? submissionLastDate;
  final DateTime? offerOpeningDate;
  final DateTime? auctionStartDate;
  final DateTime? auctionEndDate;
  final String? propertyAddress;
  final String? propertyCity;
  final String? propertyState;
  final List<String> images;
  final PropertyAuctionStatus status;
  final bool isActive;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PropertyAuction({
    required this.id,
    this.eventType,
    this.eventNo,
    this.nitRefNo,
    this.eventTitle,
    this.eventBank,
    this.eventBranch,
    this.propertyCategory,
    this.propertySubCategory,
    this.propertyDescription,
    this.borrowerName,
    this.reservePrice = 0,
    this.tenderFee = 0,
    this.priceBid = 0,
    this.bidIncrementValue = 0,
    this.autoExtensionTime,
    this.noOfAutoExtension,
    this.dscRequired = false,
    this.emdAmount = 0,
    this.emdBankName,
    this.emdAccountNo,
    this.emdIfscCode,
    this.pressReleaseDate,
    this.inspectionDateFrom,
    this.inspectionDateTo,
    this.submissionLastDate,
    this.offerOpeningDate,
    this.auctionStartDate,
    this.auctionEndDate,
    this.propertyAddress,
    this.propertyCity,
    this.propertyState,
    this.images = const [],
    this.status = PropertyAuctionStatus.upcoming,
    this.isActive = true,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  String get formattedReservePrice => _currencyFormat.format(reservePrice);
  String get formattedEmdAmount => _currencyFormat.format(emdAmount);
  String get formattedTenderFee => _currencyFormat.format(tenderFee);

  bool get isLive => status == PropertyAuctionStatus.live;
  bool get isUpcoming => status == PropertyAuctionStatus.upcoming;
  bool get hasEnded => status == PropertyAuctionStatus.ended;

  /// Calculate actual status based on dates
  PropertyAuctionStatus get calculatedStatus {
    final now = DateTime.now();
    if (auctionStartDate == null || auctionEndDate == null) return status;

    if (now.isBefore(auctionStartDate!)) return PropertyAuctionStatus.upcoming;
    if (now.isAfter(auctionEndDate!)) return PropertyAuctionStatus.ended;
    return PropertyAuctionStatus.live;
  }

  String get location {
    final parts = <String>[];
    if (propertyCity != null && propertyCity!.isNotEmpty) {
      parts.add(propertyCity!);
    }
    if (propertyState != null && propertyState!.isNotEmpty) {
      parts.add(propertyState!);
    }
    return parts.isNotEmpty ? parts.join(', ') : '-';
  }

  String get shortDescription {
    if (propertyDescription == null) return '';
    return propertyDescription!.length > 100
        ? '${propertyDescription!.substring(0, 100)}...'
        : propertyDescription!;
  }

  bool get hasImages => images.isNotEmpty;
  String? get primaryImage => hasImages ? images.first : null;

  PropertyAuction copyWith({
    String? id,
    String? eventType,
    String? eventNo,
    String? nitRefNo,
    String? eventTitle,
    String? eventBank,
    String? eventBranch,
    String? propertyCategory,
    String? propertySubCategory,
    String? propertyDescription,
    String? borrowerName,
    double? reservePrice,
    double? tenderFee,
    double? priceBid,
    double? bidIncrementValue,
    int? autoExtensionTime,
    int? noOfAutoExtension,
    bool? dscRequired,
    double? emdAmount,
    String? emdBankName,
    String? emdAccountNo,
    String? emdIfscCode,
    DateTime? pressReleaseDate,
    DateTime? inspectionDateFrom,
    DateTime? inspectionDateTo,
    DateTime? submissionLastDate,
    DateTime? offerOpeningDate,
    DateTime? auctionStartDate,
    DateTime? auctionEndDate,
    String? propertyAddress,
    String? propertyCity,
    String? propertyState,
    List<String>? images,
    PropertyAuctionStatus? status,
    bool? isActive,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PropertyAuction(
      id: id ?? this.id,
      eventType: eventType ?? this.eventType,
      eventNo: eventNo ?? this.eventNo,
      nitRefNo: nitRefNo ?? this.nitRefNo,
      eventTitle: eventTitle ?? this.eventTitle,
      eventBank: eventBank ?? this.eventBank,
      eventBranch: eventBranch ?? this.eventBranch,
      propertyCategory: propertyCategory ?? this.propertyCategory,
      propertySubCategory: propertySubCategory ?? this.propertySubCategory,
      propertyDescription: propertyDescription ?? this.propertyDescription,
      borrowerName: borrowerName ?? this.borrowerName,
      reservePrice: reservePrice ?? this.reservePrice,
      tenderFee: tenderFee ?? this.tenderFee,
      priceBid: priceBid ?? this.priceBid,
      bidIncrementValue: bidIncrementValue ?? this.bidIncrementValue,
      autoExtensionTime: autoExtensionTime ?? this.autoExtensionTime,
      noOfAutoExtension: noOfAutoExtension ?? this.noOfAutoExtension,
      dscRequired: dscRequired ?? this.dscRequired,
      emdAmount: emdAmount ?? this.emdAmount,
      emdBankName: emdBankName ?? this.emdBankName,
      emdAccountNo: emdAccountNo ?? this.emdAccountNo,
      emdIfscCode: emdIfscCode ?? this.emdIfscCode,
      pressReleaseDate: pressReleaseDate ?? this.pressReleaseDate,
      inspectionDateFrom: inspectionDateFrom ?? this.inspectionDateFrom,
      inspectionDateTo: inspectionDateTo ?? this.inspectionDateTo,
      submissionLastDate: submissionLastDate ?? this.submissionLastDate,
      offerOpeningDate: offerOpeningDate ?? this.offerOpeningDate,
      auctionStartDate: auctionStartDate ?? this.auctionStartDate,
      auctionEndDate: auctionEndDate ?? this.auctionEndDate,
      propertyAddress: propertyAddress ?? this.propertyAddress,
      propertyCity: propertyCity ?? this.propertyCity,
      propertyState: propertyState ?? this.propertyState,
      images: images ?? this.images,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        eventType,
        eventNo,
        nitRefNo,
        eventTitle,
        eventBank,
        eventBranch,
        propertyCategory,
        propertySubCategory,
        propertyDescription,
        borrowerName,
        reservePrice,
        tenderFee,
        priceBid,
        bidIncrementValue,
        autoExtensionTime,
        noOfAutoExtension,
        dscRequired,
        emdAmount,
        emdBankName,
        emdAccountNo,
        emdIfscCode,
        pressReleaseDate,
        inspectionDateFrom,
        inspectionDateTo,
        submissionLastDate,
        offerOpeningDate,
        auctionStartDate,
        auctionEndDate,
        propertyAddress,
        propertyCity,
        propertyState,
        images,
        status,
        isActive,
        createdBy,
        createdAt,
        updatedAt,
      ];
}
