import '../../data/datasources/card_datasource.dart';
import '../../data/models/credit_card_model.dart';
import '../../domain/repositories/card_repository.dart';

class CardRepositoryImpl implements CardRepository {
  final CardDataSource _dataSource;

  CardRepositoryImpl(this._dataSource);

  @override
  Future<List<CreditCardModel>> getAll() async {
    return await _dataSource.getAll();
  }

  @override
  Future<void> save(
    CreditCardModel model,
    String cardNumber,
    String cvv,
    String note,
    String pinCode,
  ) async {
    await _dataSource.save(model, cardNumber, cvv, pinCode);
  }

  @override
  Future<void> delete(String id) async {
    await _dataSource.delete(id);
  }

  @override
  Future<String?> getCardNumber(String id) async {
    return await _dataSource.getCardNumber(id);
  }

  @override
  Future<String?> getCvv(String id) async {
    return await _dataSource.getCvv(id);
  }

  @override
  Future<String?> getPinCode(String id) async {
    return await _dataSource.getPinCode(id);
  }
}
