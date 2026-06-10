import 'package:calclyo/src/core/calculator.dart';
import 'package:calclyo/src/core/categories.dart';
import 'package:calclyo/src/features/search/recents_repository.dart';
import 'package:calclyo/src/features/search/search_cubit.dart';
import 'package:calclyo/src/features/search/search_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Search screen. Wires a [SearchCubit] backed by a [RecentsRepository] that
/// uses [SharedPreferences] for persistence.
///
/// Behavior:
///   - Live filtering as the user types (no submit button).
///   - Results render grouped by category when more than one match exists.
///   - When the box is empty, the recent queries list is shown instead.
///   - Empty state appears when the query is non-empty but yields no matches.
class SearchView extends StatelessWidget {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final cubit = SearchCubit(
          recents: RecentsRepository(preferences: snapshot.data!),
        );
        return BlocProvider<SearchCubit>(
          create: (_) => cubit..loadRecents(),
          child: const _SearchScaffold(),
        );
      },
    );
  }
}

class _SearchScaffold extends StatefulWidget {
  const _SearchScaffold();

  @override
  State<_SearchScaffold> createState() => _SearchScaffoldState();
}

class _SearchScaffoldState extends State<_SearchScaffold> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto-focus the field so the keyboard pops immediately — matches the
    // reference UI which presents the search as the primary affordance.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: BlocConsumer<SearchCubit, SearchState>(
        listenWhen: (prev, next) =>
            prev.errorMessage != next.errorMessage && next.errorMessage != null,
        listener: (context, state) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Unknown error')),
            );
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  textInputAction: TextInputAction.search,
                  onChanged: context.read<SearchCubit>().updateQuery,
                  onSubmitted: (_) =>
                      context.read<SearchCubit>().commitQuery(),
                  decoration: InputDecoration(
                    hintText: 'Search calculators',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _controller.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close),
                            tooltip: 'Clear',
                            onPressed: () {
                              _controller.clear();
                              context.read<SearchCubit>().updateQuery('');
                              setState(() {});
                            },
                          ),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _ResultsBody(
                    state: state,
                    onTapRecent: (entry) {
                      _controller.text = entry;
                      _controller.selection = TextSelection.collapsed(
                        offset: entry.length,
                      );
                      context.read<SearchCubit>().updateQuery(entry);
                      setState(() {});
                    },
                    onRemoveRecent: (entry) =>
                        context.read<SearchCubit>().removeRecent(entry),
                    onTapCalculator: (calc) => context.go(calc.route),
                  ),
                ),
                if (state.status == SearchStatus.loading)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: LinearProgressIndicator(
                      color: theme.colorScheme.primary,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Renders either the recents list, the grouped results, or the empty state.
class _ResultsBody extends StatelessWidget {
  const _ResultsBody({
    required this.state,
    required this.onTapRecent,
    required this.onRemoveRecent,
    required this.onTapCalculator,
  });

  final SearchState state;
  final ValueChanged<String> onTapRecent;
  final ValueChanged<String> onRemoveRecent;
  final ValueChanged<CalculatorDefinition> onTapCalculator;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final query = state.query.trim();

    // No query yet → show recents (or a "no recents" hint on first run).
    if (query.isEmpty) {
      if (state.recentQueries.isEmpty) {
        return Center(
          child: Text(
            'Start typing to find a calculator',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        );
      }
      return _RecentsList(
        recents: state.recentQueries,
        onTapRecent: onTapRecent,
        onRemoveRecent: onRemoveRecent,
      );
    }

    // Query typed but no matches → empty state.
    if (state.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              'No results for "$query"',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return _GroupedResults(groups: state.results, onTap: onTapCalculator);
  }
}

class _RecentsList extends StatelessWidget {
  const _RecentsList({
    required this.recents,
    required this.onTapRecent,
    required this.onRemoveRecent,
  });

  final List<String> recents;
  final ValueChanged<String> onTapRecent;
  final ValueChanged<String> onRemoveRecent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
          child: Text(
            'RECENT SEARCHES',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.secondary,
              letterSpacing: 0.8,
            ),
          ),
        ),
        for (final entry in recents)
          ListTile(
            leading: const Icon(Icons.history),
            title: Text(entry),
            trailing: IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Remove',
              onPressed: () => onRemoveRecent(entry),
            ),
            onTap: () => onTapRecent(entry),
          ),
      ],
    );
  }
}

class _GroupedResults extends StatelessWidget {
  const _GroupedResults({required this.groups, required this.onTap});

  final List<CalculatorCategoryWithCalculators> groups;
  final ValueChanged<CalculatorDefinition> onTap;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: groups.length,
      itemBuilder: (context, i) {
        final group = groups[i];
        return _CategoryGroup(group: group, onTap: onTap);
      },
    );
  }
}

class _CategoryGroup extends StatelessWidget {
  const _CategoryGroup({required this.group, required this.onTap});

  final CalculatorCategoryWithCalculators group;
  final ValueChanged<CalculatorDefinition> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
          child: Text(
            group.category.name.toUpperCase(),
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.secondary,
              letterSpacing: 0.8,
            ),
          ),
        ),
        for (final calc in group.calculators)
          ListTile(
            leading: Icon(calc.icon, color: calc.accent),
            title: Text(calc.name),
            subtitle: Text(calc.subtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => onTap(calc),
            tileColor: theme.colorScheme.surface,
          ),
      ],
    );
  }
}
