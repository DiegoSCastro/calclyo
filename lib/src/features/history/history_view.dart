import 'package:calclyo/src/calculator_registry.dart';
import 'package:calclyo/src/core/calculator.dart';
import 'package:calclyo/src/features/history/history_cubit.dart';
import 'package:calclyo/src/features/history/history_entry.dart';
import 'package:calclyo/src/features/history/history_repository.dart';
import 'package:calclyo/src/features/history/relative_time.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lazily-initialised singleton [HistoryRepository]. Production code
/// reads it via [HistoryRepositoryProvider.instance].
class HistoryRepositoryProvider {
  HistoryRepositoryProvider._();

  static HistoryRepository? _instance;

  /// The bootstrapped repository instance.
  static HistoryRepository get instance {
    final existing = _instance;
    if (existing != null) return existing;
    throw StateError(
      'HistoryRepository has not been initialised. Call '
      'HistoryRepositoryProvider.bootstrap() during app startup.',
    );
  }

  /// True when [bootstrap] (or [debugSet]) has installed a repository.
  /// Cheaper than catching the StateError from [instance].
  static bool get isReady => _instance != null;

  /// Initialise from [SharedPreferences]. Call this once during startup
  /// (e.g. in `main` after `WidgetsFlutterBinding.ensureInitialized()`).
  static Future<HistoryRepository> bootstrap() async {
    final existing = _instance;
    if (existing != null) return existing;
    final prefs = await SharedPreferences.getInstance();
    final repo = SharedPreferencesHistoryRepository(prefs);
    _instance = repo;
    return repo;
  }

  /// Test-only override. Lets unit/widget tests inject a fake without
  /// touching [SharedPreferences].
  // ignore: use_setters_to_change_properties
  static void debugSet(HistoryRepository repository) {
    _instance = repository;
  }

  /// Test-only reset.
  static void debugReset() {
    _instance = null;
  }
}

/// The /history page. Renders the [HistoryCubit] over the singleton
/// [HistoryRepository].
class HistoryPage extends StatelessWidget {
  /// Creates [HistoryPage].
  const HistoryPage({super.key});

  /// Helper for tests: build a `HistoryPage` that uses [repository]
  /// directly without touching the singleton.
  static Widget withRepository(HistoryRepository repository) {
    return BlocProvider(
      create: (_) => HistoryCubit(repository)..refresh(),
      child: const HistoryView(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          HistoryCubit(HistoryRepositoryProvider.instance)..refresh(),
      child: const HistoryView(),
    );
  }
}

/// The actual UI. Watches [HistoryCubit] for the list of entries.
class HistoryView extends StatelessWidget {
  /// Creates [HistoryView].
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          BlocBuilder<HistoryCubit, HistoryState>(
            buildWhen: (a, b) => a.entries.length != b.entries.length,
            builder: (context, state) {
              if (state.entries.isEmpty) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(Icons.delete_sweep),
                tooltip: 'Clear history',
                onPressed: () => _confirmClear(context),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<HistoryCubit, HistoryState>(
        builder: (context, state) {
          if (state.error != null) {
            return _ErrorState(message: state.error!);
          }
          if (state.entries.isEmpty) {
            return const _EmptyState();
          }
          return ListView.separated(
            itemCount: state.entries.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final entry = state.entries[i];
              return _HistoryTile(entry: entry);
            },
          );
        },
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context) async {
    final cubit = context.read<HistoryCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear history?'),
        content: const Text(
          'This will permanently remove all of your recent calculations '
          'from this device. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await cubit.clear();
    }
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.entry});

  final HistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final definition = _resolveDefinition(entry.calculatorId);
    final icon = definition?.icon ?? Icons.calculate;
    final name = definition?.name ?? entry.calculatorId;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: (definition?.accent ?? theme.colorScheme.primary)
            .withValues(alpha: 0.15),
        foregroundColor: definition?.accent ?? theme.colorScheme.onSurface,
        child: Icon(icon),
      ),
      title: Text(name),
      subtitle: Text(
        formatRelativeTime(entry.timestamp),
        style: theme.textTheme.bodySmall,
      ),
      trailing: Text(
        entry.result,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: definition?.accent ?? theme.colorScheme.onSurface,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () => _rerun(context, entry, definition),
    );
  }

  CalculatorDefinition? _resolveDefinition(String id) {
    for (final def in calculatorRegistry.all) {
      if (def.id == id) return def;
    }
    return null;
  }

  void _rerun(
    BuildContext context,
    HistoryEntry entry,
    CalculatorDefinition? definition,
  ) {
    if (definition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This calculator is no longer available')),
      );
      return;
    }
    context.go(definition.route, extra: <String, String>{...entry.inputs});
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text('No recent calculations', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Your last 50 calculations will show up here automatically.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            const Text('Could not load history'),
            const SizedBox(height: 4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
