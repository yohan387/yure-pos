import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todouapp/core/constants/route_constants.dart';
import 'package:todouapp/core/di/injection.dart';
import 'package:todouapp/core/widgets/pin_input_display.dart';
import 'package:todouapp/core/widgets/pin_keyboard.dart';
import 'package:todouapp/features/auth/presentation/cubit/pin_cubit.dart';
import 'package:todouapp/features/auth/presentation/cubit/pin_state.dart';

class PinPage extends StatelessWidget {
  final PinMode mode;

  const PinPage({super.key, required this.mode});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<PinCubit>(param1: mode),
      child: const _PinPageContent(),
    );
  }
}

class _PinPageContent extends StatelessWidget {
  const _PinPageContent();

  void _handleBackButton(BuildContext context, PinState state) {
    if (state.isSetupMode) {
      if (state.isConfirmationStep) {
        // À l'étape de confirmation, revenir à l'étape de création
        context.read<PinCubit>().restart();
      } else {
        // À l'étape de création, quitter l'app (fermer la page)
        Navigator.of(context).pop();
      }
    } else {
      // Pour les autres modes, comportement normal
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PinCubit, PinState>(
      builder: (context, state) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) {
              _handleBackButton(context, state);
            }
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF080808)),
                onPressed: () => _handleBackButton(context, state),
              ),
            ),
            body: _buildBody(context, state),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, PinState state) {
    return BlocConsumer<PinCubit, PinState>(
        listener: (context, state) {
          if (state.step == PinStep.success) {
            // Navigation selon le mode
            Navigator.pushNamedAndRemoveUntil(
              context,
              RouteConstants.accueil,
              (route) => false,
            );
          }

          // APP-013: Trop de tentatives → Déconnexion
          if (state.step == PinStep.blocked) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              RouteConstants.login,
              (route) => false,
            );
          }

          // APP-015: Changement de terminal
          if (state.step == PinStep.terminalChange) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              RouteConstants.terminalSelection,
              (route) => false,
            );
          }

          // Vibration sur erreur
          if (state.showError) {
            HapticFeedback.vibrate();
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),
                // Logo
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_outline,
                    size: 40,
                    color: Color(0xFF080808),
                  ),
                ),
                const SizedBox(height: 40),
                // Titre dynamique
                Text(
                  state.title,
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF080808),
                  ),
                ),
                const SizedBox(height: 8),
                // Sous-titre dynamique
                if (state.subtitle.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      state.subtitle,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                const SizedBox(height: 60),
                // Affichage PIN
                PinInputDisplay(filledCount: state.currentPin.length),
                const SizedBox(height: 20),
                // Message d'erreur
                if (state.showError)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      state.errorMessage ?? 'Erreur',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.red,
                      ),
                    ),
                  ),
                const Spacer(),
                // Clavier
                PinKeyboard(
                  onDigitPressed: (digit) =>
                      context.read<PinCubit>().addDigit(digit),
                  onDeletePressed: () =>
                      context.read<PinCubit>().deleteLastDigit(),
                  deleteEnabled: state.canDelete,
                ),
                const SizedBox(height: 20),
                // Bouton "Passer cette étape" (mode setup, étape création uniquement)
                if (state.isSetupMode && state.isCreationStep)
                  TextButton(
                    onPressed: () => context.read<PinCubit>().skipSetup(),
                    child: Text(
                      'Passer cette étape',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                // Bouton "Recommencer" uniquement si mismatch
                if (state.step == PinStep.mismatch)
                  TextButton(
                    onPressed: () => context.read<PinCubit>().restart(),
                    child: Text(
                      'Recommencer',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                  ),
                // Bouton "PIN oublié ?" (mode verify uniquement)
                if (state.isVerifyMode)
                  TextButton(
                    onPressed: () => context.read<PinCubit>().forgotPin(),
                    child: Text(
                      'PIN oublié ?',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                // Bouton "Changer de terminal" (mode verify uniquement)
                if (state.isVerifyMode)
                  TextButton(
                    onPressed: () => context.read<PinCubit>().changeTerminal(),
                    child: Text(
                      'Changer de terminal',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      );
  }
}
