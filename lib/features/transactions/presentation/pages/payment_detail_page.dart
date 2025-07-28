import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

import 'package:share_plus/share_plus.dart';
import 'package:todouapp/core/widgets/button_widget.dart';

import 'package:todouapp/features/profil/presentation/bloc/profil_bloc.dart';
import 'package:todouapp/features/transactions/presentation/bloc/transaction_bloc.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/utils/amout_format.dart';
import '../../data/models/transaction_model.dart';

class PaymentDetailPage extends StatefulWidget {
  final TransactionModel transaction;
  const PaymentDetailPage({Key? key, required this.transaction})
      : super(key: key);

  @override
  _PaymentDetailPageState createState() => _PaymentDetailPageState();
}

class _PaymentDetailPageState extends State<PaymentDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<ProfilBloc>().add(LoadProfilEvent());
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy - HH:mm:ss');
    final isSucces = widget.transaction.status == 'succeeded';
    final isPending = widget.transaction.status.toLowerCase() == 'pending';

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: Column(
              children: [
                Center(
                  child:
                      widget.transaction.paymentMethod.toUpperCase() == 'CARD'
                          ? Image.asset(
                              height: 80,
                              widget.transaction.network.toUpperCase() ==
                                      "MASTERCARD"
                                  ? "assets/images/mastercard.png"
                                  : widget.transaction.network.toUpperCase() ==
                                          "VISA"
                                      ? "assets/images/visa.png"
                                      : "assets/images/visa.png",
                              fit: BoxFit.contain,
                            )
                          : Image.asset(
                              height: 80,
                              widget.transaction.network == "OM"
                                  ? "assets/images/orange.png"
                                  : widget.transaction.network == "MTN"
                                      ? "assets/images/momo.png"
                                      : widget.transaction.network == "MOOV"
                                          ? "assets/images/moov.png"
                                          : widget.transaction.network == "WAVE"
                                              ? "assets/images/wave.png"
                                              : "assets/images/wallet.png",
                              fit: BoxFit.contain,
                            ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${isSucces ? '+' : '-'}${AmountFormatter.format(widget.transaction.amount)} ${widget.transaction.currency}',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w800,
                    fontSize: 25,
                  ),
                ),
                const SizedBox(height: 8),
                if (widget.transaction.customerPhone.isNotEmpty)
                  Text(
                    widget.transaction.customerPhone,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
              ],
            ),
          ),
          Lottie.asset(
            isSucces
                ? 'assets/images/error.json'
                : isPending
                    ? 'assets/images/pending.json'
                    : 'assets/images/success.json',
            fit: BoxFit.fill,
            height: 100,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Container(
              width: 375,
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Statut",
                          style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        ),
                        const Spacer(),
                        SizedBox(
                          child: FittedBox(
                            fit: BoxFit.fill,
                            child: Text(
                              widget.transaction.status.toUpperCase(),
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 15,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w200,
                                color: isSucces
                                    ? Colors.green.shade900
                                    : isPending
                                        ? Colors.orange.shade900
                                        : Colors.red,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Frais",
                          style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        ),
                        const Spacer(),
                        SizedBox(
                          child: FittedBox(
                            fit: BoxFit.fill,
                            child: Text(
                              'O ${widget.transaction.currency} ',
                              style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w200,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Date",
                          style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        ),
                        const Spacer(),
                        SizedBox(
                          child: FittedBox(
                            fit: BoxFit.fill,
                            child: Text(
                              dateFormat.format(widget.transaction.date),
                              style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w200,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Montant",
                          style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        ),
                        const Spacer(),
                        SizedBox(
                          child: FittedBox(
                            fit: BoxFit.fill,
                            child: Text(
                              '${isSucces ? '+' : '-'}${AmountFormatter.format(widget.transaction.amount)}',
                              style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w200,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                        // SizedBox(
                        //   child: FittedBox(
                        //     fit: BoxFit.fill,
                        //     child: Text(
                        //       context.select<TransactionBloc, String>((bloc) =>
                        //           '${AmountFormatter.format(bloc.state.balance?.amount ?? 0)} ${bloc.state.balance?.currency ?? 'XOF'}'),
                        //       style: TextStyle(
                        //           fontFamily: 'Inter',
                        //           fontSize: 16,
                        //           fontWeight: FontWeight.w200,
                        //           color: Colors.white),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Référence",
                          style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        ),
                        const Spacer(),
                        Expanded(
                          child: Text(
                            widget.transaction.transactionRef ?? 'N/A',
                            style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 15,
                                fontWeight: FontWeight.w200,
                                color: Colors.white),
                            textAlign: TextAlign.right,
                            softWrap: true,
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (widget.transaction.id == 0)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 45),
              child: CancelButton(
                text: 'Retour à l\'accueil',
              ),
            )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // _shareRecuAsImage(widget.transaction.transactionRef);
          final shareText = '''
          Transaction ${widget.transaction.status.toUpperCase()}
          Méthode de paiement: ${widget.transaction.paymentMethod.toUpperCase()}
          Réseau: ${widget.transaction.network.toUpperCase()}
          Montant: ${AmountFormatter.format(widget.transaction.amount)} ${widget.transaction.currency}
          Date: ${DateFormat('MMM dd, yyyy - HH:mm:ss').format(widget.transaction.date)}
          Référence: ${widget.transaction.transactionRef ?? 'N/A'}
          ''';
          // ignore: use_build_context_synchronously
          await Share.share(shareText, subject: 'Détail de la transaction');
        },
        backgroundColor: primaryColor,
        child: Icon(Icons.share, color: Colors.white),
      ),
    );
  }

  bool isCapturing = false;

  // final ScreenshotController screenshotController = ScreenshotController();

  // Future<void> _shareRecuAsImage(transactionId) async {
  //   log('Capture de l\'écran en cours...');
  //   // await Permission.storage.request();
  //   setState(() => isCapturing = true);
  //   final Uint8List? image = await screenshotController.capture();

  //   if (image != null) {
  //     final directory = await getTemporaryDirectory();
  //     final imagePath =
  //         await File('${directory.path}/recu_$transactionId.png').create();
  //     await imagePath.writeAsBytes(image);

  //     await Share.shareXFiles(
  //       [XFile(imagePath.path)],
  //       text: 'Voici votre reçu',
  //     );
  //   }
  //   setState(() => isCapturing = false);
  // }
}
