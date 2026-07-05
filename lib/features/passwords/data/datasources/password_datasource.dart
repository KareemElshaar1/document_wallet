import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/storage/hive_storage.dart';
import '../models/password_model.dart';

abstract class PasswordDataSource {
  Future<List<PasswordModel>> getAll();
  Future<void> save(PasswordModel model, String plainPassword);
  Future<void> update(PasswordModel model, {String? newPassword});
  Future<void> delete(String id);
  Future<String?> getPassword(String id);
}

class PasswordDataSourceImpl implements PasswordDataSource {
  static const _pwPrefix = 'pw_';

  final FlutterSecureStorage _secure;

  PasswordDataSourceImpl(this._secure);

  @override
  Future<List<PasswordModel>> getAll() async {
    final raw = HiveStorage.getPasswords();
    return raw
        .map((e) => PasswordModel.fromMap(e))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<void> save(PasswordModel model, String plainPassword) async {
    await HiveStorage.savePassword(model.id, model.toMap());
    await _secure.write(key: '$_pwPrefix${model.id}', value: plainPassword);
  }

  @override
  Future<void> update(PasswordModel model, {String? newPassword}) async {
    await HiveStorage.savePassword(model.id, model.toMap());
    if (newPassword != null) {
      await _secure.write(key: '$_pwPrefix${model.id}', value: newPassword);
    }
  }

  @override
  Future<void> delete(String id) async {
    await HiveStorage.deletePassword(id);
    await _secure.delete(key: '$_pwPrefix$id');
  }

  @override
  Future<String?> getPassword(String id) async {
    return await _secure.read(key: '$_pwPrefix$id');
  }
}
