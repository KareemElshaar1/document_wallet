import '../../data/models/document_model.dart';
import '../../data/models/folder_model.dart';

enum DocumentStatus { initial, loading, success, error }

class DocumentState {
  final List<DocumentModel> documents;
  final List<FolderModel> folders;
  final DocumentStatus status;
  final String? errorMessage;

  const DocumentState({
    required this.documents,
    required this.folders,
    required this.status,
    this.errorMessage,
  });

  factory DocumentState.initial() {
    return const DocumentState(
      documents: [],
      folders: [],
      status: DocumentStatus.initial,
      errorMessage: null,
    );
  }

  DocumentState copyWith({
    List<DocumentModel>? documents,
    List<FolderModel>? folders,
    DocumentStatus? status,
    String? errorMessage,
  }) {
    return DocumentState(
      documents: documents ?? this.documents,
      folders: folders ?? this.folders,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
