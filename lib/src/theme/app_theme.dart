import 'package:flutter/material.dart';

/// AppTheme.
class AppTheme {
  const AppTheme._();

  static const _seed = Color(0xFF6750A4);

  /// Light theme.
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: _seed),
  );

  /// Dark theme.
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.dark,
    ),
  );
}
