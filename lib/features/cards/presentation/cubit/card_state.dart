import '../../data/models/credit_card_model.dart';

abstract class CardState {
  const CardState();
}

class CardInitial extends CardState {}

class CardLoading extends CardState {}

class CardLoaded extends CardState {
  final List<CreditCardModel> cards;
  const CardLoaded(this.cards);
}

class CardError extends CardState {
  final String message;
  const CardError(this.message);
}
