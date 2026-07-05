import 'package:hive_flutter/hive_flutter.dart';

class HiveStorage {
  HiveStorage._();

  static const String _documentsBoxName = 'documents_v1';
  static const String _foldersBoxName = 'folders_v1';
  static const String _settingsBoxName = 'settings_v1';
  static const String _passwordsBoxName = 'passwords_box';
  static const String _cardsBoxName = 'cards_box';

  static late Box _documentsBox;
  static late Box _foldersBox;
  static late Box _settingsBox;
  static late Box _passwordsBox;
  static late Box _cardsBox;

  /// Opens boxes without generic types so all accessors share the same Box instance.
  static Future<Box> _openBoxSafe(String name) async {
    if (Hive.isBoxOpen(name)) {
      return Hive.box(name);
    }
    return Hive.openBox(name, crashRecovery: true);
  }

  static Future<void> init() async {
    await Hive.initFlutter();

    _documentsBox = await _openBoxSafe(_documentsBoxName);
    _foldersBox = await _openBoxSafe(_foldersBoxName);
    _settingsBox = await _openBoxSafe(_settingsBoxName);
    _passwordsBox = await _openBoxSafe(_passwordsBoxName);
    _cardsBox = await _openBoxSafe(_cardsBoxName);
  }

  // --- Document CRUD Operations ---
  static List<Map<String, dynamic>> getDocuments() {
    return _documentsBox.values
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  static Future<void> saveDocument(
    String id,
    Map<String, dynamic> docMap,
  ) async {
    await _documentsBox.put(id, docMap);
  }

  static Future<void> deleteDocument(String id) async {
    await _documentsBox.delete(id);
  }

  // --- Folder CRUD Operations ---
  static List<Map<String, dynamic>> getFolders() {
    return _foldersBox.values
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  static Future<void> saveFolder(
    String id,
    Map<String, dynamic> folderMap,
  ) async {
    await _foldersBox.put(id, folderMap);
  }

  static Future<void> deleteFolder(String id) async {
    await _foldersBox.delete(id);
  }

  // --- Card CRUD Operations ---
  static List<Map<String, dynamic>> getCards() {
    return _cardsBox.values
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  static Future<void> saveCard(String id, Map<String, dynamic> cardMap) async {
    await _cardsBox.put(id, cardMap);
  }

  static Future<void> deleteCard(String id) async {
    await _cardsBox.delete(id);
  }

  // --- Password CRUD Operations ---
  static List<Map<String, dynamic>> getPasswords() {
    return _passwordsBox.values
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  static Future<void> savePassword(
    String id,
    Map<String, dynamic> passwordMap,
  ) async {
    await _passwordsBox.put(id, passwordMap);
  }

  static Future<void> deletePassword(String id) async {
    await _passwordsBox.delete(id);
  }

  // --- Settings Helper Operations ---
  static dynamic getSetting(String key, {dynamic defaultValue}) {
    return _settingsBox.get(key, defaultValue: defaultValue);
  }

  static Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  static Future<void> clearAll() async {
    await _documentsBox.clear();
    await _foldersBox.clear();
    await _settingsBox.clear();
    await _passwordsBox.clear();
    await _cardsBox.clear();
  }
}
