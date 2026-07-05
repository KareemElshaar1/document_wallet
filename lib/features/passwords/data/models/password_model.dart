import 'package:uuid/uuid.dart';

class PasswordModel {
  final String id;
  final String serviceName;
  final String username;
  final String categoryTag; // social, banking, work, shopping, entertainment, other
  final int colorValue;
  final int iconCode;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Note: the actual password string is stored separately in SecureStorage
  // keyed by id, so it never appears in Hive unencrypted.

  PasswordModel({
    String? id,
    required this.serviceName,
    required this.username,
    this.categoryTag = 'other',
    this.colorValue = 0xFF6366F1,
    this.iconCode = 0xe3af, // Icons.lock
    DateTime? createdAt,
    this.updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'serviceName': serviceName,
        'username': username,
        'categoryTag': categoryTag,
        'colorValue': colorValue,
        'iconCode': iconCode,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory PasswordModel.fromMap(Map<String, dynamic> map) => PasswordModel(
        id: map['id'] as String,
        serviceName: map['serviceName'] as String,
        username: map['username'] as String,
        categoryTag: map['categoryTag'] as String? ?? 'other',
        colorValue: map['colorValue'] as int? ?? 0xFF6366F1,
        iconCode: map['iconCode'] as int? ?? 0xe3af,
        createdAt: DateTime.parse(map['createdAt'] as String),
        updatedAt: map['updatedAt'] != null
            ? DateTime.parse(map['updatedAt'] as String)
            : null,
      );

  PasswordModel copyWith({
    String? serviceName,
    String? username,
    String? categoryTag,
    int? colorValue,
    int? iconCode,
    DateTime? updatedAt,
  }) =>
      PasswordModel(
        id: id,
        serviceName: serviceName ?? this.serviceName,
        username: username ?? this.username,
        categoryTag: categoryTag ?? this.categoryTag,
        colorValue: colorValue ?? this.colorValue,
        iconCode: iconCode ?? this.iconCode,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
