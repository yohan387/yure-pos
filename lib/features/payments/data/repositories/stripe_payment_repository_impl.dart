import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:todouapp/core/constants/api_constants.dart';
import 'package:todouapp/core/errors/failures.dart';
import 'package:todouapp/core/network/api_client.dart';
import 'package:todouapp/core/network/network_info.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/secure_storage.dart';
import '../../domain/repositories/stripe_payment_repository.dart';
import '../models/stripe_payment_intent_response.dart';

class StripePaymentRepositoryImpl implements StripePaymentRepository {
  final ApiClient apiClient;
  final NetworkInfo networkInfo;

  StripePaymentRepositoryImpl({
    required this.apiClient,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, StripePaymentIntentResponse>> createPaymentIntent(
      double amount) async {
    // 1. Vérifier la connexion internet
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      /* VISA */
      // 4242 4242 4242
      // 12/34
      // 567

      /* Mastercard */
      // 5555 5555 5555 4444
      // 3 chiffres aléatoires
      // Toute date postérieure à la date du jour

      final secureStorage = SecureStorageService();
      final marchantId = await secureStorage.getMarchandId();
      final terminalId = await secureStorage.getTerminalId();
      // 2. Appeler l'API Todou pour créer l'intention de paiement
      final response = await apiClient.post(ApiConstants.stripePaymentIntent,
          body: {
            'amount': amount,
            'currency': 'XOF',
            "terminal_id": int.parse('$terminalId'),
            "merchant_id": int.parse('$marchantId'),
            'metadata': {
              'app_name': 'TodouApp',
              'platform': 'flutter',
            },
          },
          requiresAuth: true);

      log('Stripe $response');
      // 3. Convertir la réponse en modèle
      return Right(StripePaymentIntentResponse.fromJson(response));
    } on ServerException catch (e) {
      // 4. Gérer les erreurs serveur
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      log('error stripe $e');
      // 5. Gérer les autres erreurs
      return Left(ServerFailure(message: 'Une erreur inattendue est survenue'));
    }
  }
}
