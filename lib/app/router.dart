import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/climb/pages/climb_placeholder_page.dart';
import '../features/collection/pages/collection_placeholder_page.dart';
import '../features/home/pages/home_page.dart';
import '../features/settings/pages/settings_placeholder_page.dart';
import 'app_shell.dart';
import 'app_tab.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppTab.home.path,
    redirect: (context, state) {
      if (state.uri.path == '/') {
        return AppTab.home.path;
      }
      return null;
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) =>
            AppShell(currentPath: state.uri.path, child: child),
        routes: [
          GoRoute(
            path: AppTab.home.path,
            name: AppTab.home.name,
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: AppTab.climb.path,
            name: AppTab.climb.name,
            builder: (context, state) => const ClimbPlaceholderPage(),
          ),
          GoRoute(
            path: AppTab.collection.path,
            name: AppTab.collection.name,
            builder: (context, state) => const CollectionPlaceholderPage(),
          ),
          GoRoute(
            path: AppTab.settings.path,
            name: AppTab.settings.name,
            builder: (context, state) => const SettingsPlaceholderPage(),
          ),
        ],
      ),
    ],
  );
});
