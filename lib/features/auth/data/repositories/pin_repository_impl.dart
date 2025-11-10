import 'package:dartz/dartz.dart';
import 'package:todouapp/core/errors/failures.dart';
import 'package:todouapp/core/types/future_result.dart';
import 'package:todouapp/core/utils/pin_hasher.dart';
import 'package:todouapp/features/auth/data/datasources/i_pin_local_data_source.dart';
import 'package:todouapp/features/auth/domain/repositories/i_pin_repository.dart';

/// Implémentation du repository PIN
/// Gère la logique de hashage et la communication avec le data source
class PinRepositoryImpl implements IPinRepository {
  final IPinLocalDataSource _localDataSource;

  PinRepositoryImpl(this._localDataSource);

  @override
  FutureResult<void> savePin(String pin) async {
    try {
      final hash = PinHasher.hashPin(pin);
      await _localDataSource.savePinHash(hash);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Erreur lors de la sauvegarde du PIN: ${e.toString()}'));
    }
  }

  @override
  FutureResult<bool> verifyPin(String pin) async {
    try {
      final storedHash = await _localDataSource.getPinHash();
      if (storedHash == null || storedHash.isEmpty) {
        return const Right(false);
      }

      final enteredHash = PinHasher.hashPin(pin);
      return Right(storedHash == enteredHash);
    } catch (e) {
      return Left(CacheFailure(message: 'Erreur lors de la vérification du PIN: ${e.toString()}'));
    }
  }

  @override
  FutureResult<void> deletePin() async {
    try {
      await _localDataSource.deletePinHash();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Erreur lors de la suppression du PIN: ${e.toString()}'));
    }
  }

  @override
  FutureResult<bool> hasPinConfigured() async {
    try {
      final result = await _localDataSource.hasPinConfigured();
      return Right(result);
    } catch (e) {
      return Left(CacheFailure(message: 'Erreur lors de la vérification du PIN: ${e.toString()}'));
    }
  }

  @override
  FutureResult<void> setPinSetupSkipped(bool skipped) async {
    try {
      await _localDataSource.setPinSetupSkipped(skipped);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Erreur lors de la sauvegarde du statut: ${e.toString()}'));
    }
  }

  @override
  FutureResult<bool> hasPinSetupSkipped() async {
    try {
      final result = await _localDataSource.hasPinSetupSkipped();
      return Right(result);
    } catch (e) {
      return Left(CacheFailure(message: 'Erreur lors de la vérification du statut: ${e.toString()}'));
    }
  }
}
