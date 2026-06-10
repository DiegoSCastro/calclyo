import 'dart:convert';

import 'package:calclyo/src/core/calculator.dart' show CalculatorFailure;
import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Failure emitted by [RecentsRepository] — kept as a string so the UI can
/// render it verbatim (mirrors the calculator contract's [CalculatorFailure]).
class RecentsFailure implements Exception {
  /// Creates [RecentsFailure].
  const RecentsFailure(this.message);

  /// message.
  final String message;

  @override
  String toString() => 'RecentsFailure: $message';
}

/// Persists the user's recent search queries via [SharedPreferences].
///
/// Storage shape: a JSON list of strings under [_storageKey], newest first,
/// capped at [maxRecents]. The repository is a thin adapter so tests can
/// inject a fake [SharedPreferences] without touching the platform plugin.
class RecentsRepository {
  /// Creates [RecentsRepository].
  const RecentsRepository({required this.preferences, this.maxRecents = 5});

  static const _storageKey = 'search.recents.v1';

  /// preferences.
  final SharedPreferences preferences;

  /// maxRecents.
  final int maxRecents;

  /// Load the persisted recents. Returns an empty list when no entry exists.
  /// Surfaces a [RecentsFailure] if the stored payload is corrupt.
  TaskEither<RecentsFailure, List<String>> load() {
    return TaskEither.tryCatch(() async {
      final raw = preferences.getStringList(_storageKey);
      if (raw == null) return const <String>[];
      // Defensive: SharedPreferences returns a List<String>, but a
      // hand-edited store could contain non-strings. Filter to keep the
      // contract tight.
      return raw.whereType<String>().toList(growable: false);
    }, (e, _) => RecentsFailure('Failed to load recents: $e'));
  }

  /// Persist a new query as the most recent. Trims, dedupes (case-insensitive
  /// match, keeps the new entry's casing), and caps at [maxRecents]. The
  /// returned [TaskEither] resolves with the persisted list (the new state of
  /// recents), so the Cubit can emit it without a second read.
  TaskEither<RecentsFailure, List<String>> push(String query) {
    return TaskEither.tryCatch(() async {
      final trimmed = query.trim();
      if (trimmed.isEmpty) {
        return preferences.getStringList(_storageKey) ?? const <String>[];
      }
      final existing =
          preferences.getStringList(_storageKey) ?? const <String>[];
      final deduped = [
        trimmed,
        ...existing.where(
          (entry) => entry.toLowerCase() != trimmed.toLowerCase(),
        ),
      ].take(maxRecents).toList(growable: false);
      await preferences.setStringList(_storageKey, deduped);
      return deduped;
    }, (e, _) => RecentsFailure('Failed to persist recents: $e'));
  }

  /// Remove a single query from the recents list.
  TaskEither<RecentsFailure, List<String>> remove(String query) {
    return TaskEither.tryCatch(() async {
      final existing =
          preferences.getStringList(_storageKey) ?? const <String>[];
      final remaining = existing
          .where((entry) => entry != query)
          .toList(growable: false);
      await preferences.setStringList(_storageKey, remaining);
      return remaining;
    }, (e, _) => RecentsFailure('Failed to remove recents entry: $e'));
  }

  /// Clear all recents. Useful for tests; not wired to UI in v0.2.
  TaskEither<RecentsFailure, Unit> clear() {
    return TaskEither.tryCatch(() async {
      await preferences.remove(_storageKey);
      return unit;
    }, (e, _) => RecentsFailure('Failed to clear recents: $e'));
  }

  /// Decode a raw JSON list of strings. Re-exported for completeness — the
  /// list-of-strings API above is the supported one.
  static List<String> decodeList(String raw) =>
      (jsonDecode(raw) as List).whereType<String>().toList(growable: false);
}
