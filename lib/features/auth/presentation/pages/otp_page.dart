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
import '../../../../core/widgets/header.dart';
import '../../../../core/widgets/my_app_bar.dart';
import '../../../../core/widgets/page_loader.dart';
import '../bloc/auth_bloc.dart';

class OtpPage extends StatefulWidget {
  OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final TextEditingController _otpController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  @override
  void dispose() {
    //_otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.statusOtp == AuthStatus.failure) {
            CustomSnackbar.showError(context, state.message ?? 'OTP incorrect');
          } else if (state.statusOtp == AuthStatus.success &&
              state.isAuthenticated) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              RouteConstants.accueil,
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
                        const Text(
                          "Saisissez l'OTP envoyé à votre appareil",
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        PinCodeTextField(
                          appContext: context,
                          length: AppConstants.otpLength,
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          pinTheme: PinTheme(
                            shape: PinCodeFieldShape.underline,
                            activeColor: Theme.of(context).primaryColor,
                            inactiveColor: Colors.grey,
                            selectedColor: Theme.of(context).primaryColor,
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
                              text: 'Verifier',
                              onPressed: state.statusOtp == AuthStatus.loading
                                  ? null
                                  : () async {
                                      final storage = FlutterSecureStorage();

                                      final code =
                                          await storage.read(key: 'code');

                                      if (_formKey.currentState?.validate() ??
                                          false) {
                                        context.read<AuthBloc>().add(
                                              VerifyOtpEvent(
                                                  _otpController.text, '$code'),
                                            );
                                      }
                                    },
                            );
                          },
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
