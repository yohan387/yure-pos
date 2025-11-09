import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todouapp/core/constants/route_constants.dart';
import 'package:todouapp/core/widgets/pin_input_display.dart';
import 'package:todouapp/core/widgets/pin_keyboard.dart';
import 'package:todouapp/features/auth/presentation/cubit/pin_creation_cubit.dart';
import 'package:todouapp/features/auth/presentation/cubit/pin_creation_state.dart';

class PinCreationPage extends StatelessWidget {
  const PinCreationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF080808)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<PinCreationCubit, PinCreationState>(
        listener: (context, state) {
          // Auto-navigate to confirmation when PIN is complete
          if (state.status == PinCreationStatus.complete) {
            // Small delay for better UX
            Future.delayed(const Duration(milliseconds: 300), () {
              if (context.mounted) {
                // Navigator.pushNamed(
                //   context,
                //   RouteConstants.pinConfirmation,
                //   arguments: {'pin': state.currentPin},
                // );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Code PIN créé avec succès'),
                    duration: const Duration(seconds: 2),
                  ),
                );
                // Reset the cubit for when user comes back
                context.read<PinCreationCubit>().reset();
              }
            });
          }
        },
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Logo placeholder - you can add your logo here
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
              // Title
              Text(
                'Créez un code PIN',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF080808),
                ),
              ),
              const SizedBox(height: 8),
              // Subtitle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Pour sécuriser l\'accès rapide à votre application',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              const SizedBox(height: 60),
              // PIN Display
              BlocBuilder<PinCreationCubit, PinCreationState>(
                builder: (context, state) {
                  return PinInputDisplay(
                    filledCount: state.currentPin.length,
                  );
                },
              ),
              const Spacer(),
              // Keyboard
              BlocBuilder<PinCreationCubit, PinCreationState>(
                builder: (context, state) {
                  return PinKeyboard(
                    onDigitPressed: (digit) {
                      context.read<PinCreationCubit>().addDigit(digit);
                    },
                    onDeletePressed: () {
                      context.read<PinCreationCubit>().deleteLastDigit();
                    },
                    deleteEnabled: state.canDelete,
                  );
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
