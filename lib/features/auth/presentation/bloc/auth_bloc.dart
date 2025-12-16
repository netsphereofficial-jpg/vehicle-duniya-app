import 'dart:async';
import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/app_logger.dart';
import '../../../../shared/domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// Auth BLoC for managing authentication state
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  Timer? _resendTimer;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthState()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthSendOtpRequested>(_onSendOtpRequested);
    on<AuthVerifyOtpRequested>(_onVerifyOtpRequested);
    on<AuthResendOtpRequested>(_onResendOtpRequested);
    on<AuthUpdateProfileRequested>(_onUpdateProfileRequested);
    on<AuthUploadProfileImageRequested>(_onUploadProfileImageRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthErrorCleared>(_onErrorCleared);
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.blocEvent('AuthBloc', 'AuthCheckRequested');
    emit(state.copyWith(status: AuthStatus.loading));

    if (!_authRepository.isSignedIn) {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
      return;
    }

    final result = await _authRepository.getCurrentUser();
    result.fold(
      (failure) {
        emit(state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: failure.message,
        ));
      },
      (user) {
        if (user == null) {
          emit(state.copyWith(status: AuthStatus.unauthenticated));
        } else if (user.name.isEmpty) {
          emit(state.copyWith(
            status: AuthStatus.profileIncomplete,
            user: user,
          ));
        } else {
          emit(state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
          ));
        }
      },
    );
  }

  Future<void> _onSendOtpRequested(
    AuthSendOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.blocEvent('AuthBloc', 'AuthSendOtpRequested');
    emit(state.copyWith(
      status: AuthStatus.loading,
      phoneNumber: event.phoneNumber,
      clearError: true,
    ));

    final result = await _authRepository.sendOtp(event.phoneNumber);
    result.fold(
      (failure) {
        emit(state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        ));
      },
      (verificationId) {
        emit(state.copyWith(
          status: AuthStatus.otpSent,
          verificationId: verificationId,
          canResendOtp: false,
          resendCountdown: 30,
        ));
        _startResendTimer(emit);
      },
    );
  }

  Future<void> _onVerifyOtpRequested(
    AuthVerifyOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.blocEvent('AuthBloc', 'AuthVerifyOtpRequested');

    if (state.verificationId == null) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Please request OTP first',
      ));
      return;
    }

    emit(state.copyWith(status: AuthStatus.verifying, clearError: true));

    final result = await _authRepository.verifyOtp(
      verificationId: state.verificationId!,
      otp: event.otp,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(
          status: AuthStatus.otpSent,
          errorMessage: failure.message,
        ));
      },
      (user) {
        _cancelResendTimer();
        if (user.name.isEmpty) {
          emit(state.copyWith(
            status: AuthStatus.profileIncomplete,
            user: user,
          ));
        } else {
          emit(state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
          ));
        }
      },
    );
  }

  Future<void> _onResendOtpRequested(
    AuthResendOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.blocEvent('AuthBloc', 'AuthResendOtpRequested');

    if (state.phoneNumber == null || !state.canResendOtp) return;

    emit(state.copyWith(status: AuthStatus.loading, clearError: true));

    final result = await _authRepository.sendOtp(state.phoneNumber!);
    result.fold(
      (failure) {
        emit(state.copyWith(
          status: AuthStatus.otpSent,
          errorMessage: failure.message,
        ));
      },
      (verificationId) {
        emit(state.copyWith(
          status: AuthStatus.otpSent,
          verificationId: verificationId,
          canResendOtp: false,
          resendCountdown: 30,
        ));
        _startResendTimer(emit);
      },
    );
  }

  Future<void> _onUpdateProfileRequested(
    AuthUpdateProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.blocEvent('AuthBloc', 'AuthUpdateProfileRequested');
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));

    final result = await _authRepository.updateProfile(event.user);
    result.fold(
      (failure) {
        emit(state.copyWith(
          status: AuthStatus.profileIncomplete,
          errorMessage: failure.message,
        ));
      },
      (user) {
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          clearUploadedImage: true,
        ));
      },
    );
  }

  Future<void> _onUploadProfileImageRequested(
    AuthUploadProfileImageRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.blocEvent('AuthBloc', 'AuthUploadProfileImageRequested');
    emit(state.copyWith(isUploadingImage: true, clearError: true));

    final result = await _authRepository.uploadProfileImage(
      Uint8List.fromList(event.imageData),
    );

    result.fold(
      (failure) {
        emit(state.copyWith(
          isUploadingImage: false,
          errorMessage: failure.message,
        ));
      },
      (imageUrl) {
        emit(state.copyWith(
          isUploadingImage: false,
          uploadedImageUrl: imageUrl,
        ));
      },
    );
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.blocEvent('AuthBloc', 'AuthSignOutRequested');
    emit(state.copyWith(status: AuthStatus.loading));

    final result = await _authRepository.signOut();
    result.fold(
      (failure) {
        emit(state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        ));
      },
      (_) {
        emit(const AuthState(status: AuthStatus.unauthenticated));
      },
    );
  }

  void _onErrorCleared(
    AuthErrorCleared event,
    Emitter<AuthState> emit,
  ) {
    emit(state.copyWith(clearError: true));
  }

  void _startResendTimer(Emitter<AuthState> emit) {
    _cancelResendTimer();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.resendCountdown > 0) {
        // ignore: invalid_use_of_visible_for_testing_member
        emit(state.copyWith(resendCountdown: state.resendCountdown - 1));
      } else {
        // ignore: invalid_use_of_visible_for_testing_member
        emit(state.copyWith(canResendOtp: true));
        timer.cancel();
      }
    });
  }

  void _cancelResendTimer() {
    _resendTimer?.cancel();
    _resendTimer = null;
  }

  @override
  Future<void> close() {
    _cancelResendTimer();
    return super.close();
  }
}
