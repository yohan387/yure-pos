import 'package:flutter/material.dart';
import 'package:todouapp/core/constants/colors.dart';

// ignore: must_be_immutable
class OnbordingDots extends StatelessWidget {
  bool isActive;
  OnbordingDots(this.isActive);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 3.3),
      height: isActive ? 10 : 12,
      width: isActive ? 36 : 12,
      decoration: BoxDecoration(
        color: isActive ? primaryColor : Color(0xFFE9ECEE),
        border: isActive
            ? Border.all(
                color: primaryColor,
                width: 2.0,
              )
            : Border.all(
                color: Colors.transparent,
                width: 1,
              ),
        borderRadius: BorderRadius.all(Radius.circular(isActive ? 12 : 5)),
      ),
    );
  }
}
