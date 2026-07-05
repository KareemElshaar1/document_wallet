import '../../data/models/credit_card_model.dart';

abstract class CardRepository {
  Future<List<CreditCardModel>> getAll();
  Future<void> save(
    CreditCardModel model,
    String cardNumber,
    String cvv,
    String note,
    String pinCode,
  );
  Future<void> delete(String id);
  Future<String?> getCardNumber(String id);
  Future<String?> getCvv(String id);
  Future<String?> getPinCode(String id);
}
