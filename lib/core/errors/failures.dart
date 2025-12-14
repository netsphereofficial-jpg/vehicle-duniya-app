import 'package:equatable/equatable.dart';

/// Base failure class for domain layer errors
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Server/API failures
class ServerFailure extends Failure {
  const ServerFailure({
    super.message = 'Server error occurred. Please try again.',
    super.code,
  });
}

/// Network failures
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection. Please check your network.',
    super.code,
  });
}

/// Cache/Local storage failures
class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Local storage error occurred.',
    super.code,
  });
}

/// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure({
    super.message = 'Authentication failed. Please try again.',
    super.code,
  });

  factory AuthFailure.invalidOtp() => const AuthFailure(
        message: 'Invalid OTP. Please try again.',
        code: 'invalid-otp',
      );

  factory AuthFailure.otpExpired() => const AuthFailure(
        message: 'OTP has expired. Please request a new one.',
        code: 'otp-expired',
      );

  factory AuthFailure.tooManyRequests() => const AuthFailure(
        message: 'Too many requests. Please try again later.',
        code: 'too-many-requests',
      );

  factory AuthFailure.invalidPhone() => const AuthFailure(
        message: 'Invalid phone number.',
        code: 'invalid-phone',
      );

  factory AuthFailure.sessionExpired() => const AuthFailure(
        message: 'Session expired. Please login again.',
        code: 'session-expired',
      );
}

/// Firebase/Firestore failures
class FirebaseFailure extends Failure {
  const FirebaseFailure({
    super.message = 'Firebase error occurred. Please try again.',
    super.code,
  });

  factory FirebaseFailure.permissionDenied() => const FirebaseFailure(
        message: 'Permission denied. You don\'t have access to this resource.',
        code: 'permission-denied',
      );

  factory FirebaseFailure.notFound() => const FirebaseFailure(
        message: 'Data not found.',
        code: 'not-found',
      );

  factory FirebaseFailure.unavailable() => const FirebaseFailure(
        message: 'Service temporarily unavailable. Please try again.',
        code: 'unavailable',
      );
}

/// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.code,
  });
}

/// Bid-related failures
class BidFailure extends Failure {
  const BidFailure({
    super.message = 'Bid failed. Please try again.',
    super.code,
  });

  factory BidFailure.auctionEnded() => const BidFailure(
        message: 'This auction has ended.',
        code: 'auction-ended',
      );

  factory BidFailure.bidTooLow() => const BidFailure(
        message: 'Your bid is too low. Please enter a higher amount.',
        code: 'bid-too-low',
      );

  factory BidFailure.notVerified() => const BidFailure(
        message: 'Please complete KYC verification to place bids.',
        code: 'kyc-required',
      );

  factory BidFailure.alreadyHighestBidder() => const BidFailure(
        message: 'You are already the highest bidder.',
        code: 'already-highest',
      );
}

/// Payment failures
class PaymentFailure extends Failure {
  const PaymentFailure({
    super.message = 'Payment failed. Please try again.',
    super.code,
  });
}

/// Unknown/Generic failures
class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'An unexpected error occurred. Please try again.',
    super.code,
  });
}
