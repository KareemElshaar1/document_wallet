import 'package:uuid/uuid.dart';

class CreditCardModel {
  final String id;
  final String bankName;
  final String cardHolderName;
  final String maskedNumber; // e.g. "•••• •••• •••• 4321"
  final String cardType; // visa, mastercard, amex, other
  final int colorValue; // Hex color for card background
  final String? photoPath; // Local file path to the photo of the card
  final String expiryMonth;
  final String expiryYear;
  final DateTime addedAt;
  final String? note;

  CreditCardModel({
    String? id,
    required this.bankName,
    required this.cardHolderName,
    this.note,
    required this.maskedNumber,
    this.cardType = 'other',
    this.colorValue = 0xFF1E293B,
    this.photoPath,

    required this.expiryMonth,
    required this.expiryYear,
    DateTime? addedAt,
  }) : id = id ?? const Uuid().v4(),
       addedAt = addedAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'id': id,
    'bankName': bankName,
    'cardHolderName': cardHolderName,
    'maskedNumber': maskedNumber,
    'cardType': cardType,
    'note': note,
    'colorValue': colorValue,
    'photoPath': photoPath,
    'expiryMonth': expiryMonth,
    'expiryYear': expiryYear,
    'addedAt': addedAt.toIso8601String(),
  };

  factory CreditCardModel.fromMap(Map<String, dynamic> map) => CreditCardModel(
    id: map['id'] as String,
    bankName: map['bankName'] as String,
    cardHolderName: map['cardHolderName'] as String,
    maskedNumber: map['maskedNumber'] as String,
    cardType: map['cardType'] as String? ?? 'other',
    note: map['note'] as String?,
    colorValue: map['colorValue'] as int? ?? 0xFF1E293B,
    photoPath: map['photoPath'] as String?,
    expiryMonth: map['expiryMonth'] as String,
    expiryYear: map['expiryYear'] as String,
    addedAt: DateTime.parse(map['addedAt'] as String),
  );

  CreditCardModel copyWith({
    String? bankName,
    String? cardHolderName,
    String? maskedNumber,
    String? cardType,
    int? colorValue,
    String? note,
    String? photoPath,
    String? expiryMonth,
    String? expiryYear,
  }) => CreditCardModel(
    id: id,
    bankName: bankName ?? this.bankName,
    cardHolderName: cardHolderName ?? this.cardHolderName,
    maskedNumber: maskedNumber ?? this.maskedNumber,
    cardType: cardType ?? this.cardType,
    colorValue: colorValue ?? this.colorValue,
    photoPath: photoPath ?? this.photoPath,
    expiryMonth: expiryMonth ?? this.expiryMonth,
    expiryYear: expiryYear ?? this.expiryYear,
    addedAt: addedAt,
    note: note ?? this.note,
  );
}
