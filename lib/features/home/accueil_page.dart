import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todouapp/core/constants/colors.dart';
import 'package:todouapp/features/transactions/presentation/pages/home_page.dart';

import '../payments/presentation/pages/payment_page.dart';
import '../profil/presentation/pages/profil_page.dart';

class AccueilPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AccueilPageState();
}

class _AccueilPageState extends State<AccueilPage> {
  late Timer _timer;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final heure = TimeOfDay.fromDateTime(_now)
        .format(context)
        .replaceAll(RegExp(r' [AP]M'), '');

    final date =
        "${_now.day.toString().padLeft(2, '0')}.${_now.month.toString().padLeft(2, '0')}.${_now.year}";

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Yure POS',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          Flexible(
              child: Column(
            children: [
              Container(
                width: double.infinity,
                color: Colors.transparent,
                child: Image.asset("assets/images/home_img.png"),
              ),
              Container(
                width: double.infinity,
                color: Colors.transparent,
                child: Column(
                  children: [
                    Text(
                      heure,
                      style: GoogleFonts.inter(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 65,
                      ),
                    ),
                    Text(
                      date,
                      style: GoogleFonts.inter(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              /// Contenu principal
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(top: 55),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                  decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25))),
                  child: GridView.builder(
                    itemCount: 4,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 25,
                      mainAxisSpacing: 25,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (context, index) {
                      final icons = [
                        'Vente',
                        "Profile",
                        "Remboursement",
                        "Balance",
                      ];
                      final images = [
                        "assets/images/shopping_cart.png",
                        "assets/images/User_home.png",
                        "assets/images/history_icon.png",
                        "assets/images/purse_wallet.png",
                      ];
                      final destinations = [
                        PaymentPage(),
                        ProfilPage(),
                        HomePage(),
                        HomePage(),
                      ];
                      return InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => destinations[index],
                            ),
                          );
                        },
                        child: Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              children: [
                                Expanded(
                                  child: Image.asset(
                                    images[index],
                                    fit: BoxFit.contain,
                                    width: 50,
                                  ),
                                ),
                                Text(
                                  icons[index],
                                  style: GoogleFonts.inter(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }
}
