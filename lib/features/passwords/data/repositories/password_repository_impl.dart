import '../../data/datasources/password_datasource.dart';
import '../../data/models/password_model.dart';
import '../../domain/repositories/password_repository.dart';

class PasswordRepositoryImpl implements PasswordRepository {
  final PasswordDataSource _dataSource;

  PasswordRepositoryImpl(this._dataSource);

  @override
  Future<List<PasswordModel>> getAll() async {
    return await _dataSource.getAll();
  }

  @override
  Future<void> save(PasswordModel model, String plainPassword) async {
    await _dataSource.save(model, plainPassword);
  }

  @override
  Future<void> update(PasswordModel model, {String? newPassword}) async {
    await _dataSource.update(model, newPassword: newPassword);
  }

  @override
  Future<void> delete(String id) async {
    await _dataSource.delete(id);
  }

  @override
  Future<String?> getPassword(String id) async {
    return await _dataSource.getPassword(id);
  }
}
