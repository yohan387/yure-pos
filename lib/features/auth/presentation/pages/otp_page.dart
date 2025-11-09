import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:todouapp/core/constants/colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/widgets/button_widget.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/widgets/page_loader.dart';
import '../bloc/auth_bloc.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final TextEditingController _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final StreamController<ErrorAnimationType> _errorController =
      StreamController<ErrorAnimationType>();

  Timer? _timer;
  int _remainingSeconds = 300; // 5 minutes
  int _resendCooldown = 0;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _remainingSeconds = 300;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
          } else {
            timer.cancel();
          }
        });
      }
    });
  }

  void _startResendCooldown() {
    _resendCooldown = 60;
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_resendCooldown > 0) {
            _resendCooldown--;
          } else {
            timer.cancel();
          }
        });
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _errorController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.statusOtp == AuthStatus.failure) {
            _errorController.add(ErrorAnimationType.shake);

            // Différencier code expiré vs code invalide
            String errorMessage;
            if (_remainingSeconds == 0) {
              // Timer client expiré
              errorMessage = 'Code expiré. Veuillez demander un nouveau code.';
            } else if (state.message?.toLowerCase().contains('expiré') == true) {
              // Serveur dit que le code est expiré (peut-être expiré côté serveur avant le timer client)
              errorMessage = 'Code expiré. Veuillez demander un nouveau code.';
            } else {
              // Code invalide
              errorMessage = 'Code invalide. Veuillez réessayer.';
            }

            CustomSnackbar.showError(context, errorMessage);
          } else if (state.statusOtp == AuthStatus.success &&
              state.isAuthenticated) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              RouteConstants.terminalSelection,
              (route) => false,
            );
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(height: 50),
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF080808),
                            ),
                            children: [
                              TextSpan(
                                text: 'Bienvenue',
                                style: GoogleFonts.inter(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF080808),
                                ),
                              ),
                              TextSpan(
                                text: state.merchantName != null
                                    ? ' ${state.merchantName}'
                                    : '',
                                style: GoogleFonts.inter(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: primaryColor,
                                ),
                              ),
                              TextSpan(
                                text: ' !',
                                style: GoogleFonts.inter(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF080808),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          "Saisissez l'OTP envoyé à votre appareil",
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (_remainingSeconds > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: _remainingSeconds < 60
                                  ? Colors.red.withValues(alpha: 0.1)
                                  : primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.timer_outlined,
                                  color: _remainingSeconds < 60
                                      ? Colors.red
                                      : primaryColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Code valide encore ${_formatTime(_remainingSeconds)}',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: _remainingSeconds < 60
                                        ? Colors.red
                                        : primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (_remainingSeconds == 0)
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
                          enabled: _remainingSeconds > 0,
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
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            return CustomButton(
                              text: 'Vérifier',
                              onPressed: state.statusOtp == AuthStatus.loading ||
                                      _remainingSeconds == 0
                                  ? null
                                  : () async {
                                      final storage = FlutterSecureStorage();

                                      final code =
                                          await storage.read(key: 'code');

                                      if (_formKey.currentState?.validate() ??
                                          false) {
                                        FocusScope.of(context).unfocus();
                                        context.read<AuthBloc>().add(
                                              VerifyOtpEvent(
                                                  _otpController.text, '$code'),
                                            );
                                      }
                                    },
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: _resendCooldown > 0 || _isResending
                              ? null
                              : () async {
                                  setState(() {
                                    _isResending = true;
                                  });

                                  final storage = FlutterSecureStorage();
                                  final code = await storage.read(key: 'code');

                                  if (code != null) {
                                    // Trigger verifyCode again to resend OTP
                                    context.read<AuthBloc>().add(
                                          VerifyCodeEvent(code),
                                        );

                                    // Reset timer and start cooldown
                                    _startTimer();
                                    _startResendCooldown();
                                    _otpController.clear();

                                    CustomSnackbar.showSuccess(
                                      context,
                                      'Un nouveau code a été envoyé',
                                    );
                                  }

                                  setState(() {
                                    _isResending = false;
                                  });
                                },
                          child: Text(
                            _resendCooldown > 0
                                ? 'Vous pouvez renvoyer dans ${_resendCooldown}s'
                                : 'Renvoyer le code',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: _resendCooldown > 0
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
              if (state.statusOtp == AuthStatus.loading) const FullPageLoader(),
            ],
          );
        },
      ),
    );
  }
}
