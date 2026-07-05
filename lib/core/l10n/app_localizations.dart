import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;
  Map<String, String> _strings = {};

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  Future<bool> load() async {
    final jsonString = await rootBundle.loadString(
      'assets/l10n/app_${locale.languageCode}.arb',
    );
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    _strings = jsonMap.map((key, value) => MapEntry(key, value.toString()));
    return true;
  }

  String _t(String key) => _strings[key] ?? key;

  // ─── App General ────────────────────────────────
  String get appName => _t('appName');
  String get note => _t('note');
  String get pinCode => _t('pinCode');
  String get welcomeBack => _t('welcomeBack');
  String get secureVault => _t('secureVault');
  String get dashboard => _t('dashboard');
  String get search => _t('search');
  String get settings => _t('settings');
  String get documents => _t('documents');
  String get folders => _t('folders');
  String get categories => _t('categories');
  String get passwords => _t('passwords');

  String get cards => _t('cards');
  String get favorites => _t('favorites');
  String get recent => _t('recent');
  String get save => _t('save');
  String get cancel => _t('cancel');
  String get delete => _t('delete');
  String get edit => _t('edit');
  String get rename => _t('rename');
  String get share => _t('share');
  String get print => _t('print');
  String get move => _t('move');
  String get copy => _t('copy');
  String get favorite => _t('favorite');
  String get unfavorite => _t('unfavorite');
  String get lock => _t('lock');
  String get unlock => _t('unlock');
  String get open => _t('open');
  String get view => _t('view');
  String get about => _t('about');
  String get version => _t('version');
  String get other => _t('other');

  // ─── Add Actions ────────────────────────────────
  String get addDocument => _t('addDocument');
  String get addPassword => _t('addPassword');
  String get addCard => _t('addCard');
  String get scanDocument => _t('scanDocument');
  String get takePhoto => _t('takePhoto');
  String get scanQrCode => _t('scanQrCode');
  String get scanQrHint => _t('scanQrHint');
  String get linkedUrl => _t('linkedUrl');
  String get documentTitle => _t('documentTitle');
  String get category => _t('category');
  String get moveToFolder => _t('moveToFolder');
  String get descriptionOptional => _t('descriptionOptional');
  String get tagsOptional => _t('tagsOptional');
  String get saveToVault => _t('saveToVault');
  String get noFileSelected => _t('noFileSelected');
  String get editPhoto => _t('editPhoto');
  String get expirationDateOptional => _t('expirationDateOptional');
  String get noExpiryDate => _t('noExpiryDate');
  String get lockDocumentSubtitle => _t('lockDocumentSubtitle');
  String get importFile => _t('importFile');
  String get importImage => _t('importImage');
  String get camera => _t('camera');
  String get gallery => _t('gallery');
  String get files => _t('files');
  String get createFolder => _t('createFolder');

  // ─── Empty States ────────────────────────────────
  String get noDocuments => _t('noDocuments');
  String get noDocumentsSubtitle => _t('noDocumentsSubtitle');
  String get noPasswords => _t('noPasswords');
  String get noPasswordsSubtitle => _t('noPasswordsSubtitle');
  String get noCards => _t('noCards');
  String get noCardsSubtitle => _t('noCardsSubtitle');

  // ─── Dashboard ────────────────────────────────
  String get storageUsed => _t('storageUsed');
  String get totalFiles => _t('totalFiles');
  String get expiringSoon => _t('expiringSOon');
  String get allSecure => _t('allSecure');
  String get allSecureSubtitle => _t('allSecureSubtitle');
  String get expirationAlerts => _t('expirationAlerts');
  String get expired => _t('expired');
  String get expiresToday => _t('expiresToday');
  String get expiresThisWeek => _t('expiresThisWeek');
  String get expiresThisMonth => _t('expiresThisMonth');
  String get quickActions => _t('quickActions');
  String get recentDocuments => _t('recentDocuments');
  String get walletStorage => _t('walletStorage');

  // ─── Document Form ────────────────────────────────
  String get title => _t('title');
  String get description => _t('description');
  String get folder => _t('folder');
  String get tags => _t('tags');
  String get notes => _t('notes');
  String get expirationDate => _t('expirationDate');
  String get lockDocument => _t('lockDocument');
  String get selectFile => _t('selectFile');
  String get fileSelected => _t('fileSelected');
  String get saveDocument => _t('saveDocument');
  String get documentSaved => _t('documentSaved');
  String get documentDeleted => _t('documentDeleted');
  String get confirmDelete => _t('confirmDelete');
  String get confirmDeleteMessage => _t('confirmDeleteMessage');
  String get addTag => _t('addTag');
  String get noFolder => _t('noFolder');

  // ─── Sort & Filter ────────────────────────────────
  String get sortBy => _t('sortBy');
  String get newest => _t('newest');
  String get oldest => _t('oldest');
  String get nameAZ => _t('nameAZ');
  String get sizeDesc => _t('sizeDesc');
  String get filterBy => _t('filterBy');
  String get allTypes => _t('allTypes');

  // ─── Settings ────────────────────────────────
  String get appearance => _t('appearance');
  String get darkMode => _t('darkMode');
  String get darkModeSubtitle => _t('darkModeSubtitle');
  String get language => _t('language');
  String get english => _t('english');
  String get arabic => _t('arabic');
  String get security => _t('security');
  String get notifications => _t('notifications');
  String get notificationTime => _t('notificationTime');
  String get notificationTimeSubtitle => _t('notificationTimeSubtitle');
  String get reminderDays => _t('reminderDays');
  String get dataBackup => _t('dataBackup');
  String get exportBackup => _t('exportBackup');
  String get exportBackupSubtitle => _t('exportBackupSubtitle');
  String get importBackup => _t('importBackup');
  String get importBackupSubtitle => _t('importBackupSubtitle');
  String get factoryReset => _t('factoryReset');
  String get factoryResetSubtitle => _t('factoryResetSubtitle');
  String get factoryResetTitle => _t('factoryResetTitle');
  String get factoryResetMessage => _t('factoryResetMessage');
  String get securitySettings => _t('securitySettings');
  String get notificationSettings => _t('notificationSettings');
  String get backupRestore => _t('backupRestore');

  // ─── Auth ────────────────────────────────
  String get appLockPin => _t('appLockPin');
  String get appLockPinSubtitle => _t('appLockPinSubtitle');
  String get biometricAuth => _t('biometricAuth');
  String get biometricAuthSubtitle => _t('biometricAuthSubtitle');
  String get enterPinToConfirm => _t('enterPinToConfirm');
  String get eraseAll => _t('eraseAll');
  String get deactivate => _t('deactivate');
  String get deactivateAppLock => _t('deactivateAppLock');
  String get enterPin => _t('enterPin');
  String get invalidPin => _t('invalidPin');
  String get appLockDeactivated => _t('appLockDeactivated');
  String get setupPin => _t('setupPin');
  String get setupPinSubtitle => _t('setupPinSubtitle');
  String get confirmPin => _t('confirmPin');
  String get pinMismatch => _t('pinMismatch');
  String get pinSaved => _t('pinSaved');
  String get enterYourPin => _t('enterYourPin');
  String get useBiometrics => _t('useBiometrics');
  String get biometricFailed => _t('biometricFailed');

  // ─── Password Manager ────────────────────────────────
  String get serviceName => _t('serviceName');
  String get processing => _t('processing');
  String get importFromGallery => _t('importFromGallery');
  String get noQrFound => _t('noQrFound');
  String get errorPickingImage => _t('errorPickingImage');
  String get serviceNameHint => _t('serviceNameHint');
  String get username => _t('username');
  String get password => _t('password');
  String get showPassword => _t('showPassword');
  String get hidePassword => _t('hidePassword');
  String get copyPassword => _t('copyPassword');
  String get passwordCopied => _t('passwordCopied');
  String get requireBiometricToView => _t('requireBiometricToView');
  String get passwordCategory => _t('passwordCategory');
  String get social => _t('social');
  String get banking => _t('banking');
  String get work => _t('work');
  String get shopping => _t('shopping');
  String get entertainment => _t('entertainment');
  String get searchDocs => _t('searchDocs');

  // ─── Credit Cards ────────────────────────────────
  String get bankName => _t('bankName');
  String get cardHolderName => _t('cardHolderName');
  String get cardNumber => _t('cardNumber');
  String get expiryDate => _t('expiryDate');
  String get cvv => _t('cvv');
  String get cardType => _t('cardType');
  String get visa => _t('visa');
  String get mastercard => _t('mastercard');
  String get amex => _t('amex');
  String get tapToReveal => _t('tapToReveal');
  String get addCardPhoto => _t('addCardPhoto');
  String get cardPhotoOptional => _t('cardPhotoOptional');

  // ─── Image Editor ────────────────────────────────
  String get photoEditing => _t('photoEditing');
  String get cropRotate => _t('cropRotate');

  // ─── Categories ────────────────────────────────
  String get categoryPersonal => _t('categoryPersonal');
  String get categoryEducation => _t('categoryEducation');
  String get categoryMedical => _t('categoryMedical');
  String get categoryFinance => _t('categoryFinance');
  String get categoryWork => _t('categoryWork');
  String get categoryVehicle => _t('categoryVehicle');
  String get categoryWarranty => _t('categoryWarranty');

  // ─── Warning Banner ────────────────────────────────
  String get warning => _t('warning');
  String get pleaseRenew => _t('pleaseRenew');
  String get pleaseCheck => _t('pleaseCheck');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
