import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:mek_stripe_terminal/mek_stripe_terminal.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rive/rive.dart';
import '../../core/constants/route_constants.dart';
import '../../core/utils/secure_storage.dart';
import '../../core/widgets/button_widget.dart';

class ScannerReader extends StatefulWidget {
  final double amount;
  const ScannerReader({Key? key, required this.amount}) : super(key: key);
  @override
  _ScannerReaderState createState() => _ScannerReaderState();
}

class _ScannerReaderState extends State<ScannerReader> {
  bool isScanning = false;
  String scanStatus = "Chargement...";
  Terminal? _terminal;
  Location? _selectedLocation;
  List<Reader> _readers = [];
  Reader? _reader;
  bool isTerminalInitialize = false;

  static const bool _isSimulated = true;

  StreamSubscription? _onConnectionStatusChangeSub;
  StreamSubscription? _onPaymentStatusChangeSub;
  StreamSubscription? _onUnexpectedReaderDisconnectSub;
  StreamSubscription? _discoverReaderSub;

  bool _isPaymentSuccessful = false;
  PaymentIntent? _paymentIntent;
  bool _isCollecting = false;
  PaymentStatus _paymentStatus = PaymentStatus.notReady;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    await _initTerminal();

    final connectionStatus = await _terminal!.getConnectionStatus();
    if (connectionStatus == ConnectionStatus.connected) {
      final connectedReader = await _terminal!.getConnectedReader();
      if (!mounted) return;
      setState(() {
        _reader = connectedReader;
        scanStatus = "";
      });
      _collectPayment(_terminal!);
    } else {
      _startDiscoverReaders(_terminal!);
    }
  }

  Future<void> _initTerminal() async {
    await requestPermissions();
    await initTerminal();
    await _fetchLocations();
  }

  Future<void> initTerminal() async {
    if (_terminal != null) return;

    _terminal = await Terminal.getInstance(
      shouldPrintLogs: true,
      fetchToken: () async {
        final token = await getConnectionToken();
        if (token.isEmpty) throw Exception("Token manquant");
        return token;
      },
    );

    _onConnectionStatusChangeSub =
        _terminal!.onConnectionStatusChange.listen((status) {
      if (!mounted) return;
      setState(() => scanStatus = status.name);
    });

    _onUnexpectedReaderDisconnectSub =
        _terminal!.onUnexpectedReaderDisconnect.listen((reader) {
      showSnackBar("Lecteur déconnecté : ${reader.label}");
    });

    _onPaymentStatusChangeSub =
        _terminal!.onPaymentStatusChange.listen((status) {
      _paymentStatus = status;
    });

    if (!mounted) return;
    setState(() => isTerminalInitialize = true);
  }

  // void _startDiscoverReaders(Terminal terminal) {
  //   isScanning = true;
  //   _readers = [];

  //   final location1 = Location(
  //     address: Address(
  //       city: "Lille",
  //       country: "FR",
  //       line1: "10 Rue Faidherbe",
  //       line2: "",
  //       postalCode: "59000",
  //       state: "Hauts-de-France",
  //     ),
  //     displayName: "Zone Nord - Lille",
  //     id: "loc_1",
  //     livemode: false, // false pour mode test
  //     metadata: {},
  //   );

  //   final location2 = Location(
  //     id: "loc_2",
  //     address: Address(
  //       city: "Lille",
  //       country: "FR",
  //       line1: "10 Rue Faidherbe",
  //       line2: "",
  //       postalCode: "59000",
  //       state: "Hauts-de-France",
  //     ),
  //     displayName: "Zone Sud - Lille",
  //     livemode: false, // false pour mode test
  //     metadata: {},
  //   );
  //   // MOCK de plusieurs lecteurs
  //   setState(() {
  //     scanStatus = "Simulateurs connectés";
  //     _readers = [
  //       Reader(
  //         locationStatus: LocationStatus.set,
  //         batteryLevel: 100.0,
  //         deviceType: DeviceType.chipper1X,
  //         simulated: true,
  //         availableUpdate: false,
  //         serialNumber: "SIMULATED_READER_001",
  //         locationId: location1.id,
  //         location: location1,
  //         label: "Simulateur 1",
  //       ),
  //       Reader(
  //         locationStatus: LocationStatus.set,
  //         batteryLevel: 90.0,
  //         deviceType: DeviceType.chipper2X,
  //         simulated: true,
  //         availableUpdate: false,
  //         serialNumber: "SIMULATED_READER_002",
  //         locationId: location2.id,
  //         location: location2,
  //         label: "Simulateur 2",
  //       ),
  //     ];
  //     isScanning = false;
  //   });
  // }

  void _startDiscoverReaders(Terminal terminal) async {
    try {
      isScanning = true;
      _readers = [];

      final discoverReaderStream = terminal.discoverReaders(
        const LocalMobileDiscoveryConfiguration(isSimulated: _isSimulated),
      );

      _discoverReaderSub = discoverReaderStream.listen(
        (readers) async {
          if (!mounted) return;

          if (readers.length == 1) {
            final reader = readers.first;
            await _connectReader(terminal, reader);
            _collectPayment(terminal);
          } else if (readers.isNotEmpty) {
            setState(() {
              _readers = readers;
              scanStatus = "Choisissez un terminal à connecter";
            });
          }
        },
        onError: (error) {
          if (!mounted) return;
          setState(() {
            isScanning = false;
            scanStatus = "Erreur: téléphone non compatible Tap to Pay.";
            _readers = const [];
          });
          showSnackBar("Erreur de détection du terminal.");
        },
        onDone: () {
          if (!mounted) return;
          setState(() {
            _discoverReaderSub = null;
            isScanning = false;
          });
        },
      );
    } catch (e) {
      showSnackBar("Erreur inattendue lors du scan.");
    }
  }

  Future<void> _fetchLocations() async {
    final locations = await _terminal!.listLocations();
    if (locations.isEmpty) {
      throw AssertionError("Aucune location Stripe trouvée.");
    }
    _selectedLocation = locations.first;
  }

  Future<void> requestPermissions() async {
    final permissions = [
      Permission.locationWhenInUse,
      Permission.bluetooth,
      if (Platform.isAndroid) ...[
        Permission.bluetoothScan,
        Permission.bluetoothConnect
      ],
    ];

    for (final p in permissions) {
      final result = await p.request();
      if (result.isDenied || result.isPermanentlyDenied) return;
    }
  }

  Future<String> getConnectionToken() async {
    http.Response response = await http.post(
      Uri.parse("https://api.stripe.com/v1/terminal/connection_tokens"),
      headers: {
        'Authorization': 'Bearer ${dotenv.env['STRIPE_SECRET_KEY']}',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    Map jsonResponse = json.decode(response.body);
    return jsonResponse['secret'] ?? "";
  }

  Future<void> _connectReader(Terminal terminal, Reader reader) async {
    final locationId = _selectedLocation?.id ?? reader.locationId;
    final connectedReader =
        await terminal.connectMobileReader(reader, locationId: locationId!);
    if (!mounted) return;
    setState(() => _reader = connectedReader);
  }

  Future<void> _disconnectReader() async {
    try {
      await _terminal?.disconnectReader();
      if (!mounted) return;
      setState(() => _reader = null);
      showSnackBar("Lecteur déconnecté.");
    } catch (e) {
      log("Erreur de déconnexion : $e");
    }
  }

  void _collectPayment(Terminal terminal) async {
    if (_isCollecting) return;
    _isCollecting = true;

    bool status = await _createPaymentIntent(terminal, widget.amount);

    _isCollecting = false;
    if (status) {
      showSnackBar('Paiement de ${widget.amount}€ effectué');
    } else {
      showSnackBar('Paiement annulé');
    }
  }

  Future<bool> _createPaymentIntent(Terminal terminal, double amount) async {
    final secureStorage = SecureStorageService();
    final marchantId = await secureStorage.getMarchandId();
    final terminalId = await secureStorage.getTerminalId();

    final paymentIntent = await terminal.createPaymentIntent(
      PaymentIntentParameters(
        amount: (amount * 100).ceil(),
        currency: "eur",
        captureMethod: CaptureMethod.automatic,
        paymentMethodTypes: [PaymentMethodType.cardPresent],
        metadata: {
          "terminal_id": '$terminalId',
          "merchant_id": '$marchantId',
        },
      ),
    );

    _paymentIntent = paymentIntent;
    return await _collectPaymentMethod(terminal, paymentIntent);
  }

  Future<bool> _collectPaymentMethod(
      Terminal terminal, PaymentIntent paymentIntent) async {
    try {
      final paymentIntentWithMethod =
          await terminal.collectPaymentMethod(paymentIntent, skipTipping: true);
      _paymentIntent = paymentIntentWithMethod;

      await _confirmPaymentIntent(terminal, _paymentIntent!);
      return true;
    } on TerminalException catch (e) {
      showSnackBar(e.message);
      return false;
    }
  }

  Future<void> _confirmPaymentIntent(
      Terminal terminal, PaymentIntent paymentIntent) async {
    final confirmed = await terminal.confirmPaymentIntent(paymentIntent);
    _paymentIntent = confirmed;
    if (!mounted) return;
    setState(() => _isPaymentSuccessful = true);
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _onConnectionStatusChangeSub?.cancel();
    _discoverReaderSub?.cancel();
    _onUnexpectedReaderDisconnectSub?.cancel();
    _onPaymentStatusChangeSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Connecter un terminal".toUpperCase(),
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Inter',
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _isPaymentSuccessful
          ? Center(
              child: RiveAnimation.asset(
              'assets/animations/success.riv',
            ))
          : Column(
              children: [
                const SizedBox(height: 20),
                if (_reader != null)
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Card(
                      child: ListTile(
                        onTap: () => _collectPayment(_terminal!),
                        leading: Icon(Icons.bluetooth_connected,
                            color: Colors.green),
                        title: Text(_reader!.label ?? "Lecteur connecté"),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("SN: ${_reader!.serialNumber}"),
                            Text(
                                "Location: ${_reader!.location?.displayName ?? ''}"),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.logout, color: Colors.red),
                          onPressed: _disconnectReader,
                        ),
                      ),
                    ),
                  ),
                if (_readers.isNotEmpty)
                  ..._readers.map(
                    (reader) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        child: ListTile(
                          leading: Icon(Icons.nfc),
                          title: Text(reader.label ?? "Lecteur inconnu"),
                          subtitle: Text("SN: ${reader.serialNumber}"),
                          onTap: () async {
                            await _connectReader(_terminal!, reader);
                            _collectPayment(_terminal!);
                          },
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    scanStatus,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (!isTerminalInitialize)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isPaymentSuccessful)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 50.0),
                  child: CustomButton(
                    text: 'Retour à l\'accueil',
                    onPressed: () async {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        RouteConstants.home,
                        (route) => false,
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
