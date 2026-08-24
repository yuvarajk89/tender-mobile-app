import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/auth_providers.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/lot/presentation/add_lot_page.dart';
import '../../features/lot/presentation/poc_lot_entry_page.dart';
import '../../features/settings/presentation/settings_page.dart';
import '../../features/tender/presentation/tender_list_page.dart';
import '../../features/tender/presentation/tender_shell_page.dart';

final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// Navigation map (client note #2):
///   Login → Home (pick a tender) → per-tender workspace with bottom tabs
///   (Lots / Capture / Work list / Summary) inside TenderShellPage.
///   Lot entry and Add-lot are full-screen pushes over the tender workspace.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/login',
    redirect: (context, state) {
      final loggedIn = ref.read(authControllerProvider).isAuthenticated;
      final onLogin = state.matchedLocation == '/login';
      if (!loggedIn) return onLogin ? null : '/login';
      if (onLogin) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),

      // Home — the tender picker (a standalone screen, NOT a tab).
      GoRoute(path: '/home', builder: (_, __) => const TenderListPage()),

      GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),

      // Per-tender workspace (its own bottom tabs live inside the shell).
      GoRoute(
        path: '/tender/:tid',
        builder: (_, s) =>
            TenderShellPage(tenderId: s.pathParameters['tid']!),
        routes: [
          GoRoute(
            path: 'lot/:lid',
            builder: (_, s) => PocLotEntryPage(
              tenderId: s.pathParameters['tid']!,
              lotId: s.pathParameters['lid']!,
            ),
          ),
          GoRoute(
            path: 'add-lot',
            builder: (_, s) =>
                AddLotPage(tenderId: s.pathParameters['tid']!),
          ),
        ],
      ),
    ],
  );
});
