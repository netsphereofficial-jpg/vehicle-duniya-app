part of 'auth_bloc.dart';

/// Auth events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Check authentication status
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Send OTP to phone number
class AuthSendOtpRequested extends AuthEvent {
  final String phoneNumber;

  const AuthSendOtpRequested(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

/// Verify OTP
class AuthVerifyOtpRequested extends AuthEvent {
  final String otp;

  const AuthVerifyOtpRequested(this.otp);

  @override
  List<Object?> get props => [otp];
}

/// Resend OTP
class AuthResendOtpRequested extends AuthEvent {
  const AuthResendOtpRequested();
}

/// Update profile
class AuthUpdateProfileRequested extends AuthEvent {
  final User user;

  const AuthUpdateProfileRequested(this.user);

  @override
  List<Object?> get props => [user];
}

/// Upload profile image
class AuthUploadProfileImageRequested extends AuthEvent {
  final List<int> imageData;

  const AuthUploadProfileImageRequested(this.imageData);

  @override
  List<Object?> get props => [imageData];
}

/// Sign out
class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

/// Clear error
class AuthErrorCleared extends AuthEvent {
  const AuthErrorCleared();
}
