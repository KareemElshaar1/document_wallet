import 'package:document_wallet/features/authentication/domain/repositories/auth_repository.dart';

import '../../../../core/services/local_auth_service.dart';
import '../datasources/auth_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource _dataSource;
  final LocalAuthService _localAuthService;

  AuthRepositoryImpl(this._dataSource, this._localAuthService);

  @override
  Future<bool> setupPin(String pin) async {
    try {
      await _dataSource.savePin(pin);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> authenticatePin(String pin) async {
    try {
      final savedPin = await _dataSource.getPin();
      return savedPin == pin;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> hasPin() async {
    return await _dataSource.hasPin();
  }

  @override
  Future<bool> isBiometricAvailable() async {
    return await _localAuthService.isBiometricSupported();
  }

  @override
  Future<bool> authenticateBiometrics() async {
    final available = await isBiometricAvailable();
    final enabled = await isBiometricEnabled();
    if (!available || !enabled) return false;

    return await _localAuthService.authenticate(
      localizedReason: 'Access your secure Document Wallet',
    );
  }

  @override
  Future<void> enableBiometrics(bool enable) async {
    await _dataSource.setBiometricEnabled(enable);
  }

  @override
  Future<bool> isBiometricEnabled() async {
    return await _dataSource.isBiometricEnabled();
  }

  @override
  Future<void> clearAuth() async {
    await _dataSource.deletePin();
    await _dataSource.setBiometricEnabled(false);
  }
}
