import 'package:todouapp/core/utils/secure_storage.dart';
import 'package:todouapp/features/auth/data/datasources/i_pin_local_data_source.dart';

/// Implémentation du data source local pour le PIN
/// Utilise SecureStorageService pour le stockage sécurisé
class PinLocalDataSource implements IPinLocalDataSource {
  final SecureStorageService _secureStorage;

  PinLocalDataSource(this._secureStorage);

  @override
  Future<void> savePinHash(String pinHash) async {
    await _secureStorage.savePinHash(pinHash);
  }

  @override
  Future<String?> getPinHash() async {
    return await _secureStorage.getPinHash();
  }

  @override
  Future<void> deletePinHash() async {
    await _secureStorage.deletePinHash();
  }

  @override
  Future<bool> hasPinConfigured() async {
    return await _secureStorage.hasPinConfigured();
  }

  @override
  Future<void> setPinSetupSkipped(bool skipped) async {
    await _secureStorage.setPinSetupSkipped(skipped);
  }

  @override
  Future<bool> hasPinSetupSkipped() async {
    return await _secureStorage.hasPinSetupSkipped();
  }
}
