part of 'auth_bloc.dart';

/// Auth status
enum AuthStatus {
  initial,
  loading,
  otpSent,
  verifying,
  authenticated,
  unauthenticated,
  profileIncomplete,
  error,
}

/// Auth state
class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final String? phoneNumber;
  final String? verificationId;
  final String? errorMessage;
  final bool canResendOtp;
  final int resendCountdown;
  final bool isUploadingImage;
  final String? uploadedImageUrl;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.phoneNumber,
    this.verificationId,
    this.errorMessage,
    this.canResendOtp = false,
    this.resendCountdown = 0,
    this.isUploadingImage = false,
    this.uploadedImageUrl,
  });

  bool get isLoading => status == AuthStatus.loading || status == AuthStatus.verifying;
  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isOtpSent => status == AuthStatus.otpSent;
  bool get hasError => status == AuthStatus.error;
  bool get needsProfile => status == AuthStatus.profileIncomplete;

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? phoneNumber,
    String? verificationId,
    String? errorMessage,
    bool? canResendOtp,
    int? resendCountdown,
    bool? isUploadingImage,
    String? uploadedImageUrl,
    bool clearError = false,
    bool clearUser = false,
    bool clearUploadedImage = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      phoneNumber: phoneNumber ?? this.phoneNumber,
      verificationId: verificationId ?? this.verificationId,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      canResendOtp: canResendOtp ?? this.canResendOtp,
      resendCountdown: resendCountdown ?? this.resendCountdown,
      isUploadingImage: isUploadingImage ?? this.isUploadingImage,
      uploadedImageUrl: clearUploadedImage ? null : (uploadedImageUrl ?? this.uploadedImageUrl),
    );
  }

  @override
  List<Object?> get props => [
        status,
        user,
        phoneNumber,
        verificationId,
        errorMessage,
        canResendOtp,
        resendCountdown,
        isUploadingImage,
        uploadedImageUrl,
      ];
}
