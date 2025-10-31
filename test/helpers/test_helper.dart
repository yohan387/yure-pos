import 'package:mocktail/mocktail.dart';
import 'package:todouapp/core/network/api_client.dart';
import 'package:todouapp/core/network/network_info.dart';
import 'package:todouapp/core/utils/secure_storage.dart';
import 'package:todouapp/core/utils/token_validator.dart';
import 'package:todouapp/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:todouapp/features/auth/domain/repositories/auth_repository.dart';
import 'package:todouapp/features/mobile_payments/domain/repositories/mobile_payment_repository.dart';
import 'package:todouapp/features/payments/domain/repositories/stripe_payment_repository.dart';
import 'package:todouapp/features/profil/data/datasources/profil_remote_data_source.dart';
import 'package:todouapp/features/profil/domain/repositories/profil_repository.dart';
import 'package:todouapp/features/transactions/data/datasources/transaction_remote_data_source.dart';
import 'package:todouapp/features/transactions/domain/repositories/transaction_repository.dart';

// Core Mocks
class MockApiClient extends Mock implements ApiClient {}

class MockSecureStorageService extends Mock implements SecureStorageService {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

class MockTokenValidator extends Mock implements TokenValidator {}

// Auth Mocks
class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockAuthRepository extends Mock implements AuthRepository {}

// Transaction Mocks
class MockTransactionRemoteDataSource extends Mock
    implements TransactionRemoteDataSource {}

class MockTransactionRepository extends Mock implements TransactionRepository {}

// Mobile Payment Mocks
class MockMobilePaymentRepository extends Mock
    implements MobilePaymentRepository {}

// Stripe Payment Mocks
class MockStripePaymentRepository extends Mock
    implements StripePaymentRepository {}

// Profil Mocks
class MockProfilRemoteDataSource extends Mock
    implements ProfilRemoteDataSource {}

class MockProfilRepository extends Mock implements ProfilRepository {}
