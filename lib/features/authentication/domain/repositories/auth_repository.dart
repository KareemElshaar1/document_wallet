abstract class AuthRepository {
  Future<bool> setupPin(String pin);
  Future<bool> authenticatePin(String pin);
  Future<bool> hasPin();
  Future<bool> isBiometricAvailable();
  Future<bool> authenticateBiometrics();
  Future<void> enableBiometrics(bool enable);
  Future<bool> isBiometricEnabled();
  Future<void> clearAuth();
}
