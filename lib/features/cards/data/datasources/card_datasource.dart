import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/storage/hive_storage.dart';
import '../models/credit_card_model.dart';

abstract class CardDataSource {
  Future<List<CreditCardModel>> getAll();

  Future<void> save(
    CreditCardModel model,
    String cardNumber,
    String cvv,
    String pinCode,
  );

  Future<void> delete(String id);

  Future<String?> getCardNumber(String id);

  Future<String?> getCvv(String id);

  Future<String?> getPinCode(String id);
}

class CardDataSourceImpl implements CardDataSource {
  static const _cardNumPrefix = 'card_num_';
  static const _cardCvvPrefix = 'card_cvv_';
  static const _cardPinCodePrefix = 'card_pin_code_';

  final FlutterSecureStorage _secureStorage;

  CardDataSourceImpl(this._secureStorage);

  @override
  Future<List<CreditCardModel>> getAll() async {
    final raw = HiveStorage.getCards();

    return raw.map((e) => CreditCardModel.fromMap(e)).toList()
      ..sort((a, b) => b.addedAt.compareTo(a.addedAt));
  }

  @override
  Future<void> save(
    CreditCardModel model,
    String cardNumber,
    String cvv,
    String pinCode,
  ) async {
    // note محفوظ داخل model
    await HiveStorage.saveCard(model.id, model.toMap());

    await _secureStorage.write(
      key: '$_cardNumPrefix${model.id}',
      value: cardNumber,
    );

    await _secureStorage.write(key: '$_cardCvvPrefix${model.id}', value: cvv);

    await _secureStorage.write(
      key: '$_cardPinCodePrefix${model.id}',
      value: pinCode,
    );
  }

  @override
  Future<void> delete(String id) async {
    await HiveStorage.deleteCard(id);

    await _secureStorage.delete(key: '$_cardNumPrefix$id');

    await _secureStorage.delete(key: '$_cardCvvPrefix$id');

    await _secureStorage.delete(key: '$_cardPinCodePrefix$id');
  }

  @override
  Future<String?> getCardNumber(String id) {
    return _secureStorage.read(key: '$_cardNumPrefix$id');
  }

  @override
  Future<String?> getCvv(String id) {
    return _secureStorage.read(key: '$_cardCvvPrefix$id');
  }

  @override
  Future<String?> getPinCode(String id) {
    return _secureStorage.read(key: '$_cardPinCodePrefix$id');
  }
}
