import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todouapp/core/constants/colors.dart';
import 'package:todouapp/core/constants/route_constants.dart';
import 'package:todouapp/core/di/injection.dart';
import 'package:todouapp/core/widgets/custom_snackbar.dart';
import 'package:todouapp/core/widgets/page_loader.dart';
import 'package:todouapp/features/auth/domain/entities/terminal.dart';
import 'package:todouapp/features/auth/domain/usecases/get_pin_status.dart';
import 'package:todouapp/features/auth/domain/repositories/i_pin_repository.dart';
import 'package:todouapp/features/auth/presentation/cubit/terminal_selection_cubit.dart';
import 'package:todouapp/features/auth/presentation/cubit/terminal_selection_state.dart';

class TerminalSelectionPage extends StatefulWidget {
  const TerminalSelectionPage({super.key});

  @override
  State<TerminalSelectionPage> createState() => _TerminalSelectionPageState();
}

class _TerminalSelectionPageState extends State<TerminalSelectionPage> {
  @override
  void initState() {
    super.initState();
    // Load terminals when page opens
    context.read<TerminalSelectionCubit>().loadTerminals();
  }

  Color _getStatusColor(Terminal terminal) {
    if (terminal.isActive) return Colors.green;
    if (terminal.isInactive) return Colors.red;
    if (terminal.isPending) return Colors.orange;
    return Colors.grey;
  }

  String _getStatusText(Terminal terminal) {
    if (terminal.isActive) return 'Actif';
    if (terminal.isInactive) return 'Inactif';
    if (terminal.isPending) return 'En attente';
    return terminal.status;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 64,
        title: Text(
          'Sélection terminal',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocConsumer<TerminalSelectionCubit, TerminalSelectionState>(
        listener: (context, state) {
          if (state.status == TerminalSelectionStatus.failure) {
            if (state.message == 'Aucun terminal assigné') {
              // Show specific message for no terminals
              _showNoTerminalsDialog(context);
            } else {
              CustomSnackbar.showError(context, state.message ?? 'Erreur');
            }
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              if (state.status == TerminalSelectionStatus.loading)
                const FullPageLoader(),
              if (state.status == TerminalSelectionStatus.success)
                _buildTerminalsList(context, state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTerminalsList(
      BuildContext context, TerminalSelectionState state) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 4, left: 16, right: 16, bottom: 32),
      itemCount: state.terminals.length,
      itemBuilder: (context, index) {
        final terminal = state.terminals[index];
        final isSelected = state.selectedTerminal?.id == terminal.id;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildTerminalCard(
            context,
            terminal,
            isSelected,
          ),
        );
      },
    );
  }

  Widget _buildTerminalCard(
    BuildContext context,
    Terminal terminal,
    bool isSelected,
  ) {
    return InkWell(
      onTap: () async {
        final cubit = context.read<TerminalSelectionCubit>();
        final navigator = Navigator.of(context);

        cubit.selectTerminal(terminal);
        await cubit.confirmSelection();

        if (mounted) {
          // Vérifier le statut du PIN pour déterminer la navigation
          final getPinStatus = GetPinStatus(sl<IPinRepository>());
          final pinStatus = await getPinStatus();

          if (!mounted) return;

          if (pinStatus.needsPinVerification) {
            // PIN configuré → Vérifier le PIN
            navigator.pushNamedAndRemoveUntil(
              RouteConstants.pinVerify,
              (route) => false,
            );
          } else if (pinStatus.needsPinSetup) {
            // Pas de PIN et pas ignoré → Setup PIN
            navigator.pushNamedAndRemoveUntil(
              RouteConstants.pinSetup,
              (route) => false,
            );
          } else {
            // PIN ignoré → Accueil direct
            navigator.pushNamedAndRemoveUntil(
              RouteConstants.accueil,
              (route) => false,
            );
          }
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: primaryColor,
            width: 0.2,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Terminal Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryColor.withValues(alpha: 0.1)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.point_of_sale,
                color: primaryColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            // Terminal Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    terminal.name,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF080808),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    terminal.code,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(terminal).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _getStatusColor(terminal),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _getStatusText(terminal),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _getStatusColor(terminal),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Selection Radio
            Icon(
              Icons.navigate_next_rounded,
              color: isSelected ? primaryColor : Colors.grey[400],
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  void _showNoTerminalsDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          'Aucun terminal assigné',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Aucun terminal n\'est assigné à votre compte. Veuillez contacter le support.',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.grey[600],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Return to login
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: Text(
              'Retour',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
