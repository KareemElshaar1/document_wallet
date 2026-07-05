import '../../data/models/password_model.dart';

abstract class PasswordState {
  const PasswordState();
}

class PasswordInitial extends PasswordState {}

class PasswordLoading extends PasswordState {}

class PasswordLoaded extends PasswordState {
  final List<PasswordModel> passwords;
  const PasswordLoaded(this.passwords);
}

class PasswordError extends PasswordState {
  final String message;
  const PasswordError(this.message);
}
