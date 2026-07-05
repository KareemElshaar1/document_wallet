import '../../../../core/storage/secure_storage.dart';

abstract class AuthLocalDataSource {
  Future<void> savePin(String pin);
  Future<String?> getPin();
  Future<bool> hasPin();
  Future<void> deletePin();
  Future<void> setBiometricEnabled(bool enabled);
  Future<bool> isBiometricEnabled();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SecureStorage _secureStorage;

  AuthLocalDataSourceImpl(this._secureStorage);

  @override
  Future<void> savePin(String pin) async {
    await _secureStorage.savePin(pin);
  }

  @override
  Future<String?> getPin() async {
    return await _secureStorage.getPin();
  }

  @override
  Future<bool> hasPin() async {
    return await _secureStorage.hasPin();
  }

  @override
  Future<void> deletePin() async {
    await _secureStorage.deletePin();
  }

  @override
  Future<void> setBiometricEnabled(bool enabled) async {
    await _secureStorage.setBiometricEnabled(enabled);
  }

  @override
  Future<bool> isBiometricEnabled() async {
    return await _secureStorage.isBiometricEnabled();
  }
}
