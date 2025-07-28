import 'package:flutter/material.dart';
import 'package:todouapp/features/payments/presentation/pages/insert_topay_page.dart';
import 'package:todouapp/features/payments/presentation/pages/link_topay_page.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/gateway_list.dart';
import '../../../../core/utils/secure_storage.dart';
import '../../../mobile_payments/presentation/pages/mobile_money_contact_page.dart';
import '../../../mobile_payments/presentation/pages/om__payment_page.dart';
import '../../../transactions/presentation/widgets/payment_gateway.dart';

class PaymentMethodePage extends StatefulWidget {
  final double amount;
  const PaymentMethodePage({Key? key, required this.amount}) : super(key: key);

  @override
  _PaymentMethodePageState createState() => _PaymentMethodePageState();
}

class _PaymentMethodePageState extends State<PaymentMethodePage> {
  @override
  void initState() {
    getMarchant();
    super.initState();
  }

  int merchantId = 0;
  int terminalId = 0;
  String currency = "";

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
          "Selectionner le mode de paiement".toUpperCase(),
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
            SizedBox(
              height: 15,
            ),
            Text(
              "Par Carte",
              style: TextStyle(
                fontSize: 24,
                fontFamily: 'Inter',
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Center(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: (MediaQuery.of(context).size.width - 25 * 3) / 4,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => InsertTopayPage(
                                  amount: widget.amount,
                                  currency: currency,
                                ),
                              ),
                            );
                            //   Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => ScannerReader(
                            //       amount: widget.amount,
                            //       currency: currency,
                            //     ),
                            //   ),
                            // );
                          },
                          child: Container(
                            padding: const EdgeInsets.only(
                                right: 0, left: 0, top: 10, bottom: 5),
                            width: 100,
                            child: Image.asset(
                              "assets/images/cart_method.png",
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        Text('TapToPay',
                            style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Inter',
                                color: textColor,
                                fontWeight: FontWeight.w600))
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LinkTopayPage(
                                  amount: widget.amount,
                                  terminalId: terminalId,
                                  merchantId: merchantId,
                                  currency: currency,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.only(
                                right: 0, left: 0, top: 10, bottom: 5),
                            width: 100,
                            child: Image.asset(
                              "assets/images/scan_me.png",
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        Text('ScanneToPay',
                            style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Inter',
                                color: textColor,
                                fontWeight: FontWeight.w600))
                      ],
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 35,
            ),
            Text(
              "Par Mobile Money",
              style: TextStyle(
                fontSize: 24,
                fontFamily: 'Inter',
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Center(
                child: Wrap(
                  spacing: 0,
                  runSpacing: 0,
                  children: gatewayList.map((gateway) {
                    return SizedBox(
                      width: (MediaQuery.of(context).size.width - 25 * 3) / 2,
                      child: InkWell(
                          onTap: () {
                            if (gateway.name.toUpperCase() == "ORANGE") {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => OmPaymentPage(
                                          amount: widget.amount,
                                          network: "OM",
                                        )),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        MobileMoneyContactPage(
                                            amount: widget.amount,
                                            network:
                                                gateway.name.toUpperCase())),
                              );
                            }
                          },
                          child: PaymentGateway(gatewayModel: gateway)),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void getMarchant() async {
    final secureStorage = SecureStorageService();

    final marchantId = await secureStorage.getMarchandId();
    final terminalIdValue = await secureStorage.getTerminalId();
    final currencyget = await secureStorage.getCurrency();

    setState(() {
      terminalId = int.parse("$terminalIdValue");
      merchantId = int.parse("$marchantId");
      currency = "$currencyget";
    });
  }
}
