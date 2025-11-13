import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/widgets/button_widget.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/widgets/page_loader.dart';
import '../bloc/auth_bloc.dart';

class LoginPage extends StatelessWidget {
  final _codeController = TextEditingController();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.failure) {
            log('login function ${state.message}');
            CustomSnackbar.showError(
                context, state.message ?? 'Terminal introuvable');
          } else if (state.status == AuthStatus.success) {
            Navigator.pushNamed(context, RouteConstants.otp);
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 30, bottom: 20),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 30),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Code du terminal",
                              style: TextStyle(
                                  fontSize: 24,
                                  fontFamily: 'Inter',
                                  color: textColor,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Si vous ne l'avez veuillez contacter votre administrateur",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Inter',
                                  color: textColor,
                                  fontWeight: FontWeight.w300),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 45),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 3),
                                        child: Text("Code du terminal",
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontFamily: 'Inter',
                                                color: textColor,
                                                fontWeight: FontWeight.w400)),
                                      ),
                                      TextFormField(
                                        controller: _codeController,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return "Veillez saisir le code";
                                          } else {
                                            return null;
                                          }
                                        },
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                  color: Colors.grey.shade200)),
                                          focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                              borderSide: BorderSide(
                                                  color: Colors.grey.shade800)),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 30),
                                  CustomButton(
                                    text: 'Valider',
                                    onPressed:
                                        state.status == AuthStatus.loading
                                            ? null
                                            : () {
                                                if (_formKey.currentState
                                                        ?.validate() ??
                                                    false) {
                                                  context.read<AuthBloc>().add(
                                                        VerifyCodeEvent(
                                                            _codeController.text
                                                                .trim()),
                                                      );
                                                } else {
                                                  CustomSnackbar.showError(
                                                      context,
                                                      "Veuillez entrer un code valide (6 chiffres)");
                                                }
                                              },
                                  ),
                                  const SizedBox(height: 20),
                                  // Lien vers connexion par email
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                          context, RouteConstants.emailLogin);
                                    },
                                    child: Text(
                                      'Se connecter avec email et mot de passe',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'Inter',
                                        color: primaryColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (state.status == AuthStatus.loading) const FullPageLoader(),
            ],
          );
        },
      ),
    );
  }

  final _formKey = GlobalKey<FormState>();
}
