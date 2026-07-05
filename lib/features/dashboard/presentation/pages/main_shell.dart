import 'package:flutter/material.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../search/presentation/pages/search_page.dart';
import '../../../passwords/presentation/pages/passwords_page.dart';
import '../../../cards/presentation/pages/cards_page.dart';
import 'dashboard_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  // ✅ REMOVED: Do NOT define pages as a const field here.
  // Pages defined outside build() are created before BlocProviders exist.

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final labels = [l10n.dashboard, l10n.search, l10n.passwords, l10n.cards];

    // ✅ Pages defined inside build(), after context has providers available
    final pages = const [
      DashboardPage(),
      SearchPage(),
      PasswordsPage(),
      CardsPage(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        labels: labels,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
