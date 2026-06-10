import 'package:calclyo/src/features/history/history_entry.dart';
import 'package:calclyo/src/features/history/history_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

/// State of the history screen.
class HistoryState extends Equatable {
  /// Creates [HistoryState].
  const HistoryState({
    this.entries = const [],
    this.isLoading = false,
    this.error,
  });

  /// Newest first.
  final List<HistoryEntry> entries;

  /// True while [HistoryCubit.refresh] is running.
  final bool isLoading;

  /// Last user-facing error (e.g. failed to read disk). Null on success.
  final String? error;

  /// copyWith.
  HistoryState copyWith({
    List<HistoryEntry>? entries,
    bool? isLoading,
    Object? error = _unset,
  }) {
    return HistoryState(
      entries: entries ?? this.entries,
      isLoading: isLoading ?? this.isLoading,
      error: identical(error, _unset) ? this.error : error as String?,
    );
  }

  static const Object _unset = Object();

  @override
  List<Object?> get props => [entries, isLoading, error];
}

/// Cubit for the History screen. Pure passthrough over [HistoryRepository]
/// so the screen only renders state.
class HistoryCubit extends Cubit<HistoryState> {
  /// Creates a cubit backed by the given repository.
  HistoryCubit(this._repository) : super(const HistoryState());

  final HistoryRepository _repository;

  /// Read the latest list from disk.
  Future<void> refresh() async {
    emit(state.copyWith(isLoading: true, error: null));
    final result = await _repository.load().run();
    result.fold(
      (failure) =>
          emit(state.copyWith(isLoading: false, error: failure.message)),
      (list) =>
          emit(state.copyWith(entries: list, isLoading: false, error: null)),
    );
  }

  /// Record a new successful calculation. Called by the form view on
  /// submit; runs asynchronously and updates [state] with the new list.
  Future<void> record(HistoryEntry entry) async {
    final result = await _repository.add(entry).run();
    result.fold(
      (failure) => emit(state.copyWith(error: failure.message)),
      (list) => emit(state.copyWith(entries: list, error: null)),
    );
  }

  /// Wipe everything. Returns a [TaskEither] so the screen can show a
  /// confirmation flow if it wants to.
  Future<void> clear() async {
    final result = await _repository.clear().run();
    result.fold(
      (failure) => emit(state.copyWith(error: failure.message)),
      (list) => emit(state.copyWith(entries: list, error: null)),
    );
  }

  /// Re-emit `add` as a TaskEither for callers that prefer the typed
  /// monadic flow (e.g. tests).
  TaskEither<HistoryFailure, List<HistoryEntry>> recordTask(
    HistoryEntry entry,
  ) => _repository.add(entry);
}
