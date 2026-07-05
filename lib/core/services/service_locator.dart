import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:local_auth/local_auth.dart';

import '../storage/secure_storage.dart';
import 'local_auth_service.dart';
import 'notification_service.dart';

// Import Cubits & Repositories
import '../../features/authentication/data/datasources/auth_local_datasource.dart';
import '../../features/authentication/data/repositories/auth_repository_impl.dart';
import '../../features/authentication/domain/repositories/auth_repository.dart';
import '../../features/authentication/presentation/cubit/auth_cubit.dart';

import '../../features/document_manager/data/datasources/document_local_datasource.dart';
import '../../features/document_manager/data/repositories/document_repository_impl.dart';
import '../../features/document_manager/domain/repositories/document_repository.dart';
import '../../features/document_manager/presentation/cubit/document_cubit.dart';

import '../../features/settings/presentation/cubit/settings_cubit.dart';

// New Features
import '../../features/passwords/data/datasources/password_datasource.dart';
import '../../features/passwords/data/repositories/password_repository_impl.dart';
import '../../features/passwords/domain/repositories/password_repository.dart';
import '../../features/passwords/presentation/cubit/password_cubit.dart';

import '../../features/cards/data/datasources/card_datasource.dart';
import '../../features/cards/data/repositories/card_repository_impl.dart';
import '../../features/cards/domain/repositories/card_repository.dart';
import '../../features/cards/presentation/cubit/card_cubit.dart';

final sl = GetIt.instance;

Future<void> setupLocator() async {
  // --- External Dependencies ---
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    ),
  );
  sl.registerLazySingleton<LocalAuthentication>(() => LocalAuthentication());
  sl.registerLazySingleton<FlutterLocalNotificationsPlugin>(
    () => FlutterLocalNotificationsPlugin(),
  );

  // --- Core Services & Storage ---
  sl.registerLazySingleton<SecureStorage>(() => SecureStorage(sl()));
  sl.registerLazySingleton<LocalAuthService>(() => LocalAuthService(sl()));
  sl.registerLazySingleton<NotificationService>(() => NotificationService(sl()));

  // --- Features: Authentication ---
  sl.registerLazySingleton<AuthLocalDataSource>(() => AuthLocalDataSourceImpl(sl()));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl(), sl()));
  sl.registerFactory<AuthCubit>(() => AuthCubit(sl()));

  // --- Features: Document Manager ---
  sl.registerLazySingleton<DocumentLocalDataSource>(() => DocumentLocalDataSourceImpl());
  sl.registerLazySingleton<DocumentRepository>(() => DocumentRepositoryImpl(sl()));
  sl.registerFactory<DocumentCubit>(() => DocumentCubit(sl()));

  // --- Features: Settings ---
  sl.registerFactory<SettingsCubit>(() => SettingsCubit());

  // --- Features: Passwords ---
  sl.registerLazySingleton<PasswordDataSource>(() => PasswordDataSourceImpl(sl()));
  sl.registerLazySingleton<PasswordRepository>(() => PasswordRepositoryImpl(sl()));
  sl.registerFactory<PasswordCubit>(() => PasswordCubit(sl()));

  // --- Features: Cards ---
  sl.registerLazySingleton<CardDataSource>(() => CardDataSourceImpl(sl()));
  sl.registerLazySingleton<CardRepository>(() => CardRepositoryImpl(sl()));
  sl.registerFactory<CardCubit>(() => CardCubit(sl()));
}
