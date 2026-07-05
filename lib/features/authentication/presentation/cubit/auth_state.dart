abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSetupRequired extends AuthState {}

class AuthLocked extends AuthState {
  final bool isBiometricEnabled;
  final String? errorMessage;

  const AuthLocked({required this.isBiometricEnabled, this.errorMessage});
}

class AuthSuccess extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);
}
