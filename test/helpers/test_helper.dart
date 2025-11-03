import 'package:mocktail/mocktail.dart';
import 'package:todouapp/core/network/api_client.dart';
import 'package:todouapp/core/network/i_network_info.dart';
import 'package:todouapp/core/utils/secure_storage.dart';
import 'package:todouapp/core/utils/token_validator.dart';
import 'package:todouapp/features/auth/data/datasources/i_auth_data_source.dart';
import 'package:todouapp/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:todouapp/features/mobile_payments/data/datasources/i_mobile_payment_data_source.dart';
import 'package:todouapp/features/mobile_payments/domain/repositories/i_mobile_payment_repository.dart';
import 'package:todouapp/features/payments/data/datasources/i_stripe_payment_data_source.dart';
import 'package:todouapp/features/payments/domain/repositories/i_stripe_payment_repository.dart';
import 'package:todouapp/features/profil/data/datasources/i_profil_data_source.dart';
import 'package:todouapp/features/profil/domain/repositories/i_profil_repository.dart';
import 'package:todouapp/features/transactions/data/datasources/i_transaction_data_source.dart';
import 'package:todouapp/features/transactions/domain/repositories/i_transaction_repository.dart';

// Core Mocks
class MockApiClient extends Mock implements ApiClient {}

class MockSecureStorageService extends Mock implements SecureStorageService {}

class MockNetworkInfo extends Mock implements INetworkInfo {}

class MockTokenValidator extends Mock implements TokenValidator {}

// Auth Mocks
class MockAuthDataSource extends Mock implements IAuthDataSource {}

class MockAuthRepository extends Mock implements IAuthRepository {}

// Transaction Mocks
class MockTransactionDataSource extends Mock implements ITransactionDataSource {}

class MockTransactionRepository extends Mock implements ITransactionRepository {}

// Mobile Payment Mocks
class MockMobilePaymentDataSource extends Mock implements IMobilePaymentDataSource {}

class MockMobilePaymentRepository extends Mock implements IMobilePaymentRepository {}

// Stripe Payment Mocks
class MockStripePaymentDataSource extends Mock implements IStripePaymentDataSource {}

class MockStripePaymentRepository extends Mock implements IStripePaymentRepository {}

// Profil Mocks
class MockProfilDataSource extends Mock implements IProfilDataSource {}

class MockProfilRepository extends Mock implements IProfilRepository {}
