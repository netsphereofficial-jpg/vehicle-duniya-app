import 'package:equatable/equatable.dart';

/// User entity
class User extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? profileImage;
  final String? address;
  final bool isActive;
  final bool isKycVerified;
  final String? fcmToken;
  final String? referralCode;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.profileImage,
    this.address,
    this.isActive = true,
    this.isKycVerified = false,
    this.fcmToken,
    this.referralCode,
    this.createdAt,
    this.updatedAt,
  });

  bool get hasProfileImage => profileImage != null && profileImage!.isNotEmpty;

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  String get formattedPhone => '+91 $phone';

  User copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? profileImage,
    String? address,
    bool? isActive,
    bool? isKycVerified,
    String? fcmToken,
    String? referralCode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      address: address ?? this.address,
      isActive: isActive ?? this.isActive,
      isKycVerified: isKycVerified ?? this.isKycVerified,
      fcmToken: fcmToken ?? this.fcmToken,
      referralCode: referralCode ?? this.referralCode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        phone,
        email,
        profileImage,
        address,
        isActive,
        isKycVerified,
        fcmToken,
        referralCode,
        createdAt,
        updatedAt,
      ];
}
