import 'package:document_wallet/features/cards/presentation/cubit/card_cubit.dart';
import 'package:document_wallet/features/passwords/presentation/cubit/password_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/constants/app_colors.dart';
import 'core/constants/app_strings.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/storage/hive_storage.dart';
import 'core/services/service_locator.dart';
import 'core/services/notification_service.dart';
import 'core/l10n/app_localizations.dart';

import 'features/authentication/presentation/cubit/auth_cubit.dart';
import 'features/authentication/presentation/cubit/auth_state.dart';
import 'features/authentication/presentation/pages/lock_screen.dart';
import 'features/authentication/presentation/pages/setup_pin_screen.dart';
import 'features/dashboard/presentation/pages/main_shell.dart';
import 'features/document_manager/presentation/cubit/document_cubit.dart';
import 'features/settings/presentation/cubit/settings_cubit.dart';
import 'features/settings/presentation/cubit/settings_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred device orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Set system UI overlay colors
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize offline Hive boxes
  await HiveStorage.init();

  // Initialize service locator (DI)
  await setupLocator();

  // Initialize local notifications
  await sl<NotificationService>().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SettingsCubit>(create: (_) => sl<SettingsCubit>()),
        BlocProvider<AuthCubit>(
          create: (_) => sl<AuthCubit>()..checkAuthStatus(),
        ),
        BlocProvider<DocumentCubit>(
          create: (_) => sl<DocumentCubit>()..loadAllData(),
        ),
        BlocProvider<PasswordCubit>(
          create: (_) => sl<PasswordCubit>()..loadPasswords(),
        ),
        BlocProvider<CardCubit>(create: (_) => sl<CardCubit>()..loadCards()),
      ],

      child: ScreenUtilInit(
        designSize: const Size(
          390,
          844,
        ), // Standard iPhone/Android base design size
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, settingsState) {
              return MaterialApp(
                title: AppStrings.appName,
                debugShowCheckedModeBanner: false,
                locale: Locale(settingsState.languageCode),
                supportedLocales: const [Locale('en', ''), Locale('ar', '')],
                localizationsDelegates: [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                themeMode: settingsState.isDarkMode
                    ? ThemeMode.dark
                    : ThemeMode.light,
                theme: AppTheme.lightTheme(settingsState.languageCode),

                darkTheme: AppTheme.darkTheme(settingsState.languageCode),

                onGenerateRoute: AppRouter.onGenerateRoute,
                home: const RootGatePage(),
              );
            },
          );
        },
      ),
    );
  }
}

class RootGatePage extends StatelessWidget {
  const RootGatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is AuthInitial || state is AuthLoading) {
          return const Scaffold(
            body: Center(
              child: SpinKitDoubleBounce(color: AppColors.primary, size: 50.0),
            ),
          );
        }

        if (state is AuthSetupRequired) {
          return const SetupPinScreen();
        }

        if (state is AuthLocked) {
          return const LockScreen();
        }

        if (state is AuthSuccess) {
          return const MainShell();
        }

        return const Scaffold(
          body: Center(
            child: Text('Fatal System Error: Unknown Authentication State'),
          ),
        );
      },
    );
  }
}
