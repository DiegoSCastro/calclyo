import 'package:calclyo/src/core/calculator.dart';
import 'package:calclyo/src/core/categories.dart';
import 'package:equatable/equatable.dart';

/// Status flag for the search screen.
enum SearchStatus { initial, loading, ready, failure }

/// Immutable state the [SearchCubit] emits.
///
/// - [query] is the current text in the search box (state-only, not persisted).
/// - [recentQueries] is the persisted list of recent searches (newest first,
///   capped at 5).
/// - [results] is the filtered list of calculators grouped by category,
///   computed live from [query].
/// - [status] reflects the lifecycle of the initial recents load.
class SearchState extends Equatable {
  const SearchState({
    required this.status,
    required this.query,
    required this.recentQueries,
    required this.results,
    this.errorMessage,
  });

  const SearchState.initial()
      : status = SearchStatus.initial,
        query = '',
        recentQueries = const [],
        results = const [],
        errorMessage = null;

  final SearchStatus status;
  final String query;
  final List<String> recentQueries;
  final List<CalculatorCategoryWithCalculators> results;
  final String? errorMessage;

  /// True when the user typed a non-empty query and nothing matched.
  bool get isEmpty => query.trim().isNotEmpty && results.isEmpty;

  SearchState copyWith({
    SearchStatus? status,
    String? query,
    List<String>? recentQueries,
    List<CalculatorCategoryWithCalculators>? results,
    String? errorMessage,
  }) {
    return SearchState(
      status: status ?? this.status,
      query: query ?? this.query,
      recentQueries: recentQueries ?? this.recentQueries,
      results: results ?? this.results,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, query, recentQueries, results, errorMessage];
}

/// Pure filter helper. Exposed (not private) so unit tests can exercise the
/// matching rules without spinning up a Cubit.
///
/// Matches [CalculatorDefinition.name] and [CalculatorDefinition.subtitle]
/// case-insensitively. Empty query returns every calculator in registry
/// declaration order, grouped by category.
List<CalculatorCategoryWithCalculators> filterCalculators({
  required String query,
  required List<CalculatorCategoryWithCalculators> groups,
}) {
  final needle = query.trim().toLowerCase();
  if (needle.isEmpty) {
    return const [];
  }
  final filtered = <CalculatorCategoryWithCalculators>[];
  for (final group in groups) {
    final matches = group.calculators.where((calc) {
      return calc.name.toLowerCase().contains(needle) ||
          calc.subtitle.toLowerCase().contains(needle);
    }).toList(growable: false);
    if (matches.isNotEmpty) {
      filtered.add(
        CalculatorCategoryWithCalculators(
          category: group.category,
          calculators: matches,
        ),
      );
    }
  }
  return filtered;
}
