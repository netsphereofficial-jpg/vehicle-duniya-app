import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinput/pinput.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../bloc/auth_bloc.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final _otpController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onVerifyOtp() {
    if (_otpController.text.length == 6) {
      context.read<AuthBloc>().add(
            AuthVerifyOtpRequested(_otpController.text),
          );
    }
  }

  void _onResendOtp() {
    context.read<AuthBloc>().add(const AuthResendOtpRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.verifyOtp),
      ),
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state.hasError && state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: AppColors.error,
                ),
              );
              _otpController.clear();
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: AppSizes.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSizes.xl),
                  // Icon
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_outline,
                        size: 40,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.lg),
                  Text(
                    'Verification Code',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    '${AppStrings.enterOtp}\n+91 ${state.phoneNumber ?? ''}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: AppSizes.xl),
                  // OTP Input
                  Center(
                    child: Pinput(
                      controller: _otpController,
                      focusNode: _focusNode,
                      length: 6,
                      onCompleted: (_) => _onVerifyOtp(),
                      defaultPinTheme: PinTheme(
                        width: 50,
                        height: 56,
                        textStyle: Theme.of(context).textTheme.headlineSmall,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                        ),
                      ),
                      focusedPinTheme: PinTheme(
                        width: 50,
                        height: 56,
                        textStyle: Theme.of(context).textTheme.headlineSmall,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.primary, width: 2),
                          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                        ),
                      ),
                      errorPinTheme: PinTheme(
                        width: 50,
                        height: 56,
                        textStyle: Theme.of(context).textTheme.headlineSmall,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.error),
                          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.xl),
                  AppButton(
                    text: AppStrings.verifyOtp,
                    onPressed: _onVerifyOtp,
                    isLoading: state.status == AuthStatus.verifying,
                    icon: Icons.check_circle_outline,
                  ),
                  const SizedBox(height: AppSizes.lg),
                  // Resend OTP
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Didn't receive the code? ",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      if (state.canResendOtp)
                        TextButton(
                          onPressed: _onResendOtp,
                          child: const Text(AppStrings.resendOtp),
                        )
                      else
                        Text(
                          'Resend in ${state.resendCountdown}s',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
