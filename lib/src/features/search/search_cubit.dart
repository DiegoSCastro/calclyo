import 'package:calclyo/src/calculator_registry.dart';
import 'package:calclyo/src/core/categories.dart';
import 'package:calclyo/src/features/search/recents_repository.dart';
import 'package:calclyo/src/features/search/search_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Owns search-screen state. Filter logic is pure and lives in
/// [filterCalculators] (testable without the Cubit). The Cubit wires the pure
/// filter to a [RecentsRepository] and emits [SearchState] on every change.
///
/// Lifecycle:
///   - [loadRecents] reads persisted recents on screen open and flips status
///     to [SearchStatus.ready] (or [SearchStatus.failure] with an error).
///   - [updateQuery] recomputes results synchronously — no I/O.
///   - [commitQuery] persists the current query as the most recent entry.
///   - [removeRecent] deletes a single entry.
class SearchCubit extends Cubit<SearchState> {
  SearchCubit({required RecentsRepository recents})
      : _recents = recents,
        super(const SearchState.initial()) {
    // Cache the grouped registry once — `categoriesWithCalculators` rebuilds
    // a map on every call, which we do not need to repeat per keystroke.
    _groups = calculatorRegistry.categoriesWithCalculators;
  }

  final RecentsRepository _recents;
  late final List<CalculatorCategoryWithCalculators> _groups;

  /// Load persisted recents. Idempotent — safe to call more than once.
  Future<void> loadRecents() async {
    if (state.status == SearchStatus.loading) return;
    emit(state.copyWith(status: SearchStatus.loading));
    final result = await _recents.load().run();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: SearchStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (recents) => emit(
        state.copyWith(
          status: SearchStatus.ready,
          recentQueries: recents,
        ),
      ),
    );
  }

  /// Update the search query and recompute the live filtered results.
  ///
  /// Pure (no I/O). The empty-string short-circuit is handled inside
  /// [filterCalculators] so the screen renders recents when the box is empty.
  void updateQuery(String query) {
    final groups = filterCalculators(query: query, groups: _groups);
    emit(state.copyWith(query: query, results: groups));
  }

  /// Persist [state.query] as the most recent entry. No-op if the query is
  /// blank or already the head of the recents list. Re-emits state with the
  /// new recents list on success.
  Future<void> commitQuery() async {
    final q = state.query.trim();
    if (q.isEmpty) return;
    if (state.recentQueries.isNotEmpty &&
        state.recentQueries.first.toLowerCase() == q.toLowerCase()) {
      return;
    }
    final result = await _recents.push(q).run();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: SearchStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (recents) => emit(state.copyWith(recentQueries: recents)),
    );
  }

  /// Remove a single entry from the recents list.
  Future<void> removeRecent(String query) async {
    final result = await _recents.remove(query).run();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: SearchStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (recents) => emit(state.copyWith(recentQueries: recents)),
    );
  }
}
