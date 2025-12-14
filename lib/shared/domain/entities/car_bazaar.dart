import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

/// Car bazaar listing status
enum CarBazaarStatus { active, sold, inactive }

extension CarBazaarStatusX on CarBazaarStatus {
  String get displayName => switch (this) {
        CarBazaarStatus.active => 'Active',
        CarBazaarStatus.sold => 'Sold',
        CarBazaarStatus.inactive => 'Inactive',
      };

  static CarBazaarStatus fromString(String? value) {
    return CarBazaarStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => CarBazaarStatus.active,
    );
  }
}

/// Car bazaar listing entity
class CarBazaarListing extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String? make;
  final String? model;
  final int? year;
  final String? fuelType;
  final String? transmission;
  final int? kmDriven;
  final int? owners;
  final String? registrationNumber;
  final String? color;
  final double price;
  final bool negotiable;
  final List<String> images;
  final String? shopId;
  final String? shopName;
  final String? contactPerson;
  final String? contactNumber;
  final String? location;
  final CarBazaarStatus status;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CarBazaarListing({
    required this.id,
    required this.title,
    this.description,
    this.make,
    this.model,
    this.year,
    this.fuelType,
    this.transmission,
    this.kmDriven,
    this.owners,
    this.registrationNumber,
    this.color,
    this.price = 0,
    this.negotiable = false,
    this.images = const [],
    this.shopId,
    this.shopName,
    this.contactPerson,
    this.contactNumber,
    this.location,
    this.status = CarBazaarStatus.active,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  String get formattedPrice => _currencyFormat.format(price);

  String get fullDescription {
    final parts = <String>[];
    if (make != null && make!.isNotEmpty) parts.add(make!);
    if (model != null && model!.isNotEmpty) parts.add(model!);
    if (year != null) parts.add('($year)');
    return parts.isNotEmpty ? parts.join(' ') : title;
  }

  String get formattedKm {
    if (kmDriven == null) return '-';
    if (kmDriven! >= 100000) {
      return '${(kmDriven! / 100000).toStringAsFixed(1)} Lakh km';
    }
    return '${NumberFormat('#,###').format(kmDriven)} km';
  }

  String get ownerInfo {
    if (owners == null) return '-';
    return owners == 1 ? '1st Owner' : '${owners}nd Owner';
  }

  bool get hasImages => images.isNotEmpty;
  String? get primaryImage => hasImages ? images.first : null;
  int get imageCount => images.length;

  bool get isAvailable => status == CarBazaarStatus.active && isActive;

  CarBazaarListing copyWith({
    String? id,
    String? title,
    String? description,
    String? make,
    String? model,
    int? year,
    String? fuelType,
    String? transmission,
    int? kmDriven,
    int? owners,
    String? registrationNumber,
    String? color,
    double? price,
    bool? negotiable,
    List<String>? images,
    String? shopId,
    String? shopName,
    String? contactPerson,
    String? contactNumber,
    String? location,
    CarBazaarStatus? status,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CarBazaarListing(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      fuelType: fuelType ?? this.fuelType,
      transmission: transmission ?? this.transmission,
      kmDriven: kmDriven ?? this.kmDriven,
      owners: owners ?? this.owners,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      color: color ?? this.color,
      price: price ?? this.price,
      negotiable: negotiable ?? this.negotiable,
      images: images ?? this.images,
      shopId: shopId ?? this.shopId,
      shopName: shopName ?? this.shopName,
      contactPerson: contactPerson ?? this.contactPerson,
      contactNumber: contactNumber ?? this.contactNumber,
      location: location ?? this.location,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        make,
        model,
        year,
        fuelType,
        transmission,
        kmDriven,
        owners,
        registrationNumber,
        color,
        price,
        negotiable,
        images,
        shopId,
        shopName,
        contactPerson,
        contactNumber,
        location,
        status,
        isActive,
        createdAt,
        updatedAt,
      ];
}
