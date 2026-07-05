import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_state.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(AuthInitial());

  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    final hasPin = await _authRepository.hasPin();
    if (!hasPin) {
      emit(AuthSetupRequired());
    } else {
      emit(const AuthLocked(isBiometricEnabled: false));
    }
  }

  Future<void> setupNewPin(String pin) async {
    emit(AuthLoading());
    if (pin.length < 4) {
      emit(const AuthError('PIN code must be at least 4 digits'));
      emit(AuthSetupRequired());
      return;
    }
    final success = await _authRepository.setupPin(pin);
    if (success) {
      emit(AuthSuccess());
    } else {
      emit(const AuthError('Failed to save PIN code. Please try again.'));
      emit(AuthSetupRequired());
    }
  }

  Future<void> enterPin(String pin) async {
    final success = await _authRepository.authenticatePin(pin);
    if (success) {
      emit(AuthSuccess());
    } else {
      emit(
        const AuthLocked(
          isBiometricEnabled: false,
          errorMessage: 'Invalid PIN Code',
        ),
      );
    }
  }

  Future<bool> verifyPin(String pin) async {
    return await _authRepository.authenticatePin(pin);
  }

  Future<void> tryBiometricAuth() async {
    final bioEnabled = await _authRepository.isBiometricEnabled();

    emit(AuthLoading());
    final success = await _authRepository.authenticateBiometrics();
    if (success) {
      emit(AuthSuccess());
    } else {
      emit(
        AuthLocked(
          isBiometricEnabled: bioEnabled,
          errorMessage: bioEnabled ? 'Biometric authentication failed' : null,
        ),
      );
    }
  }

  Future<void> logOut() async {
    final bioEnabled = await _authRepository.isBiometricEnabled();
    emit(AuthLocked(isBiometricEnabled: bioEnabled));
  }

  Future<void> enableBiometrics(bool enable) async {
    await _authRepository.enableBiometrics(enable);
  }

  Future<bool> isBiometricEnabled() async {
    return await _authRepository.isBiometricEnabled();
  }

  Future<bool> isBiometricAvailable() async {
    return await _authRepository.isBiometricAvailable();
  }

  Future<void> factoryReset() async {
    await _authRepository.clearAuth();
    emit(AuthSetupRequired());
  }
}
