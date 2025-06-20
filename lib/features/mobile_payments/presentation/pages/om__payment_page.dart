import 'package:flutter/material.dart';
import 'package:country_list_pick/country_list_pick.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/keyboard.dart';
import 'mobile_money_amount_page.dart';

class OmPaymentPage extends StatefulWidget {
  final String network;

  const OmPaymentPage({Key? key, required this.network}) : super(key: key);

  @override
  _OmPaymentPageState createState() => _OmPaymentPageState();
}

class _OmPaymentPageState extends State<OmPaymentPage> {
  late List<List<dynamic>> keys;
  late String phoneNumber;
  late String otp;
  bool enteringOtp = false;
  String countryCode = '+225';

  @override
  void initState() {
    super.initState();
    phoneNumber = '';
    otp = '';
    keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', const Icon(Icons.keyboard_arrow_left, color: Colors.black)],
    ];
  }

  void onKeyTap(String val) {
    setState(() {
      if (!enteringOtp && phoneNumber.length < 10) {
        phoneNumber += val;
        if (phoneNumber.length == 10) {
          enteringOtp = true;
        }
      } else if (enteringOtp && otp.length < 4) {
        otp += val;
      }
    });
  }

  // void onBackspacePress() {
  //   setState(() {
  //     if (enteringOtp && otp.isNotEmpty) {
  //       otp = otp.substring(0, otp.length - 1);
  //     } else if (!enteringOtp && phoneNumber.isNotEmpty) {
  //       phoneNumber = phoneNumber.substring(0, phoneNumber.length - 1);
  //     }
  //     if (phoneNumber.length < 10) {
  //       enteringOtp = false;
  //     }
  //   });
  // }
  void onBackspacePress() {
    setState(() {
      if (enteringOtp && otp.isNotEmpty) {
        // Supprime OTP normalement
        otp = otp.substring(0, otp.length - 1);
      } else if (enteringOtp && otp.isEmpty) {
        // Revenir au champ numéro
        enteringOtp = false;
      } else if (!enteringOtp && phoneNumber.isNotEmpty) {
        phoneNumber = phoneNumber.substring(0, phoneNumber.length - 1);
      }
    });
  }

  Widget buildHeader() {
    final style = TextStyle(
        fontSize: 16,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w300,
        color: textColor);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 25.0),
      child: Text(
        enteringOtp
            ? "Entrez le code OTP à 4 lettres"
            : "Entrez le numéro de téléphone (10 chiffres)",
        style: style,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget buildInputFields() {
    TextStyle style = const TextStyle(
      fontSize: 28.0,
      fontWeight: FontWeight.w500,
      letterSpacing: 2,
      color: textColor,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CountryListPick(
                appBar: AppBar(title: const Text('Sélectionnez votre pays')),
                theme: CountryTheme(
                  isShowCode: true,
                  isShowFlag: true,
                  isShowTitle: false,
                  isDownIcon: true,
                  labelColor: Colors.black,
                ),
                initialSelection: '+225',
                onChanged: (code) => setState(() {
                  countryCode = code!.dialCode!;
                }),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  phoneNumber.padRight(10, '_'),
                  style: style,
                ),
              ),
              if (enteringOtp)
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () {
                    setState(() {
                      enteringOtp = false;
                      otp = '';
                    });
                  },
                ),
            ],
          ),
        ),

        // OTP
        if (enteringOtp) ...[
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              children: [
                const Text(
                  "OTP : ",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                Expanded(
                  child: Text(
                    otp.padRight(4, '_'),
                    style: style.copyWith(letterSpacing: 16),
                  ),
                ),
              ],
            ),
          ),
        ]
      ],
    );
  }

  Widget renderKeyboard() {
    return Column(
      children: keys
          .map(
            (row) => Row(
              children: row.map(
                (key) {
                  return Expanded(
                    child: KeyboardKey(
                      label: key,
                      value: key,
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

  Widget buildContinueButton() {
    bool ready = phoneNumber.length == 10 && otp.length == 4;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: GestureDetector(
        onTap: ready
            ? () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MobileMoneyAmountPage(
                      network: widget.network,
                      customerPhone: phoneNumber,
                      otp: otp,
                    ),
                  ),
                )
            : null,
        child: Container(
          height: 50.0,
          width: double.infinity,
          decoration: BoxDecoration(
            color: ready ? primaryColor : Colors.grey,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Center(
            child: Text(
              'Continuer',
              style: TextStyle(
                color: ready ? Colors.black : Colors.white,
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
    final media = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Paiement ${widget.network}".toUpperCase(),
          style: TextStyle(
              fontSize: 16,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              color: textColor),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            buildHeader(),
            const SizedBox(height: 30),
            Center(
              child: buildInputFields(),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Divider(thickness: 1),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.orange.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, -1)),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              renderKeyboard(),
              buildContinueButton(),
            ],
          ),
        ),
      ),
    );
  }
}
