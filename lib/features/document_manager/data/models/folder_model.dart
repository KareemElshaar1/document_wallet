class FolderModel {
  final String id;
  final String name;
  final DateTime createdAt;
  final bool isFavorite;
  final int iconCode;
  final int colorValue;

  const FolderModel({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.isFavorite,
    required this.iconCode,
    required this.colorValue,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'isFavorite': isFavorite,
      'iconCode': iconCode,
      'colorValue': colorValue,
    };
  }

  factory FolderModel.fromMap(Map<String, dynamic> map) {
    return FolderModel(
      id: map['id'] as String,
      name: map['name'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      isFavorite: map['isFavorite'] as bool? ?? false,
      iconCode: map['iconCode'] as int? ?? 0xe2a3, // Default folder icon
      colorValue: map['colorValue'] as int? ?? 0xFF6366F1,
    );
  }

  FolderModel copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    bool? isFavorite,
    int? iconCode,
    int? colorValue,
  }) {
    return FolderModel(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
      iconCode: iconCode ?? this.iconCode,
      colorValue: colorValue ?? this.colorValue,
    );
  }
}
