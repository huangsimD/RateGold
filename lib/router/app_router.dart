import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rategold/l10n/l10n_extensions.dart';
import 'package:rategold/screens/board_screen.dart';
import 'package:rategold/screens/convert_screen.dart';
import 'package:rategold/screens/gold_markets_screen.dart';
import 'package:rategold/screens/manage_favorites_screen.dart';
import 'package:rategold/screens/privacy_policy_screen.dart';
import 'package:rategold/screens/settings_screen.dart';
import 'package:rategold/services/ops_analytics.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

String? screenNameForLocation(String location) {
  if (location.startsWith('/settings/favorites')) return 'favorites';
  if (location.startsWith('/settings/privacy')) return 'privacy';
  if (location.startsWith('/gold')) return 'gold';
  if (location.startsWith('/convert')) return 'convert';
  if (location.startsWith('/settings')) return 'settings';
  if (location == '/' || location.isEmpty) return 'board';
  return null;
}

GoRouter createRouter({OpsAnalytics? ops}) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      final screen = screenNameForLocation(state.uri.path);
      if (screen != null && ops != null) {
        // Fire-and-forget; analytics never blocks navigation.
        ops.screenView(screen);
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/settings/favorites',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ManageFavoritesScreen(),
      ),
      GoRoute(
        path: '/settings/privacy',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: '/gold',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const GoldMarketsScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => _AppShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: BoardScreen(),
            ),
          ),
          GoRoute(
            path: '/convert',
            pageBuilder: (context, state) => NoTransitionPage(
              child: ConvertScreen(key: ValueKey(state.uri.toString())),
            ),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsScreen(),
            ),
          ),
        ],
      ),
    ],
  );
}

class _AppShell extends StatefulWidget {
  const _AppShell({required this.child});

  final Widget child;

  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> {
  int _indexFromLocation(String location) {
    if (location.startsWith('/convert')) return 1;
    if (location.startsWith('/settings')) return 2;
    return 0;
  }

  void _onTap(int index) {
    switch (index) {
      case 0:
        context.go('/');
      case 1:
        context.go('/convert');
      case 2:
        context.go('/settings');
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final index = _indexFromLocation(location);
    final l10n = context.l10n;

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: _onTap,
        destinations: [
          NavigationDestination(
            key: const Key('nav_board'),
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: l10n.tabBoard,
          ),
          NavigationDestination(
            key: const Key('nav_convert'),
            icon: const Icon(Icons.swap_horiz_outlined),
            selectedIcon: const Icon(Icons.swap_horiz),
            label: l10n.tabConvert,
          ),
          NavigationDestination(
            key: const Key('nav_settings'),
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.tabSettings,
          ),
        ],
      ),
    );
  }
}
