import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:mek_stripe_terminal/mek_stripe_terminal.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rive/rive.dart';

import '../../core/constants/colors.dart';
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
  String scanStatus = "Charger un terminal que vous voulez \n connecter ";
  Terminal? _terminal;
  Location? _selectedLocation;
  List<Reader> _readers = [];
  Reader? _reader;
  bool isTerminalInitialize = false;

  static const bool _isSimulated = true; //if testing >> true otherwise false

  //Tap & Pay
  StreamSubscription? _onConnectionStatusChangeSub;

  var _connectionStatus = ConnectionStatus.notConnected;

  StreamSubscription? _onPaymentStatusChangeSub;

  PaymentStatus _paymentStatus = PaymentStatus.notReady;

  StreamSubscription? _onUnexpectedReaderDisconnectSub;

  StreamSubscription? _discoverReaderSub;

  // void _startDiscoverReaders(Terminal terminal) {
  //   try {
  //     isScanning = true;
  //     _readers = [];
  //     final discoverReaderStream =
  //         terminal.discoverReaders(const LocalMobileDiscoveryConfiguration(
  //       isSimulated: _isSimulated,
  //     ));
  //     setState(() {
  //       _discoverReaderSub = discoverReaderStream.listen((readers) {
  //         scanStatus = "Choisissez un terminal à connecter";
  //         log("Discovered Readers: ${_readers}");

  //         setState(() => _readers = readers);
  //       }, onDone: () {
  //         setState(() {
  //           _discoverReaderSub = null;
  //           _readers = const [];
  //         });
  //       });
  //     });
  //     log("Discovered Readers: ${_readers}");
  //   } catch (e) {
  //     log("Error discovering readers: $e");
  //   }
  // }

  void _startDiscoverReaders(Terminal terminal) {
    try {
      isScanning = true;
      _readers = [];

      final discoverReaderStream = terminal.discoverReaders(
        const LocalMobileDiscoveryConfiguration(
          isSimulated: _isSimulated,
        ),
      );

      _discoverReaderSub = discoverReaderStream.listen(
        (readers) {
          scanStatus = "Choisissez un terminal à connecter";
          log("Discovered Readers: $readers");
          if (!mounted) return;
          setState(() => _readers = readers);
        },
        onError: (error) {
          log("Erreur lors de la découverte des terminaux: $error");
          if (!mounted) return;
          setState(() {
            isScanning = false;
            scanStatus =
                "Oup's, verifiez que votre\n téléphone supporte pas Tap to Pay.";
            _readers = const [];
          });

          showSnackBar(
              "Oup's, verifiez que votre téléphone \n supporte pas Tap to Pay.");
        },
        onDone: () {
          setState(() {
            _discoverReaderSub = null;
            _readers = const [];
            isScanning = false;
          });
        },
      );
    } catch (e) {
      log("Erreur dans _startDiscoverReaders (bloc try): $e");
      showSnackBar("Erreur inconnue lors de la détection.");
    }
  }

  void _stopDiscoverReaders() {
    unawaited(_discoverReaderSub?.cancel());
    if (!mounted) return;
    setState(() {
      _discoverReaderSub = null;
      isScanning = false;
      scanStatus = "Charger un terminal que vous voulez \n connecter ";
      _readers = const [];
    });
  }

  Future<void> _disconnectReader() async {
    try {
      await _terminal?.disconnectReader();
      if (!mounted) return;
      setState(() {
        _reader == null;
      });
      showSnackBar("Déconnecté du terminal");
    } catch (e) {
      log("Erreur de déconnexion : $e");
    }
  }

  Future<void> _connectReader(Terminal terminal, Reader reader) async {
    await _tryConnectReader(terminal, reader).then((value) {
      final connectedReader = value;
      if (connectedReader == null) {
        throw Exception("Error connecting to reader ! Please try again");
      }
      _reader = connectedReader;
    });
  }

  Future<Reader?> _tryConnectReader(Terminal terminal, Reader reader) async {
    String? getLocationId() {
      final locationId = _selectedLocation?.id ?? reader.locationId;
      if (locationId == null) throw AssertionError('Missing location');

      return locationId;
    }

    final locationId = getLocationId();

    return await terminal.connectMobileReader(
      reader,
      locationId: locationId!,
    );
  }

  Future<void> _fetchLocations() async {
    final locations = await _terminal!.listLocations();
    if (locations.isEmpty) {
      throw AssertionError(
        'Aucune location Stripe trouvée.\n Va sur ton dashboard Stripe et crée une "location" dans la section Terminal.',
      );
    }
    _selectedLocation = locations.first;

    print(_selectedLocation);
    if (_selectedLocation == null) {
      throw AssertionError(
          'Please create location on stripe dashboard to proceed further!');
    }
  }

  Future<void> requestPermissions() async {
    final permissions = [
      Permission.locationWhenInUse,
      Permission.bluetooth,
      if (Platform.isAndroid) ...[
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
      ],
    ];

    for (final permission in permissions) {
      final result = await permission.request();
      if (result == PermissionStatus.denied ||
          result == PermissionStatus.permanentlyDenied) return;
    }
  }

  Future<void> _initTerminal() async {
    await requestPermissions();
    await initTerminal();
    await _fetchLocations();
  }

  Future<String> getConnectionToken() async {
    http.Response response = await http.post(
      Uri.parse("https://api.stripe.com/v1/terminal/connection_tokens"),
      headers: {
        'Authorization': 'Bearer ${dotenv.env['STRIPE_SECRET_KEY']}',
        'Content-Type': 'application/x-www-form-urlencoded'
      },
    );
    Map jsonResponse = json.decode(response.body);
    print(jsonResponse);
    if (jsonResponse['secret'] != null) {
      return jsonResponse['secret'];
    } else {
      return "";
    }
  }

  // Future<void> initTerminal() async {
  //   if (_terminal != null) {
  //     return;
  //   }

  //   final connectionToken = await getConnectionToken();
  //   final terminal = await Terminal.getInstance(
  //     shouldPrintLogs: false,
  //     fetchToken: () async {
  //       return connectionToken;
  //     },
  //   );
  //   _terminal = terminal;
  //   // showSnackBar("Initialized Stripe Terminal");
  //   setState(() {
  //     isTerminalInitialize = true;
  //   });

  //   _onConnectionStatusChangeSub =
  //       terminal.onConnectionStatusChange.listen((status) {
  //     print('Connection Status Changed: ${status.name}');
  //     _connectionStatus = status;
  //     scanStatus = _connectionStatus.name;
  //   });
  //   _onUnexpectedReaderDisconnectSub =
  //       terminal.onUnexpectedReaderDisconnect.listen((reader) {
  //     print('Reader Unexpected Disconnected: ${reader.label}');
  //   });
  //   _onPaymentStatusChangeSub = terminal.onPaymentStatusChange.listen((status) {
  //     print('Payment Status Changed: ${status.name}');
  //     _paymentStatus = status;
  //   });
  //   if (_terminal == null) {
  //     print('Please try again later!');
  //   }
  // }

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

    // Listeners
    _onConnectionStatusChangeSub =
        _terminal!.onConnectionStatusChange.listen((status) {
      _connectionStatus = status;
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

    setState(() {
      isTerminalInitialize = true;
    });

    // Récupération des locations Stripe
    await _fetchLocations();

    // Nouvelle partie : détecter si un lecteur est déjà connecté
    final status = await _terminal!.getConnectionStatus();
    if (status == ConnectionStatus.connected) {
      try {
        final connectedReader = await _terminal!.getConnectedReader();
        setState(() {
          _reader = connectedReader;
          scanStatus = "";
        });
        log("Lecteur déjà connecté détecté : ${connectedReader?.serialNumber}");
      } catch (e) {
        log("Erreur lors de la récupération du lecteur connecté : $e");
      }
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message),
      ));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      isTerminalInitialize = true;
    });

    _initTerminal();
  }

  @override
  void dispose() {
    unawaited(_onConnectionStatusChangeSub?.cancel());
    unawaited(_discoverReaderSub?.cancel());
    unawaited(_onUnexpectedReaderDisconnectSub?.cancel());
    unawaited(_onPaymentStatusChangeSub?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Connecter un terminal".toUpperCase(),
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Inter',
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
      ),
      body: _isPaymentSuccessful
          ? RiveAnimation.asset(
              'assets/animations/success.riv',
            )
          : Column(
              mainAxisAlignment: _readers.isNotEmpty
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              children: [
                if (!isTerminalInitialize)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Veuillez patienter pendant que le terminal est initialisé",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            color: Colors.black),
                      ),
                      const SizedBox(height: 20),
                      SpinKitThreeBounce(color: Colors.red)
                    ],
                  ),
                if (isTerminalInitialize)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        scanStatus,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                // if (_readers.isNotEmpty)
                //   ..._readers.map((reader) => TextButton(
                //         onPressed: () async {
                //           await _connectReader(_terminal!, reader).then((v) {
                //             // Navigator.push(
                //             //   context,
                //             //   MaterialPageRoute(
                //             //       builder: (context) => StripeTaptopayPage(
                //             //             terminal: _terminal!,
                //             //           )),
                //             // );
                //             _collectPayment(_terminal!);
                //           }).catchError((error) {
                //             showSnackBar(
                //                 'Erreur de connexion au lecteur: $error');
                //             log('Error connecting to reader: $error');
                //           });
                //         },
                //         child: ListTile(
                //           title: Text(
                //             reader.location!.displayName ?? 'Lecteur inconnu',
                //             style: const TextStyle(
                //                 fontFamily: 'Inter', fontSize: 16),
                //           ),
                //           subtitle: Text(
                //             reader.serialNumber ?? 'Numéro de série inconnu',
                //             style: const TextStyle(
                //                 fontFamily: 'Inter', fontSize: 14),
                //           ),
                //         ),
                //       )),
                if (_reader != null) // Terminal déjà connecté
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 12),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        onTap: () async {
                          if (_terminal != null) {
                            _collectPayment(_terminal!);
                          } else {
                            showSnackBar("Terminal non initialisé");
                          }
                        },
                        leading: Icon(Icons.bluetooth_connected,
                            color: Colors.green, size: 32),
                        title: Text(
                          _reader!.label ?? "Lecteur connecté",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_reader!.serialNumber != null)
                              Text(
                                "SN: ${_reader!.serialNumber}",
                                style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w700),
                              ),
                            if (_reader!.location != null)
                              Text(
                                "Emplacement: ${_reader!.location!.displayName ?? ''}",
                                style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w700),
                              ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.logout, color: Colors.red),
                          tooltip: "Déconnecter le lecteur",
                          onPressed: () async {
                            await _disconnectReader();
                            if (!mounted) return;
                            setState(() => _reader = null);
                            showSnackBar("Lecteur déconnecté.");
                          },
                        ),
                      ),
                    ),
                  ),

                if (_readers.isNotEmpty)
                  ..._readers.map((reader) => TextButton(
                        onPressed: () async {
                          // Confirmation avant de connecter
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(
                                'Connexion au terminal',
                                style: TextStyle(fontFamily: 'Inter'),
                              ),
                              content: Text(
                                'Voulez-vous connecter ce terminal :\n${reader.serialNumber}?',
                                style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w800),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: Text(
                                    'Annuler',
                                    style: TextStyle(
                                        color: Colors.red, fontFamily: 'Inter'),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text(
                                    'Connecter',
                                    style: TextStyle(
                                        color: Colors.green,
                                        fontFamily: 'Inter'),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (confirmed != true) return;

                          await _connectReader(_terminal!, reader).then((v) {
                            _collectPayment(_terminal!);
                          }).catchError((error) {
                            showSnackBar(
                                'Erreur de connexion au lecteur: $error');
                            log('Error connecting to reader: $error');
                          });
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading:
                                Icon(Icons.nfc, color: Colors.blue, size: 30),
                            title: Text(
                              reader.location?.displayName ?? 'Lecteur inconnu',
                              style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              reader.serialNumber ?? 'Numéro de série inconnu',
                              style: const TextStyle(
                                  fontFamily: 'Inter', fontSize: 14),
                            ),
                          ),
                        ),
                      ))
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
                      // Retour à l'écran d'accueil
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        RouteConstants.home,
                        (route) => false,
                      );
                    },
                  ),
                ),
              if (!_isPaymentSuccessful)
                GestureDetector(
                  // onTap: () async {
                  //   if (isScanning && isTerminalInitialize == true) {
                  //     _stopDiscoverReaders();
                  //   } else {
                  //     // Si déjà connecté à un reader, déconnecte d'abord
                  //     final status = await _terminal?.getConnectionStatus();

                  //     if (status == ConnectionStatus.connected) {
                  //       log('deconnexion');
                  //       _disconnectReader();
                  //     }
                  //     _startDiscoverReaders(_terminal!);
                  //   }
                  // },
                  onTap: () async {
                    if (isScanning && isTerminalInitialize == true) {
                      _stopDiscoverReaders();
                    } else {
                      final connectedReader =
                          await _terminal?.getConnectedReader();
                      if (connectedReader != null) {
                        // Reader déjà connecté : demander confirmation
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Déjà connecté'),
                            content: Text(
                              'Vous êtes déjà connecté au lecteur :\n\n'
                              '${connectedReader.label != null ? '"${connectedReader.label}"\n' : ''}Numéro : ${connectedReader.serialNumber}\n\n'
                              'Voulez-vous vous déconnecter pour rechercher un nouveau lecteur ?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Annuler'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Changer de lecteur'),
                              ),
                            ],
                          ),
                        );

                        if (confirm != true) {
                          showSnackBar("Connexion existante conservée.");
                          return;
                        }

                        // Déconnecter si confirmé
                        await _disconnectReader();
                      }

                      _startDiscoverReaders(_terminal!);
                    }
                  },

                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 50.0),
                    child: Container(
                      height: 50.0,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isScanning ? Icons.stop : Icons.scanner,
                              color: isScanning ? Colors.red : Colors.green,
                            ),
                            Text(
                              isScanning
                                  ? 'Arrêter le scan'
                                  : 'Lecteur de terminal',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  bool _isPaymentSuccessful = false;
  PaymentIntent? _paymentIntent;
  Future<bool> _createPaymentIntent(Terminal terminal, double amount) async {
    final secureStorage = SecureStorageService();
    final marchantId = await secureStorage.getMarchandId();
    final terminalId = await secureStorage.getTerminalId();
    final paymentIntent =
        await terminal.createPaymentIntent(PaymentIntentParameters(
      amount: (double.parse(amount.toStringAsFixed(2)) * 100).ceil(),
      currency: "eur",
      captureMethod: CaptureMethod.automatic,
      paymentMethodTypes: [PaymentMethodType.cardPresent],
      metadata: {
        "terminal_id": '$terminalId',
        "merchant_id": '$marchantId',
      },
    ));
    _paymentIntent = paymentIntent;
    if (_paymentIntent == null) {
      showSnackBar('Payment intent is not created!');
    }

    return await _collectPaymentMethod(terminal, _paymentIntent!);
  }

  Future<bool> _collectPaymentMethod(
      Terminal terminal, PaymentIntent paymentIntent) async {
    final collectingPaymentMethod = terminal.collectPaymentMethod(
      paymentIntent,
      skipTipping: true,
    );

    try {
      final paymentIntentWithPaymentMethod = await collectingPaymentMethod;
      _paymentIntent = paymentIntentWithPaymentMethod;
      await _confirmPaymentIntent(terminal, _paymentIntent!).then((value) {});
      return true;
    } on TerminalException catch (exception) {
      switch (exception.code) {
        case TerminalExceptionCode.canceled:
          showSnackBar('Le paiement a été annulé !');
          return false;
        default:
          showSnackBar('Erreur de paiement : ${exception.message}');
          log("TerminalException: ${exception.toString()}");
          return false;
      }
    }
  }

  Future<void> _confirmPaymentIntent(
      Terminal terminal, PaymentIntent paymentIntent) async {
    try {
      showSnackBar('En Traitement...!');

      final processedPaymentIntent =
          await terminal.confirmPaymentIntent(paymentIntent);
      _paymentIntent = processedPaymentIntent;

      Future.delayed(Duration(seconds: 3), () {
        if (!mounted) return;
        setState(() {
          // _isPaymentSuccessful = false;
        });
      });

      setState(() {
        _isPaymentSuccessful = true;
      });
      showSnackBar('Paiement effectué !');
    } catch (e) {
      //showSnackBar('Inside collect payment exception ${e.toString()}');

      log(e.toString());
    }
  }

  void _collectPayment(Terminal terminal) async {
    bool status = await _createPaymentIntent(terminal, widget.amount);
    if (status) {
      showSnackBar('Paiement perçu: ${widget.amount}');
    } else {
      showSnackBar('Paiement annulé');
    }
  }
}
