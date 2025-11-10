import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Type de snackbar
enum SnackbarType {
  error,   // Erreur - Icône rouge
  warning, // Attention - Icône jaune/orange
  success, // Succès - Icône verte
  info,    // Information - Icône blanche/bleue
}

class CustomSnackbar {
  /// Affiche un snackbar personnalisé avec icône et titre
  static void show(
    BuildContext context,
    SnackbarType type,
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 4),
  }) {
    // Déterminer les propriétés selon le type
    final config = _getSnackbarConfig(type, title);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: _SnackbarContent(
          icon: config.icon,
          iconColor: config.iconColor,
          title: config.title,
          message: message,
        ),
        backgroundColor: const Color(0xFF1A1A1A), // Fond noir
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        duration: duration,
        elevation: 6,
      ),
    );
  }

  // Méthodes de compatibilité pour l'ancien code
  static void showError(BuildContext context, String message) {
    show(context, SnackbarType.error, message);
  }

  static void showWarning(BuildContext context, String message) {
    show(context, SnackbarType.warning, message);
  }

  static void showSuccess(BuildContext context, String message) {
    show(context, SnackbarType.success, message);
  }

  static void showInfo(BuildContext context, String message) {
    show(context, SnackbarType.info, message);
  }

  /// Configuration par défaut selon le type
  static _SnackbarConfig _getSnackbarConfig(SnackbarType type, String? title) {
    switch (type) {
      case SnackbarType.error:
        return _SnackbarConfig(
          icon: Icons.error_outline,
          iconColor: const Color(0xFFEF4444), // Rouge
          title: title ?? 'Erreur',
        );
      case SnackbarType.warning:
        return _SnackbarConfig(
          icon: Icons.warning_amber_rounded,
          iconColor: const Color(0xFFF59E0B), // Orange/Jaune
          title: title ?? 'Attention',
        );
      case SnackbarType.success:
        return _SnackbarConfig(
          icon: Icons.check_circle_outline,
          iconColor: const Color(0xFF10B981), // Vert
          title: title ?? 'Succès',
        );
      case SnackbarType.info:
        return _SnackbarConfig(
          icon: Icons.info_outline,
          iconColor: const Color(0xFF60A5FA), // Bleu clair
          title: title ?? 'Information',
        );
    }
  }
}

/// Configuration du snackbar
class _SnackbarConfig {
  final IconData icon;
  final Color iconColor;
  final String title;

  _SnackbarConfig({
    required this.icon,
    required this.iconColor,
    required this.title,
  });
}

/// Widget de contenu du snackbar
class _SnackbarContent extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;

  const _SnackbarContent({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ligne 1 : Icône + Titre
        Row(
          children: [
            Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Ligne 2 : Message détaillé
        Padding(
          padding: const EdgeInsets.only(left: 36), // Aligné avec le texte du titre
          child: Text(
            message,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ),
      ],
    );
  }
}
