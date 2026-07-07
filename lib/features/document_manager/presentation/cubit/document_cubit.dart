import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../domain/repositories/document_repository.dart';
import '../../data/models/document_model.dart';
import '../../data/models/folder_model.dart';
import 'document_state.dart';

class DocumentCubit extends Cubit<DocumentState> {
  final DocumentRepository _repository;
  final Uuid _uuid = const Uuid();

  DocumentCubit(this._repository) : super(DocumentState.initial());

  void loadAllData() {
    emit(state.copyWith(status: DocumentStatus.loading));
    try {
      final documents = _repository.getDocuments();
      final folders = _repository.getFolders();
      emit(
        state.copyWith(
          documents: documents,
          folders: folders,
          status: DocumentStatus.success,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: DocumentStatus.error,
          errorMessage: 'Failed to load documents: ${e.toString()}',
        ),
      );
    }
  }

  // --- Folder Management ---
  Future<void> createFolder(String name, int iconCode, int colorValue) async {
    emit(state.copyWith(status: DocumentStatus.loading));
    try {
      final newFolder = FolderModel(
        id: _uuid.v4(),
        name: name,
        createdAt: DateTime.now(),
        isFavorite: false,
        iconCode: iconCode,
        colorValue: colorValue,
      );
      await _repository.addFolder(newFolder);
      loadAllData();
    } catch (e) {
      emit(
        state.copyWith(
          status: DocumentStatus.error,
          errorMessage: 'Failed to create folder: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> toggleFavoriteFolder(String folderId) async {
    try {
      final folder = state.folders.firstWhere((f) => f.id == folderId);
      final updated = folder.copyWith(isFavorite: !folder.isFavorite);
      await _repository.updateFolder(updated);
      loadAllData();
    } catch (_) {}
  }

  Future<void> renameFolder(String folderId, String newName) async {
    try {
      final folder = state.folders.firstWhere((f) => f.id == folderId);
      final updated = folder.copyWith(name: newName);
      await _repository.updateFolder(updated);
      loadAllData();
    } catch (_) {}
  }

  Future<void> deleteFolder(String folderId) async {
    emit(state.copyWith(status: DocumentStatus.loading));
    try {
      // 1. Delete folder
      await _repository.deleteFolder(folderId);

      // 2. Remove folder link from all documents in this folder
      final documentsInFolder = state.documents.where(
        (doc) => doc.folderId == folderId,
      );
      for (final doc in documentsInFolder) {
        final updatedDoc = doc.copyWith(clearFolderId: true);
        await _repository.updateDocument(updatedDoc);
      }

      loadAllData();
    } catch (e) {
      emit(
        state.copyWith(
          status: DocumentStatus.error,
          errorMessage: 'Failed to delete folder: ${e.toString()}',
        ),
      );
    }
  }

  // --- Document Management ---
  Future<void> addDocument({
    required String title,
    required String categoryId,
    required String categoryName,
    String? folderId,
    required String description,
    required List<String> tags,
    DateTime? expirationDate,
    required int fileSize,
    required String fileType,
    required String filePath,
    required bool isLocked,
    List<DocumentFile> additionalFiles = const [],
  }) async {
    emit(state.copyWith(status: DocumentStatus.loading));
    try {
      final newDoc = DocumentModel(
        id: _uuid.v4(),
        title: title,
        categoryId: categoryId,
        categoryName: categoryName,
        folderId: folderId,
        description: description,
        tags: tags,
        createdAt: DateTime.now(),
        expirationDate: expirationDate,
        isFavorite: false,
        fileSize: fileSize,
        fileType: fileType,
        filePath: filePath,
        isLocked: isLocked,
        additionalFiles: additionalFiles,
      );
      await _repository.addDocument(newDoc);
      loadAllData();
    } catch (e) {
      emit(
        state.copyWith(
          status: DocumentStatus.error,
          errorMessage: 'Failed to add document: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> deleteDocument(String id) async {
    emit(state.copyWith(status: DocumentStatus.loading));
    try {
      final doc = state.documents.firstWhere((d) => d.id == id);

      // Physically delete the local copy of the file
      try {
        final file = File(doc.filePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {
        // Ignore deletion errors if file was manually deleted from disk
      }

      // Physically delete the local copies of additional files
      for (final addFile in doc.additionalFiles) {
        try {
          final file = File(addFile.filePath);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (_) {
          // Ignore
        }
      }

      await _repository.deleteDocument(id);
      loadAllData();
    } catch (e) {
      emit(
        state.copyWith(
          status: DocumentStatus.error,
          errorMessage: 'Failed to delete document: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> updateDocumentDetails(DocumentModel updatedDoc) async {
    emit(state.copyWith(status: DocumentStatus.loading));
    try {
      await _repository.updateDocument(updatedDoc);
      loadAllData();
    } catch (e) {
      emit(
        state.copyWith(
          status: DocumentStatus.error,
          errorMessage: 'Failed to update document: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> toggleFavoriteDocument(String id) async {
    try {
      final doc = state.documents.firstWhere((d) => d.id == id);
      final updated = doc.copyWith(isFavorite: !doc.isFavorite);
      await _repository.updateDocument(updated);
      loadAllData();
    } catch (_) {}
  }

  Future<void> moveDocument(String docId, String? folderId) async {
    try {
      final doc = state.documents.firstWhere((d) => d.id == docId);
      final updated = doc.copyWith(folderId: folderId);
      await _repository.updateDocument(updated);
      loadAllData();
    } catch (_) {}
  }

  Future<void> toggleLockDocument(String docId, bool isLocked) async {
    try {
      final doc = state.documents.firstWhere((d) => d.id == docId);
      final updated = doc.copyWith(isLocked: isLocked);
      await _repository.updateDocument(updated);
      loadAllData();
    } catch (_) {}
  }

  Future<void> restoreBackup({
    required List<Map<String, dynamic>> folders,
    required List<Map<String, dynamic>> documents,
  }) async {
    emit(state.copyWith(status: DocumentStatus.loading));
    try {
      for (final fMap in folders) {
        final folder = FolderModel.fromMap(fMap);
        await _repository.addFolder(folder);
      }
      for (final dMap in documents) {
        final doc = DocumentModel.fromMap(dMap);
        await _repository.addDocument(doc);
      }
      loadAllData();
    } catch (e) {
      emit(
        state.copyWith(
          status: DocumentStatus.error,
          errorMessage: 'Failed to restore backup: ${e.toString()}',
        ),
      );
    }
  }
}
