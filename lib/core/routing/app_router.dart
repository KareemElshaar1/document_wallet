import 'package:flutter/material.dart';

import '../../features/authentication/presentation/pages/lock_screen.dart';
import '../../features/authentication/presentation/pages/setup_pin_screen.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/document_manager/presentation/pages/add_document_page.dart';
import '../../features/document_viewer/presentation/pages/document_viewer_page.dart';
import '../../features/categories/presentation/pages/category_detail_page.dart';
import '../../features/folders/presentation/pages/folder_detail_page.dart';
import '../../features/search/presentation/pages/search_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';

import '../../features/document_manager/data/models/document_model.dart';
import '../../features/document_manager/data/models/folder_model.dart';

class AppRouter {
  AppRouter._();

  static const String lock = '/lock';
  static const String setupPin = '/setup-pin';
  static const String dashboard = '/dashboard';
  static const String addDocument = '/add-document';
  static const String search = '/search';
  static const String setting = '/settings';
  static const String categoryDetail = '/category-detail';
  static const String folderDetail = '/folder-detail';
  static const String viewer = '/viewer';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case lock:
        return buildPageRoute(settings: settings, child: const LockScreen());
      case setupPin:
        return buildPageRoute(
          settings: settings,
          child: const SetupPinScreen(),
        );
      case dashboard:
        return buildPageRoute(settings: settings, child: const DashboardPage());
      case addDocument:
        final mode = settings.arguments as AddDocumentLaunchMode? ??
            AddDocumentLaunchMode.none;
        return buildPageRoute(
          settings: settings,
          child: AddDocumentPage(launchMode: mode),
        );
      case search:
        return buildPageRoute(settings: settings, child: const SearchPage());
      case setting:
        return buildPageRoute(settings: settings, child: const SettingsPage());
      case categoryDetail:
        final categoryName = settings.arguments as String;
        return buildPageRoute(
          settings: settings,
          child: CategoryDetailPage(categoryName: categoryName),
        );
      case folderDetail:
        final folder = settings.arguments as FolderModel;
        return buildPageRoute(
          settings: settings,
          child: FolderDetailPage(folder: folder),
        );
      case viewer:
        final doc = settings.arguments as DocumentModel;
        return buildPageRoute(
          settings: settings,
          child: DocumentViewerPage(document: doc),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }

  // Slide transition for modern feel
  static PageRouteBuilder<T> buildPageRoute<T>({
    required Widget child,
    required RouteSettings settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 0.08); // Slight slide-up
        const end = Offset.zero;
        const curve = Curves.easeOutQuint;

        var slideTween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));
        var fadeTween = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(slideTween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }
}
