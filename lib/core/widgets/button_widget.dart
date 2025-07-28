import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../constants/route_constants.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({super.key, required this.text, required this.onPressed});
  final String text;
  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontSize: 16,
              fontFamily: 'Inter',
              color: Colors.white,
              fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class CancelButton extends StatelessWidget {
  const CancelButton({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamedAndRemoveUntil(
            context,
            RouteConstants.accueil,
            (route) => false,
          );
        },
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: greyColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontSize: 16,
              fontFamily: 'Inter',
              color: Colors.black,
              fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
