import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PinKeyboard extends StatelessWidget {
  final Function(String) onDigitPressed;
  final VoidCallback onDeletePressed;
  final bool deleteEnabled;

  const PinKeyboard({
    super.key,
    required this.onDigitPressed,
    required this.onDeletePressed,
    this.deleteEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildKeyboardRow(['1', '2', '3']),
          const SizedBox(height: 16),
          _buildKeyboardRow(['4', '5', '6']),
          const SizedBox(height: 16),
          _buildKeyboardRow(['7', '8', '9']),
          const SizedBox(height: 16),
          _buildKeyboardRow(['', '0', 'delete']),
        ],
      ),
    );
  }

  Widget _buildKeyboardRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((key) {
        if (key.isEmpty) {
          // Empty space for layout
          return Expanded(
            child: Container(
              height: 64,
            ),
          );
        } else if (key == 'delete') {
          // Delete button
          return Expanded(
            child: _buildDeleteButton(),
          );
        } else {
          // Digit button
          return Expanded(
            child: _buildDigitButton(key),
          );
        }
      }).toList(),
    );
  }

  Widget _buildDigitButton(String digit) {
    return InkWell(
      onTap: () => onDigitPressed(digit),
      borderRadius: BorderRadius.circular(32),
      child: Container(
        height: 64,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[100],
        ),
        child: Center(
          child: Text(
            digit,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF080808),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return InkWell(
      onTap: deleteEnabled ? onDeletePressed : null,
      borderRadius: BorderRadius.circular(32),
      child: Container(
        height: 64,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: deleteEnabled ? Colors.grey[100] : Colors.grey[50],
        ),
        child: Center(
          child: Icon(
            Icons.backspace_outlined,
            size: 24,
            color: deleteEnabled ? const Color(0xFF080808) : Colors.grey[400],
          ),
        ),
      ),
    );
  }
}
