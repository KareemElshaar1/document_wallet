import '../../data/models/document_model.dart';
import '../../data/models/folder_model.dart';

abstract class DocumentRepository {
  List<DocumentModel> getDocuments();
  Future<void> addDocument(DocumentModel document);
  Future<void> updateDocument(DocumentModel document);
  Future<void> deleteDocument(String id);

  List<FolderModel> getFolders();
  Future<void> addFolder(FolderModel folder);
  Future<void> updateFolder(FolderModel folder);
  Future<void> deleteFolder(String id);
}
