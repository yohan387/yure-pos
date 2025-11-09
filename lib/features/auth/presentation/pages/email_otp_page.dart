import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:todouapp/core/constants/colors.dart';
import 'package:todouapp/core/constants/app_constants.dart';
import 'package:todouapp/core/constants/route_constants.dart';
import 'package:todouapp/core/utils/email_masker.dart';
import 'package:todouapp/core/widgets/button_widget.dart';
import 'package:todouapp/core/widgets/custom_snackbar.dart';
import 'package:todouapp/core/widgets/page_loader.dart';
import 'package:todouapp/features/auth/presentation/cubit/email_otp_cubit.dart';
import 'package:todouapp/features/auth/presentation/cubit/email_otp_state.dart';
import 'package:todouapp/features/auth/presentation/cubit/verify_email_otp_cubit.dart';
import 'package:todouapp/features/auth/presentation/cubit/verify_email_otp_state.dart';

class EmailOtpPage extends StatefulWidget {
  const EmailOtpPage({super.key});

  @override
  State<EmailOtpPage> createState() => _EmailOtpPageState();
}

class _EmailOtpPageState extends State<EmailOtpPage> {
  final TextEditingController _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final StreamController<ErrorAnimationType> _errorController =
      StreamController<ErrorAnimationType>();
  String? email;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (email == null) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      email = args?['email'] as String?;
      if (email != null) {
        context.read<EmailOtpCubit>().setEmail(email!);
      }
      context.read<EmailOtpCubit>().startTimer();
    }
  }

  @override
  void dispose() {
    _errorController.close();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          BlocListener<EmailOtpCubit, EmailOtpState>(
            listenWhen: (previous, current) =>
                previous.status != current.status,
            listener: (context, state) {
              if (state.status == EmailOtpStatus.failure &&
                  state.message != null &&
                  state.message != 'Le code OTP a expiré') {
                CustomSnackbar.showError(context, state.message!);
              } else if (state.status == EmailOtpStatus.resent) {
                CustomSnackbar.showSuccess(context, state.message!);
              }
            },
          ),
          BlocListener<VerifyEmailOtpCubit, VerifyEmailOtpState>(
            listenWhen: (previous, current) =>
                previous.status != current.status,
            listener: (context, state) {
              if (state.status == VerifyEmailOtpStatus.failure &&
                  state.message != null) {
                _errorController.add(ErrorAnimationType.shake);

                // Différencier code expiré vs code invalide
                final emailOtpState = context.read<EmailOtpCubit>().state;
                String errorMessage;
                if (emailOtpState.remainingSeconds == 0) {
                  // Timer client expiré
                  errorMessage = 'Code expiré. Veuillez demander un nouveau code.';
                } else if (state.message!.toLowerCase().contains('expiré')) {
                  // Serveur dit que le code est expiré (peut-être expiré côté serveur avant le timer client)
                  errorMessage = 'Code expiré. Veuillez demander un nouveau code.';
                } else {
                  // Code invalide
                  errorMessage = 'Code invalide. Veuillez réessayer.';
                }

                CustomSnackbar.showError(context, errorMessage);
              } else if (state.status == VerifyEmailOtpStatus.success) {
                if (mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    RouteConstants.terminalSelection,
                    (route) => false,
                  );
                }
              }
            },
          ),
        ],
        child: BlocBuilder<EmailOtpCubit, EmailOtpState>(
          builder: (context, emailOtpState) {
            return BlocBuilder<VerifyEmailOtpCubit, VerifyEmailOtpState>(
              builder: (context, verifyOtpState) {
                return Stack(
                  children: [
                    Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),
                              Text(
                                'Vérification de l\'email',
                                style: GoogleFonts.inter(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF080808),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Un code a été envoyé à',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                email != null
                                    ? EmailMasker.maskEmail(email!)
                                    : '',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: primaryColor,
                                ),
                              ),
                              const SizedBox(height: 24),
                              if (emailOtpState.remainingSeconds > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: emailOtpState.remainingSeconds < 60
                                        ? Colors.red.withValues(alpha: 0.1)
                                        : primaryColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.timer_outlined,
                                        color: emailOtpState.remainingSeconds < 60
                                            ? Colors.red
                                            : primaryColor,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Code valide encore ${_formatTime(emailOtpState.remainingSeconds)}',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: emailOtpState.remainingSeconds < 60
                                              ? Colors.red
                                              : primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (emailOtpState.remainingSeconds == 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.error_outline,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Le code a expiré',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 24),
                              PinCodeTextField(
                                appContext: context,
                                length: AppConstants.otpLength,
                                controller: _otpController,
                                keyboardType: TextInputType.number,
                                enabled: emailOtpState.remainingSeconds > 0,
                                autoFocus: true,
                                enableActiveFill: false,
                                autoDisposeControllers: false,
                                errorAnimationController: _errorController,
                                pastedTextStyle: GoogleFonts.inter(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: primaryColor,
                                ),
                                pinTheme: PinTheme(
                                  shape: PinCodeFieldShape.underline,
                                  activeColor: Theme.of(context).primaryColor,
                                  inactiveColor: Colors.grey,
                                  selectedColor: Theme.of(context).primaryColor,
                                  disabledColor: Colors.grey[300],
                                ),
                                validator: (value) {
                                  if (value?.length != AppConstants.otpLength) {
                                    return 'Veuillez saisir un OTP valide';
                                  }
                                  return null;
                                },
                                onChanged: (String value) {},
                              ),
                              const SizedBox(height: 30),
                              CustomButton(
                                text: 'Vérifier',
                                onPressed: verifyOtpState.status ==
                                            VerifyEmailOtpStatus.loading ||
                                        emailOtpState.remainingSeconds == 0
                                    ? null
                                    : () {
                                        if (_formKey.currentState?.validate() ??
                                            false) {
                                          FocusScope.of(context).unfocus();
                                          context
                                              .read<VerifyEmailOtpCubit>()
                                              .verifyOtp(
                                                email!,
                                                _otpController.text,
                                              );
                                        }
                                      },
                              ),
                              const SizedBox(height: 20),
                              TextButton(
                                onPressed: emailOtpState.resendCooldown > 0 ||
                                        emailOtpState.status ==
                                            EmailOtpStatus.resending
                                    ? null
                                    : () {
                                        context
                                            .read<EmailOtpCubit>()
                                            .resendOtp();
                                      },
                                child: Text(
                                  emailOtpState.resendCooldown > 0
                                      ? 'Vous pouvez renvoyer dans ${emailOtpState.resendCooldown}s'
                                      : 'Renvoyer le code',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: emailOtpState.resendCooldown > 0
                                        ? Colors.grey
                                        : primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (emailOtpState.status == EmailOtpStatus.loading ||
                        emailOtpState.status == EmailOtpStatus.resending ||
                        verifyOtpState.status == VerifyEmailOtpStatus.loading)
                      const FullPageLoader(),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
