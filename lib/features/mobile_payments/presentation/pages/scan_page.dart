import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({Key? key}) : super(key: key);

  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  @override
  void initState() {
    super.initState();
  }

  renderConfirmButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 50.0),
      child: GestureDetector(
        onTap: () {},
        child: Container(
          height: 50.0,
          width: double.infinity,
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              'Valider',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
          "Scannez pour payer",
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Inter',
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 35.0),
              child: Text(
                "Utilisez l'application Wave pour scanner ce QR code et finaliser votre paiement en toute sécurité.",
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Inter',
                  color: textColor,
                  fontWeight: FontWeight.w300,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Center(
              child: Image.asset(
                'assets/images/scan_me.png',
                height: 300,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 25),
              child: Text(
                "Scannez pour payer avec Wave",
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Inter',
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              renderConfirmButton(),
            ],
          ),
        ),
      ),
    );
  }
}
