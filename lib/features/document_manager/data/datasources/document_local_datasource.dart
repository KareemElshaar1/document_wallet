import '../../../../core/storage/hive_storage.dart';
import '../models/document_model.dart';
import '../models/folder_model.dart';

abstract class DocumentLocalDataSource {
  List<DocumentModel> getDocuments();
  Future<void> saveDocument(DocumentModel document);
  Future<void> deleteDocument(String id);

  List<FolderModel> getFolders();
  Future<void> saveFolder(FolderModel folder);
  Future<void> deleteFolder(String id);
}

class DocumentLocalDataSourceImpl implements DocumentLocalDataSource {
  @override
  List<DocumentModel> getDocuments() {
    final rawDocs = HiveStorage.getDocuments();
    return rawDocs.map((map) => DocumentModel.fromMap(map)).toList();
  }

  @override
  Future<void> saveDocument(DocumentModel document) async {
    await HiveStorage.saveDocument(document.id, document.toMap());
  }

  @override
  Future<void> deleteDocument(String id) async {
    await HiveStorage.deleteDocument(id);
  }

  @override
  List<FolderModel> getFolders() {
    final rawFolders = HiveStorage.getFolders();
    return rawFolders.map((map) => FolderModel.fromMap(map)).toList();
  }

  @override
  Future<void> saveFolder(FolderModel folder) async {
    await HiveStorage.saveFolder(folder.id, folder.toMap());
  }

  @override
  Future<void> deleteFolder(String id) async {
    await HiveStorage.deleteFolder(id);
  }
}
