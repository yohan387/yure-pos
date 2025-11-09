import 'package:flutter/material.dart';

class PinInputDisplay extends StatelessWidget {
  final int pinLength;
  final int filledCount;
  final Color filledColor;
  final Color emptyColor;

  const PinInputDisplay({
    super.key,
    this.pinLength = 4,
    required this.filledCount,
    this.filledColor = const Color(0xFF080808),
    this.emptyColor = const Color(0xFFE0E0E0),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        pinLength,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index < filledCount ? filledColor : emptyColor,
            border: Border.all(
              color: index < filledCount ? filledColor : emptyColor,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}
