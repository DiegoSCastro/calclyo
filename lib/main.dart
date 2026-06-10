import 'dart:async';

import 'package:calclyo/app/app.dart';
import 'package:calclyo/src/features/history/history_view.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Bootstrap local-only persistence (history, future settings). The
  // call is fire-and-forget on purpose — the form view skips history
  // recording until `HistoryRepositoryProvider.isReady` is true, and
  // the history page only mounts after the user navigates to it.
  unawaited(_bootstrapHistory());
  runApp(const CalclyoApp());
}

Future<void> _bootstrapHistory() async {
  try {
    await HistoryRepositoryProvider.bootstrap();
  } on Object catch (error, stack) {
    // Persistence unavailable — the app keeps working, the user just
    // doesn't get a history list. Don't crash the launch.
    debugPrint('HistoryRepositoryProvider.bootstrap failed: $error');
    debugPrintStack(stackTrace: stack);
  }
}
