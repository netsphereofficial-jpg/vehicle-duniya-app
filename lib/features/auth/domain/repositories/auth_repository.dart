import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../shared/domain/entities/user.dart';

/// Auth repository interface
abstract class AuthRepository {
  /// Send OTP to phone number
  Future<Either<Failure, String>> sendOtp(String phoneNumber);

  /// Verify OTP and sign in
  Future<Either<Failure, User>> verifyOtp({
    required String verificationId,
    required String otp,
  });

  /// Get current user
  Future<Either<Failure, User?>> getCurrentUser();

  /// Update user profile
  Future<Either<Failure, User>> updateProfile(User user);

  /// Upload profile image and return URL
  Future<Either<Failure, String>> uploadProfileImage(Uint8List imageData);

  /// Sign out
  Future<Either<Failure, void>> signOut();

  /// Check if user is signed in
  bool get isSignedIn;

  /// Get current user ID
  String? get currentUserId;

  /// Auth state changes stream
  Stream<User?> get authStateChanges;
}
