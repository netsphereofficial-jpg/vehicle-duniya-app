import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user.dart';

/// User data model for Firestore
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.phone,
    super.email,
    super.profileImage,
    super.address,
    super.isActive,
    super.isKycVerified,
    super.fcmToken,
    super.referralCode,
    super.createdAt,
    super.updatedAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel.fromMap(doc.id, data);
  }

  factory UserModel.fromMap(String id, Map<String, dynamic> data) {
    return UserModel(
      id: id,
      name: data['name'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      email: data['email'] as String?,
      profileImage: data['profileImage'] as String?,
      address: data['address'] as String?,
      isActive: data['isActive'] as bool? ?? true,
      isKycVerified: data['isKycVerified'] as bool? ?? false,
      fcmToken: data['fcmToken'] as String?,
      referralCode: data['referralCode'] as String?,
      createdAt: _parseDateTime(data['createdAt']),
      updatedAt: _parseDateTime(data['updatedAt']),
    );
  }

  factory UserModel.fromEntity(User entity) {
    return UserModel(
      id: entity.id,
      name: entity.name,
      phone: entity.phone,
      email: entity.email,
      profileImage: entity.profileImage,
      address: entity.address,
      isActive: entity.isActive,
      isKycVerified: entity.isKycVerified,
      fcmToken: entity.fcmToken,
      referralCode: entity.referralCode,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'profileImage': profileImage,
      'address': address,
      'isActive': isActive,
      'isKycVerified': isKycVerified,
      'fcmToken': fcmToken,
      'referralCode': referralCode,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'profileImage': profileImage,
      'address': address,
      'isKycVerified': isKycVerified,
      'fcmToken': fcmToken,
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
}
