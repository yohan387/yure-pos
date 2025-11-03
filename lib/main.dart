import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:todouapp/core/config/app_config.dart';
import 'package:todouapp/core/constants/route_constants.dart';
import 'package:todouapp/core/di/injection.dart';
import 'package:todouapp/core/utils/event_bus.dart';
import 'package:todouapp/core/utils/navigation.dart';
import 'package:todouapp/core/utils/route_observer.dart';
import 'package:todouapp/core/utils/secure_storage.dart';
import 'package:todouapp/core/utils/token_validator.dart';
import 'package:todouapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:todouapp/features/auth/presentation/pages/login_page.dart';
import 'package:todouapp/features/auth/presentation/pages/otp_page.dart';
import 'package:todouapp/features/home/accueil_page.dart';
import 'package:todouapp/features/mobile_payments/presentation/bloc/mobile_payment_bloc.dart';
import 'package:todouapp/features/profil/presentation/bloc/profil_bloc.dart';
import 'package:todouapp/features/transactions/data/models/transaction_model.dart';
import 'package:todouapp/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:todouapp/onbording_page.dart';

import 'features/nfc/scanner_reader.dart';
import 'features/payments/presentation/bloc/stripe_payment_bloc.dart';
import 'features/payments/presentation/pages/stripe_payment_page.dart';
import 'features/profil/presentation/pages/profil_page.dart';
import 'features/transactions/presentation/pages/home_page.dart';
import 'features/transactions/presentation/pages/payment_detail_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ===== 1. Charger l'environnement =====
  log('Step 1 - Loading environment');
  await dotenv.load(fileName: ".env");

  // ===== 2. Initialiser la configuration (Mock/Prod) =====
  AppConfig.initialize();
  log('🚀 App lancée en mode: ${AppConfig.mode.name.toUpperCase()}');

  // ===== 3. Setup des dépendances avec Service Locator =====
  log('Step 2 - Setting up dependencies');
  await setupDependencies();
  log('✅ Dépendances initialisées');

  // ===== 4. Vérifier l'authentification =====
  final secureStorage = sl<SecureStorageService>();
  String? token;

  try {
    token = await secureStorage.getToken();
  } catch (e) {
    log('⚠️ Erreur de lecture du token : $e');
    await secureStorage.deleteToken();
  }

  final isAuthenticated = TokenValidator.isTokenValid(token);
  log('🔐 Authentifié: $isAuthenticated');

  // ===== 5. Écouter les événements d'expiration de token =====
  eventBus.on<TokenExpiredEvent>().listen((_) async {
    log('⚠️ Token expiré - Déconnexion');
    await secureStorage.deleteToken();
    if (navigatorKey.currentState?.mounted ?? false) {
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        RouteConstants.login,
        (route) => false,
      );
    }
  });

  // ===== 6. Configurer Stripe (uniquement en mode prod) =====
  if (AppConfig.isProdMode) {
    Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
    await Stripe.instance.applySettings();
    log('💳 Stripe configuré');
  } else {
    log('💳 Stripe désactivé (mode mock)');
  }

  // ===== 7. Lancer l'application =====
  log('Step 3 - Running app');
  runApp(TodouApp(isAuthenticated: isAuthenticated));
}

class TodouApp extends StatelessWidget {
  final bool isAuthenticated;

  const TodouApp({
    Key? key,
    required this.isAuthenticated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>()..add(CheckAuthStatusEvent()),
        ),
        BlocProvider<TransactionBloc>(
          create: (_) => sl<TransactionBloc>(),
        ),
        BlocProvider<StripePaymentBloc>(
          create: (_) => sl<StripePaymentBloc>(),
        ),
        BlocProvider<MobilePaymentBloc>(
          create: (_) => sl<MobilePaymentBloc>(),
        ),
        BlocProvider<ProfilBloc>(
          create: (_) => sl<ProfilBloc>(),
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        navigatorObservers: [routeObserver],
        title: 'Todou App',
        debugShowCheckedModeBanner: false,
        initialRoute:
            isAuthenticated ? RouteConstants.accueil : RouteConstants.onbording,
        routes: {
          RouteConstants.onbording: (context) => OnbordingPage(),
          RouteConstants.login: (context) => LoginPage(),
          RouteConstants.otp: (context) => OtpPage(),
          RouteConstants.accueil: (context) => AccueilPage(),
          RouteConstants.home: (context) => const HomePage(),
          RouteConstants.stripePayment: (context) {
            final amount = ModalRoute.of(context)!.settings.arguments as double;
            return StripePaymentPage(amount: amount);
          },
          RouteConstants.topTopay: (context) => ScannerReader(
                amount: ModalRoute.of(context)!.settings.arguments as double? ??
                    0.0,
                currency: '',
              ),
          RouteConstants.profil: (context) => const ProfilPage(),
          RouteConstants.paymentDetail: (context) => PaymentDetailPage(
                transaction: ModalRoute.of(context)!.settings.arguments
                    as TransactionModel,
              ),
        },
      ),
    );
  }
}
