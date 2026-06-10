import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:calclyo/src/features/history/history_entry.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Failure emitted by the persistence layer. Messages are user-facing so
/// the cubit can surface them in a snackbar if needed.
class HistoryFailure implements Exception {
  /// Creates [HistoryFailure].
  const HistoryFailure(this.message);

  /// message.
  final String message;

  @override
  String toString() => 'HistoryFailure: $message';
}

/// Persistence boundary for the last 50 calculations.
///
/// Production code uses [SharedPreferencesHistoryRepository]; tests
/// inject a fake. All methods return [TaskEither] so the cubit can
/// treat success / failure uniformly.
abstract class HistoryRepository {
  /// Maximum number of entries kept on disk. Older entries are dropped
  /// when the cap is exceeded.
  static const maxEntries = 50;

  /// Storage key used in [SharedPreferences]. Versioned so a future
  /// schema change can migrate cleanly.
  static const storageKey = 'calclyo.history.v1';

  /// Read the current list, newest first.
  TaskEither<HistoryFailure, List<HistoryEntry>> load();

  /// Prepend [entry] and trim to [maxEntries]. Returns the new list
  /// (newest first) on success.
  TaskEither<HistoryFailure, List<HistoryEntry>> add(HistoryEntry entry);

  /// Wipe everything. Returns an empty list.
  TaskEither<HistoryFailure, List<HistoryEntry>> clear();
}

/// Production [HistoryRepository] backed by [SharedPreferences].
///
/// The whole list is serialised as a single JSON array under
/// [HistoryRepository.storageKey].
/// That's fine for 50 entries (≈ a few KB) and avoids the cost of
/// encoding/decoding each row on every read.
class SharedPreferencesHistoryRepository implements HistoryRepository {
  /// Creates a repository backed by the given preferences store.
  SharedPreferencesHistoryRepository(this._prefs);

  final SharedPreferences _prefs;

  @override
  TaskEither<HistoryFailure, List<HistoryEntry>> load() {
    return TaskEither<HistoryFailure, List<HistoryEntry>>.tryCatch(
      () async {
        final raw = _prefs.getString(HistoryRepository.storageKey);
        if (raw == null || raw.isEmpty) {
          return const <HistoryEntry>[];
        }
        final decoded = jsonDecode(raw);
        if (decoded is! List) {
          throw const HistoryFailure('Stored history is malformed');
        }
        final entries = <HistoryEntry>[];
        for (final item in decoded) {
          final entry = HistoryEntry.tryFromJson(item);
          if (entry != null) entries.add(entry);
        }
        // Defensive cap in case the on-disk list ever exceeds the limit.
        if (entries.length > HistoryRepository.maxEntries) {
          return List<HistoryEntry>.unmodifiable(
            entries.sublist(0, HistoryRepository.maxEntries),
          );
        }
        return List<HistoryEntry>.unmodifiable(entries);
      },
      (error, _) => HistoryFailure(
        error is HistoryFailure ? error.message : 'Failed to load history',
      ),
    );
  }

  @override
  TaskEither<HistoryFailure, List<HistoryEntry>> add(HistoryEntry entry) {
    return load().flatMap((current) {
      return TaskEither<HistoryFailure, List<HistoryEntry>>.tryCatch(
        () async {
          final next = <HistoryEntry>[entry, ...current];
          if (next.length > HistoryRepository.maxEntries) {
            next.removeRange(HistoryRepository.maxEntries, next.length);
          }
          await _writeAll(next);
          return List<HistoryEntry>.unmodifiable(next);
        },
        (error, _) => HistoryFailure(
          error is HistoryFailure ? error.message : 'Failed to save history',
        ),
      );
    });
  }

  @override
  TaskEither<HistoryFailure, List<HistoryEntry>> clear() {
    return TaskEither<HistoryFailure, List<HistoryEntry>>.tryCatch(
      () async {
        await _prefs.remove(HistoryRepository.storageKey);
        return const <HistoryEntry>[];
      },
      (error, _) => HistoryFailure(
        error is HistoryFailure ? error.message : 'Failed to clear history',
      ),
    );
  }

  Future<void> _writeAll(List<HistoryEntry> entries) async {
    final encoded = jsonEncode(entries.map((e) => e.toJson()).toList());
    final ok = await _prefs.setString(HistoryRepository.storageKey, encoded);
    if (!ok) {
      throw const HistoryFailure('Could not write history to disk');
    }
  }
}

/// Tiny id generator for new history entries. Avoids pulling in `uuid`
/// just for this — 32 hex chars are unique enough for a 50-entry cap.
class HistoryIdGenerator {
  /// Creates a generator, optionally seeded with [random].
  HistoryIdGenerator({Random? random}) : _random = random ?? Random();

  final Random _random;

  /// next.
  String next() {
    final values = List<int>.generate(16, (_) => _random.nextInt(256));
    return values.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}
