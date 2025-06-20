import 'package:flutter/material.dart';

import '../constants/colors.dart';

class Header extends StatefulWidget {
  const Header({super.key, required this.asset});
  final String asset;

  @override
  _HeaderState createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            widget.asset,
            height: 128,
          ),
        ],
      ),
    );
  }
}
