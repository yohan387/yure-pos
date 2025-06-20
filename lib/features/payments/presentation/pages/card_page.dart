import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class PaymentCardPage extends StatefulWidget {
  const PaymentCardPage({Key? key}) : super(key: key);

  @override
  _PaymentCardPageState createState() => _PaymentCardPageState();
}

class _PaymentCardPageState extends State<PaymentCardPage> {
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
              'Saisir manuellement',
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
        backgroundColor: Colors.white,
        title: Text(
          "Inserer une carte",
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
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 25.0),
              child: Text(
                "Veuillez insérer votre carte dans le terminal pour procéder au paiement.",
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Inter',
                  color: textColor,
                  fontWeight: FontWeight.w300,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Center(
              child: Image.asset('assets/images/scan_image.png'),
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
