import '../../data/models/password_model.dart';

abstract class PasswordRepository {
  Future<List<PasswordModel>> getAll();
  Future<void> save(PasswordModel model, String plainPassword);
  Future<void> update(PasswordModel model, {String? newPassword});
  Future<void> delete(String id);
  Future<String?> getPassword(String id);
}
