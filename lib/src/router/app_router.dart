import 'package:calclyo/src/features/category/presentation/view/category_list_view.dart';
import 'package:calclyo/src/features/rule_of_three/presentation/view/rule_of_three_view.dart';
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
        builder: (context, state) => const CategoryListView(),
        routes: [
          GoRoute(
            path: 'rule-of-three',
            name: 'rule-of-three',
            builder: (context, state) => const RuleOfThreeView(),
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
