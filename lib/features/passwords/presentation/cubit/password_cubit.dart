import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/password_repository.dart';
import '../../data/models/password_model.dart';
import 'password_state.dart';

class PasswordCubit extends Cubit<PasswordState> {
  final PasswordRepository _repository;

  PasswordCubit(this._repository) : super(PasswordInitial());

  Future<void> loadPasswords() async {
    emit(PasswordLoading());
    try {
      final list = await _repository.getAll();
      emit(PasswordLoaded(list));
    } catch (e) {
      emit(PasswordError(e.toString()));
    }
  }

  Future<void> addPassword(PasswordModel model, String plainPassword) async {
    try {
      await _repository.save(model, plainPassword);
      await loadPasswords();
    } catch (e) {
      emit(PasswordError(e.toString()));
      rethrow;
    }
  }

  Future<void> updatePassword(PasswordModel model, {String? newPassword}) async {
    try {
      await _repository.update(model, newPassword: newPassword);
      await loadPasswords();
    } catch (e) {
      emit(PasswordError(e.toString()));
    }
  }

  Future<void> deletePassword(String id) async {
    try {
      await _repository.delete(id);
      await loadPasswords();
    } catch (e) {
      emit(PasswordError(e.toString()));
    }
  }

  Future<String?> getPlainPassword(String id) async {
    try {
      return await _repository.getPassword(id);
    } catch (_) {
      return null;
    }
  }
}
