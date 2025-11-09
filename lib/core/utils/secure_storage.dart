import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:todouapp/core/constants/app_constants.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<String?> getToken() async {
    return await _storage.read(key: AppConstants.tokenKey);
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: AppConstants.tokenKey, value: token);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: AppConstants.tokenKey);
  }

  Future<String?> getMarchandId() async {
    return await _storage.read(key: 'marchant_id');
  }

  Future<void> saveMarchandId(String token) async {
    await _storage.write(key: 'marchant_id', value: token);
  }

  Future<String?> getTerminalId() async {
    return await _storage.read(key: 'terminal_id');
  }

  Future<void> saveTerminalId(String token) async {
    await _storage.write(key: 'terminal_id', value: token);
  }

  Future<String?> getMerchantName() async {
    return await _storage.read(key: 'merchant_first_name');
  }

  Future<void> saveMerchantName(String token) async {
    await _storage.write(key: 'merchant_first_name', value: token);
  }

  Future<String?> getCurrency() async {
    return await _storage.read(key: 'currency');
  }

  Future<void> saveCurrency(String token) async {
    await _storage.write(key: 'currency', value: token);
  }

  Future<String?> getStripeConnectedTerminal() async {
    return await _storage.read(key: 'reader');
  }

  Future<void> saveStripeConnectedTerminal(String token) async {
    await _storage.write(key: 'reader', value: token);
  }

  // Selected terminal for merchant
  Future<String?> getSelectedTerminal() async {
    return await _storage.read(key: 'selected_terminal_id');
  }

  Future<void> saveSelectedTerminal(String terminalId) async {
    await _storage.write(key: 'selected_terminal_id', value: terminalId);
  }

  // Onboarding completed flag
  Future<bool> hasCompletedOnboarding() async {
    final value = await _storage.read(key: AppConstants.onboardingCompletedKey);
    return value == 'true';
  }

  Future<void> setOnboardingCompleted() async {
    await _storage.write(key: AppConstants.onboardingCompletedKey, value: 'true');
  }
}
