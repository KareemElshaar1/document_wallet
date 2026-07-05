class DocumentFile {
  final String filePath;
  final int fileSize;
  final String fileType;

  const DocumentFile({
    required this.filePath,
    required this.fileSize,
    required this.fileType,
  });

  Map<String, dynamic> toMap() {
    return {
      'filePath': filePath,
      'fileSize': fileSize,
      'fileType': fileType,
    };
  }

  factory DocumentFile.fromMap(Map<String, dynamic> map) {
    return DocumentFile(
      filePath: map['filePath'] as String? ?? '',
      fileSize: map['fileSize'] as int? ?? 0,
      fileType: map['fileType'] as String? ?? 'pdf',
    );
  }
}

class DocumentModel {
  final String id;
  final String title;
  final String categoryId;
  final String categoryName;
  final String? folderId;
  final String description;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime? expirationDate;
  final bool isFavorite;
  final int fileSize;
  final String fileType; // pdf, jpg, png, webp, txt
  final String filePath;
  final bool isLocked;
  final List<DocumentFile> additionalFiles;

  const DocumentModel({
    required this.id,
    required this.title,
    required this.categoryId,
    required this.categoryName,
    this.folderId,
    required this.description,
    required this.tags,
    required this.createdAt,
    this.expirationDate,
    required this.isFavorite,
    required this.fileSize,
    required this.fileType,
    required this.filePath,
    required this.isLocked,
    this.additionalFiles = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'folderId': folderId,
      'description': description,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'expirationDate': expirationDate?.toIso8601String(),
      'isFavorite': isFavorite,
      'fileSize': fileSize,
      'fileType': fileType,
      'filePath': filePath,
      'isLocked': isLocked,
      'additionalFiles': additionalFiles.map((x) => x.toMap()).toList(),
    };
  }

  factory DocumentModel.fromMap(Map<String, dynamic> map) {
    return DocumentModel(
      id: map['id'] as String,
      title: map['title'] as String,
      categoryId: map['categoryId'] as String,
      categoryName: map['categoryName'] as String,
      folderId: map['folderId'] as String?,
      description: map['description'] as String? ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      createdAt: DateTime.parse(map['createdAt'] as String),
      expirationDate: map['expirationDate'] != null 
          ? DateTime.parse(map['expirationDate'] as String) 
          : null,
      isFavorite: map['isFavorite'] as bool? ?? false,
      fileSize: map['fileSize'] as int? ?? 0,
      fileType: map['fileType'] as String? ?? 'pdf',
      filePath: map['filePath'] as String? ?? '',
      isLocked: map['isLocked'] as bool? ?? false,
      additionalFiles: map['additionalFiles'] != null
          ? (map['additionalFiles'] as List)
              .map((e) => DocumentFile.fromMap(Map<String, dynamic>.from(e as Map)))
              .toList()
          : const [],
    );
  }

  DocumentModel copyWith({
    String? id,
    String? title,
    String? categoryId,
    String? categoryName,
    String? folderId,
    String? description,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? expirationDate,
    bool? isFavorite,
    int? fileSize,
    String? fileType,
    String? filePath,
    bool? isLocked,
    List<DocumentFile>? additionalFiles,
  }) {
    return DocumentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      folderId: folderId ?? this.folderId,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      expirationDate: expirationDate ?? this.expirationDate,
      isFavorite: isFavorite ?? this.isFavorite,
      fileSize: fileSize ?? this.fileSize,
      fileType: fileType ?? this.fileType,
      filePath: filePath ?? this.filePath,
      isLocked: isLocked ?? this.isLocked,
      additionalFiles: additionalFiles ?? this.additionalFiles,
    );
  }
}
