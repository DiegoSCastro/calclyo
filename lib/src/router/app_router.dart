import 'package:calclyo/src/calculator_registry.dart';
import 'package:calclyo/src/calculators/form_view.dart';
import 'package:calclyo/src/features/history/history_view.dart';
import 'package:calclyo/src/shell/app_shell.dart';
import 'package:calclyo/src/shell/view/achievements_view.dart';
import 'package:calclyo/src/shell/view/search_view.dart';
import 'package:calclyo/src/shell/view/settings_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// AppRouter.
class AppRouter {
  const AppRouter._();

  /// Documented member.
  static final config = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const AppShell(),
        routes: [
          for (final definition in calculatorRegistry.all)
            GoRoute(
              path: definition.route.replaceFirst('/', ''),
              name: definition.id,
              builder: (context, state) {
                // History taps pass pre-filled inputs through `extra`. The
                // form view's contract is unchanged when extra is null —
                // fields fall back to the schema's defaultValue.
                final extra = state.extra;
                final initialValues = extra is Map<String, String>
                    ? extra
                    : const <String, String>{};
                return CalculatorFormView(
                  definition: definition,
                  initialValues: initialValues,
                );
              },
            ),
          GoRoute(
            path: 'achievements',
            name: 'achievements',
            builder: (context, state) => const AchievementsView(),
          ),
          GoRoute(
            path: 'history',
            name: 'history',
            builder: (context, state) => const HistoryPage(),
          ),
          GoRoute(
            path: 'search',
            name: 'search',
            builder: (context, state) => const SearchView(),
          ),
          GoRoute(
            path: 'settings',
            name: 'settings',
            builder: (context, state) => const SettingsView(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Not found')),
      body: Center(child: Text('Route ${state.uri} not found')),
    ),
  );
}
