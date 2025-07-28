import 'dart:developer';

import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:todouapp/core/widgets/button_widget.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/secure_storage.dart';
import '../../../../core/widgets/keyboard.dart';
import 'payment_methode_page.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({Key? key}) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late List<List<dynamic>> keys;
  late String amount;
  String curreny = 'EUR';

  @override
  void initState() {
    super.initState();
    getCurrency();
    keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      [
        '.',
        '0',
        const Icon(
          Icons.keyboard_arrow_left,
          color: Colors.black,
        )
      ],
    ];
    amount = '';
  }

  getCurrency() async {
    final secureStorage = SecureStorageService();

    final cyn = await secureStorage.getCurrency();
    log("$cyn");

    setState(() {
      curreny = '$cyn';
    });
  }

  onKeyTap(val) {
    if (val == '0' && amount.isEmpty) return;
    setState(() {
      amount = amount + val;
    });
  }

  onBackspacePress() {
    if (amount.isEmpty) return;
    setState(() {
      amount = amount.substring(0, amount.length - 1);
    });
  }

  renderKeyboard() {
    return Column(
      children: keys
          .map(
            (x) => Row(
              children: x.map(
                (y) {
                  return Expanded(
                    child: KeyboardKey(
                      label: y,
                      value: y,
                      onTap: (val) {
                        if (val is Widget) {
                          onBackspacePress();
                        } else {
                          onKeyTap(val);
                        }
                      },
                    ),
                  );
                },
              ).toList(),
            ),
          )
          .toList(),
    );
  }

  renderAmount() {
    TextStyle amountStyle = const TextStyle(
      fontSize: 30.0,
      fontFamily: 'Inter',
      color: textColor,
      fontWeight: FontWeight.w400,
    );

    TextStyle currencyStyle = const TextStyle(
      fontSize: 18.0,
      fontWeight: FontWeight.w400,
      color: Colors.black54,
    );

    String display = amount.isEmpty ? '0' : amount;

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              'Montant',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Center(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(text: display, style: amountStyle),
                    TextSpan(text: ' $curreny', style: currencyStyle),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Divider(
              thickness: 1,
              color: Colors.grey.shade300,
            ),
          ),
        ],
      ),
    );
  }

  renderConfirmButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: GestureDetector(
        onTap: amount.isNotEmpty && curreny.isNotEmpty
            ? () async {
                // await PaymentHelper.launchStripePayment(
                //     context, double.parse(amount));
                // Navigator.of(context).pushReplacement(
                //   MaterialPageRoute(
                //     builder: (context) =>
                //         ScannerReader(amount: double.parse(amount)),
                //   ),
                // );
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) =>
                        PaymentMethodePage(amount: double.parse(amount)),
                  ),
                );
              }
            : null,
        child: Container(
          height: 50.0,
          width: double.infinity,
          decoration: BoxDecoration(
            color: amount.isNotEmpty ? primaryColor : Colors.grey,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Center(
            child: Text(
              'Valider',
              style: TextStyle(
                color: amount.isNotEmpty ? Colors.white : Colors.white,
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
        centerTitle: true,
        title: Text(
          "Entrez le montant à encaisser".toUpperCase(),
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
                "Saisissez le montant total de la transaction",
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Inter',
                  color: textColor,
                  fontWeight: FontWeight.w300,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  curreny == "EUR"
                      ? "assets/images/round.png"
                      : "assets/images/uemoa.jpg",
                  width: 25,
                ),
                SizedBox(
                  width: 5,
                ),
                InkWell(
                  onTap: () {
                    showCurrencyPicker(
                      context: context,
                      showFlag: true,
                      showSearchField: false,
                      showCurrencyName: true,
                      showCurrencyCode: true,
                      favorite: [curreny],
                      currencyFilter: <String>[
                        'EUR',
                        'XOF',
                      ],
                      onSelect: (Currency currency) async {
                        print('Select currency: ${currency.code}');
                        setState(() {
                          curreny = currency.name == "Euro" ? "EUR" : "XOF";
                        });
                        final secureStorage = SecureStorageService();

                        await secureStorage.saveCurrency(
                            currency.name == "Euro" ? "EUR" : "XOF");
                      },
                    );
                  },
                  child: const Text(
                    'Choisir la devise',
                    style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Inter',
                        color: primaryColor,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            renderAmount(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              renderKeyboard(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CancelButton(text: "ANNULER"),
                  )),
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CustomButton(
                      text: "VALIDER",
                      onPressed: amount.isNotEmpty
                          ? () async {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => PaymentMethodePage(
                                      amount: double.parse(amount)),
                                ),
                              );
                            }
                          : null,
                    ),
                  ))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
