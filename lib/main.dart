import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:todouapp/core/constants/route_constants.dart';
import 'package:todouapp/core/network/api_client.dart';
import 'package:todouapp/core/network/network_info.dart';
import 'package:todouapp/core/utils/event_bus.dart';
import 'package:todouapp/core/utils/navigation.dart';
import 'package:todouapp/core/utils/secure_storage.dart';
import 'package:todouapp/core/utils/token_validator.dart';
import 'package:todouapp/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:todouapp/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:todouapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:todouapp/features/auth/presentation/pages/login_page.dart';
import 'package:todouapp/features/auth/presentation/pages/otp_page.dart';
import 'package:todouapp/features/transactions/data/datasources/transaction_remote_data_source.dart';
import 'package:todouapp/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:todouapp/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'core/constants/api_constants.dart';
import 'features/auth/domain/usecases/verify_code.dart';
import 'features/auth/domain/usecases/verify_otp.dart';
import 'features/mobile_payments/data/repositories/mobile_payment_repository_impl.dart';
import 'features/mobile_payments/domain/usecases/init_payment.dart';
import 'features/mobile_payments/domain/usecases/verify_payment.dart';
import 'features/mobile_payments/presentation/bloc/mobile_payment_bloc.dart';
import 'features/payments/data/repositories/stripe_payment_repository_impl.dart';
import 'features/payments/presentation/bloc/stripe_payment_bloc.dart';
import 'features/payments/presentation/pages/stripe_payment_page.dart';
import 'features/transactions/domain/usecases/get_balance.dart';
import 'features/transactions/domain/usecases/get_transactions.dart';
import 'features/transactions/presentation/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final secureStorage = SecureStorageService();
  final token = await secureStorage.getToken();
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
  Stripe.publishableKey = ApiConstants.stripeKey;
  // Stripe.merchantIdentifier = 'merchant.flutter.stripe.example';
  await Stripe.instance.applySettings();

  runApp(
    TodouApp(isAuthenticated: isAuthenticated, secureStorage: secureStorage),
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
          ),
        ),
        BlocProvider<StripePaymentBloc>(
          create: (context) => StripePaymentBloc(
            repository: StripePaymentRepositoryImpl(
              apiClient: apiClient,
              networkInfo: NetworkInfoImpl(connectivity),
            ),
            secureStorage: secureStorage,
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
          ),
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey, // Ajout de la clé de navigation
        title: 'Todou App',

        debugShowCheckedModeBanner: false,
        initialRoute:
            isAuthenticated ? RouteConstants.home : RouteConstants.login,
        routes: {
          RouteConstants.login: (context) => LoginPage(),
          RouteConstants.otp: (context) => OtpPage(),
          RouteConstants.home: (context) => const HomePage(),
          RouteConstants.stripePayment: (context) {
            final amount = ModalRoute.of(context)!.settings.arguments as double;
            return StripePaymentPage(amount: amount);
          },
        },
      ),
    );
  }
}
