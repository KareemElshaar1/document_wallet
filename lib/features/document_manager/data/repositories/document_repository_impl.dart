import '../../domain/repositories/document_repository.dart';
import '../datasources/document_local_datasource.dart';
import '../models/document_model.dart';
import '../models/folder_model.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  final DocumentLocalDataSource _localDataSource;

  DocumentRepositoryImpl(this._localDataSource);

  @override
  List<DocumentModel> getDocuments() {
    return _localDataSource.getDocuments();
  }

  @override
  Future<void> addDocument(DocumentModel document) async {
    await _localDataSource.saveDocument(document);
  }

  @override
  Future<void> updateDocument(DocumentModel document) async {
    await _localDataSource.saveDocument(document);
  }

  @override
  Future<void> deleteDocument(String id) async {
    await _localDataSource.deleteDocument(id);
  }

  @override
  List<FolderModel> getFolders() {
    return _localDataSource.getFolders();
  }

  @override
  Future<void> addFolder(FolderModel folder) async {
    await _localDataSource.saveFolder(folder);
  }

  @override
  Future<void> updateFolder(FolderModel folder) async {
    await _localDataSource.saveFolder(folder);
  }

  @override
  Future<void> deleteFolder(String id) async {
    await _localDataSource.deleteFolder(id);
  }
}
