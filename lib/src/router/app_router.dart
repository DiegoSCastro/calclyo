import 'package:calclyo/src/calculator_registry.dart';
import 'package:calclyo/src/calculators/form_view.dart';
import 'package:calclyo/src/shell/app_shell.dart';
import 'package:calclyo/src/shell/view/achievements_view.dart';
import 'package:calclyo/src/shell/view/search_view.dart';
import 'package:calclyo/src/shell/view/settings_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  const AppRouter._();

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
              builder: (context, state) => CalculatorFormView(
                definition: definition,
              ),
            ),
          GoRoute(
            path: 'achievements',
            name: 'achievements',
            builder: (context, state) => const AchievementsView(),
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
