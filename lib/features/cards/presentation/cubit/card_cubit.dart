import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/card_repository.dart';
import '../../data/models/credit_card_model.dart';
import 'card_state.dart';

class CardCubit extends Cubit<CardState> {
  final CardRepository _repository;

  CardCubit(this._repository) : super(CardInitial());

  Future<void> loadCards() async {
    emit(CardLoading());
    try {
      final list = await _repository.getAll();
      emit(CardLoaded(list));
    } catch (e) {
      emit(CardError(e.toString()));
    }
  }

  Future<void> addCard(
    CreditCardModel model,
    String cardNumber,
    String cvv,
    String note,
    String pinCode,
  ) async {
    try {
      await _repository.save(model, cardNumber, cvv, note, pinCode);
      await loadCards();
    } catch (e) {
      emit(CardError(e.toString()));
      rethrow;
    }
  }

  Future<void> deleteCard(String id) async {
    try {
      await _repository.delete(id);
      await loadCards();
    } catch (e) {
      emit(CardError(e.toString()));
    }
  }

  Future<String?> getCardNumber(String id) async {
    try {
      return await _repository.getCardNumber(id);
    } catch (_) {
      return null;
    }
  }

  Future<String?> getCvv(String id) async {
    try {
      return await _repository.getCvv(id);
    } catch (_) {
      return null;
    }
  }

  Future<String?> getPinCode(String id) async {
    try {
      return await _repository.getPinCode(id);
    } catch (_) {
      return null;
    }
  }
}
