import 'package:calclyo/src/router/app_router.dart';
import 'package:calclyo/src/theme/app_theme.dart';
import 'package:flutter/material.dart';

class CalclyoApp extends StatelessWidget {
  const CalclyoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Calclyo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.config,
    );
  }
}
