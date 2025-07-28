import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:todouapp/core/constants/route_constants.dart';
import 'package:todouapp/core/network/api_client.dart';
import 'package:todouapp/core/network/network_info.dart';
import 'package:todouapp/core/utils/event_bus.dart';
import 'package:todouapp/core/utils/navigation.dart';
import 'package:todouapp/core/utils/route_observer.dart';
import 'package:todouapp/core/utils/secure_storage.dart';
import 'package:todouapp/core/utils/token_validator.dart';
import 'package:todouapp/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:todouapp/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:todouapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:todouapp/features/auth/presentation/pages/login_page.dart';
import 'package:todouapp/features/auth/presentation/pages/otp_page.dart';
import 'package:todouapp/features/home/accueil_page.dart';
import 'package:todouapp/features/mobile_payments/domain/usecases/stripe_verify_payment.dart';
import 'package:todouapp/features/profil/data/datasources/profil_remote_data_source.dart';
import 'package:todouapp/features/profil/data/repositories/profil_repository_impl.dart';
import 'package:todouapp/features/profil/domain/usecases/get_profil.dart';
import 'package:todouapp/features/profil/presentation/bloc/profil_bloc.dart';
import 'package:todouapp/features/transactions/data/datasources/transaction_remote_data_source.dart';
import 'package:todouapp/features/transactions/data/models/transaction_model.dart';
import 'package:todouapp/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:todouapp/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:todouapp/onbording_page.dart';

import 'features/auth/domain/usecases/verify_code.dart';
import 'features/auth/domain/usecases/verify_otp.dart';
import 'features/mobile_payments/data/repositories/mobile_payment_repository_impl.dart';
import 'features/mobile_payments/domain/usecases/init_payment.dart';
import 'features/mobile_payments/domain/usecases/verify_payment.dart';
import 'features/mobile_payments/presentation/bloc/mobile_payment_bloc.dart';
import 'features/nfc/scanner_reader.dart';
import 'features/payments/data/repositories/stripe_payment_repository_impl.dart';
import 'features/payments/domain/usescases/init_link_payment.dart';
import 'features/payments/presentation/bloc/stripe_payment_bloc.dart';
import 'features/payments/presentation/pages/stripe_payment_page.dart';
import 'features/profil/presentation/pages/profil_page.dart';
import 'features/transactions/domain/usecases/get_balance.dart';
import 'features/transactions/domain/usecases/get_cancel_payment.dart';
import 'features/transactions/domain/usecases/get_transactions.dart';
import 'features/transactions/presentation/pages/home_page.dart';
import 'features/transactions/presentation/pages/payment_detail_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  log('Step 1 - before runApp');
  await dotenv.load(fileName: ".env");

  final secureStorage = SecureStorageService();
  String? token;

  try {
    token = await secureStorage.getToken();
  } catch (e) {
    log(' Erreur de lecture du token : $e');
    // Si déchiffrement échoue, on nettoie le stockage
    await secureStorage.deleteToken();
  }
  final isAuthenticated = TokenValidator.isTokenValid(token);

  // Écouter les événements d'expiration
  eventBus.on<TokenExpiredEvent>().listen((_) async {
    await secureStorage.deleteToken();
    if (navigatorKey.currentState?.mounted ?? false) {
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        RouteConstants.login,
        (route) => false,
      );
    }
  });

  // Configurez Stripe
  Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
  // Stripe.merchantIdentifier = 'merchant.flutter.stripe.example';
  await Stripe.instance.applySettings();

  runApp(
    TodouApp(
      isAuthenticated: isAuthenticated,
      secureStorage: secureStorage,
    ),
  );
}

class TodouApp extends StatelessWidget {
  final bool isAuthenticated;
  final SecureStorageService secureStorage;
  const TodouApp({
    Key? key,
    required this.isAuthenticated,
    required this.secureStorage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final connectivity = Connectivity();
    final httpClient = http.Client();
    final apiClient = ApiClient(
      client: httpClient,
      secureStorage: secureStorage,
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            verifyCode: VerifyCode(
              AuthRepositoryImpl(
                remoteDataSource: AuthRemoteDataSourceImpl(
                  apiClient: apiClient,
                ),
                networkInfo: NetworkInfoImpl(connectivity),
                apiClient: apiClient,
              ),
            ),
            verifyOtp: VerifyOtp(
              AuthRepositoryImpl(
                remoteDataSource: AuthRemoteDataSourceImpl(
                  apiClient: apiClient,
                ),
                networkInfo: NetworkInfoImpl(connectivity),
                apiClient: apiClient,
              ),
            ),
            secureStorage: secureStorage,
          )..add(CheckAuthStatusEvent()),
        ),
        BlocProvider<TransactionBloc>(
          create: (context) => TransactionBloc(
            getBalance: GetBalance(
              TransactionRepositoryImpl(
                remoteDataSource: TransactionRemoteDataSourceImpl(
                  apiClient: apiClient,
                ),
                networkInfo: NetworkInfoImpl(connectivity),
              ),
            ),
            getTransactions: GetTransactions(
              TransactionRepositoryImpl(
                remoteDataSource: TransactionRemoteDataSourceImpl(
                  apiClient: apiClient,
                ),
                networkInfo: NetworkInfoImpl(connectivity),
              ),
            ),
            getCancelPayment: GetCancelPayment(
              TransactionRepositoryImpl(
                remoteDataSource: TransactionRemoteDataSourceImpl(
                  apiClient: apiClient,
                ),
                networkInfo: NetworkInfoImpl(connectivity),
              ),
            ),
          ),
        ),
        BlocProvider<StripePaymentBloc>(
          create: (context) => StripePaymentBloc(
            repository: StripePaymentRepositoryImpl(
              apiClient: apiClient,
              networkInfo: NetworkInfoImpl(connectivity),
            ),
            secureStorage: secureStorage,
            initLinkPayment: InitLinkPayment(
              StripePaymentRepositoryImpl(
                apiClient: apiClient,
                networkInfo: NetworkInfoImpl(connectivity),
              ),
            ),
          ),
        ),
        BlocProvider<MobilePaymentBloc>(
          create: (context) => MobilePaymentBloc(
            initPayment: InitPayment(
              PaymentRepositoryImpl(
                apiClient: apiClient,
                networkInfo: NetworkInfoImpl(connectivity),
              ),
            ),
            verifyPayment: VerifyPayment(
              PaymentRepositoryImpl(
                apiClient: apiClient,
                networkInfo: NetworkInfoImpl(connectivity),
              ),
            ),
            stripeVerifyPayment: StripeVerifyPayment(
              PaymentRepositoryImpl(
                apiClient: apiClient,
                networkInfo: NetworkInfoImpl(connectivity),
              ),
            ),
          ),
        ),
        BlocProvider<ProfilBloc>(
          create: (context) => ProfilBloc(
            getProfil: GetProfil(
              ProfilRepositoryImpl(
                remoteDataSource: ProfilRemoteDataSourceImpl(
                  apiClient: apiClient,
                ),
                networkInfo: NetworkInfoImpl(connectivity),
              ),
            ),
          ),
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
