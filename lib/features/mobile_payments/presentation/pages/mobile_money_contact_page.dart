import 'package:flutter/material.dart';
import 'package:todouapp/features/mobile_payments/presentation/pages/mobile_money_amount_page.dart';
import 'package:todouapp/features/payments/presentation/pages/payment_page.dart';
import 'package:country_list_pick/country_list_pick.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/keyboard.dart';
import 'mobile_money_page.dart';

class MobileMoneyContactPage extends StatefulWidget {
  final String network;
  final double amount;
  const MobileMoneyContactPage({
    super.key,
    required this.network,
    required this.amount,
  });

  @override
  _MobileMoneyContactPageState createState() => _MobileMoneyContactPageState();
}

class _MobileMoneyContactPageState extends State<MobileMoneyContactPage> {
  late List<List<dynamic>> keys;
  late String phoneNumber;

  @override
  void initState() {
    super.initState();
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
    phoneNumber = '';
  }

  String country = '+225';

  onKeyTap(val) {
    setState(() {
      phoneNumber += val;
    });
  }

  onBackspacePress() {
    if (phoneNumber.isEmpty) return;
    setState(() {
      phoneNumber = phoneNumber.substring(0, phoneNumber.length - 1);
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
    TextStyle numnerStyle = const TextStyle(
      fontSize: 30.0,
      fontFamily: 'Inter',
      color: textColor,
      fontWeight: FontWeight.w400,
    );

    String display = phoneNumber.isEmpty ? '0' : phoneNumber;

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              'Numéro de téléphone',
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
            child: Row(
              children: [
                CountryListPick(
                  appBar: AppBar(
                    title: const Text(
                      'Selectionnez votre pays',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  theme: CountryTheme(
                    searchText: 'Recherche',
                    searchHintText: 'Rechercher ici',
                    lastPickText: '',
                    isShowFlag: true,
                    isShowTitle: false,
                    isShowCode: true,
                    isDownIcon: true,
                    showEnglishName: false,
                    labelColor: Colors.black,
                    alphabetTextColor: Colors.black,
                    alphabetSelectedTextColor: Colors.black,
                  ),
                  initialSelection: '+225',
                  onChanged: (CountryCode? code) {
                    setState(() {
                      country = code!.dialCode!;
                    });
                    //print(country);
                  },
                ),
                Center(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: display, style: numnerStyle),
                        // TextSpan(text: '', style: currencyStyle),
                      ],
                    ),
                  ),
                ),
              ],
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
        onTap: phoneNumber.isNotEmpty
            ? () {
                if (widget.network == 'WAVE' ||
                    widget.network == 'MTN' ||
                    widget.network == 'MOOV') {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //       builder: (context) => MobileMoneyAmountPage(
                  //             network: widget.network,
                  //             customerPhone: phoneNumber,
                  //           )),
                  // );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MobilePaymentScreen(
                        amount: widget.amount,
                        currency: 'XOF',
                        network: widget.network,
                        customerPhone: phoneNumber,
                      ),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PaymentPage()),
                  );
                }
              }
            : null,
        child: Container(
          height: 50.0,
          width: double.infinity,
          decoration: BoxDecoration(
            color: phoneNumber.isNotEmpty ? primaryColor : Colors.grey,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Center(
            child: Text(
              'Continuer',
              style: TextStyle(
                color: phoneNumber.isNotEmpty ? Colors.white : Colors.white,
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
          "Entrez le numéro de téléphone".toUpperCase(),
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
                "Saisissez le numéro d'encaissement",
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Inter',
                  color: textColor,
                  fontWeight: FontWeight.w300,
                ),
                textAlign: TextAlign.center,
              ),
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
              // ignore: deprecated_member_use
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
              renderConfirmButton(),
            ],
          ),
        ),
      ),
    );
  }
}
