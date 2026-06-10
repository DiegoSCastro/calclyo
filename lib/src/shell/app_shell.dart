import 'package:calclyo/src/calculator_registry.dart';
import 'package:calclyo/src/shell/widgets/avatar_header.dart';
import 'package:calclyo/src/shell/widgets/category_section.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The v0.2 app shell. Owns the home scaffold: app bar with avatar +
/// search + settings, the category list, two FABs, and the ad footer.
///
/// Replaces the v0.1 `CategoryListView`. The router points `/` at this
/// widget directly.
class AppShell extends StatelessWidget {
  const AppShell({super.key});

  /// v0.2: the primary FAB always quick-launches the Rule of Three.
  /// A later task swaps it for a "Recent" sheet.
  static const _quickLaunchRoute = '/rule-of-three';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final groups = calculatorRegistry.categoriesWithCalculators;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: const AvatarHeader(initials: 'D'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search',
            onPressed: () => context.go('/search'),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: groups.length,
              itemBuilder: (context, i) => CategorySection(entry: groups[i]),
            ),
          ),
          const _AdBannerPlaceholder(),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Semantics(
            label: 'Achievements',
            button: true,
            child: FloatingActionButton.small(
              heroTag: 'fab-achievements',
              tooltip: 'Achievements',
              onPressed: () => context.go('/achievements'),
              child: const Icon(Icons.emoji_events),
            ),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'fab-quick-launch',
            tooltip: 'Quick launch',
            onPressed: () => context.go(_quickLaunchRoute),
            child: const Icon(Icons.calculate),
          ),
        ],
      ),
      backgroundColor: theme.colorScheme.surface,
    );
  }
}

/// Stand-in for the AdMob adaptive banner. Real wiring lands in
/// t_0f4443f0 — this exists so the layout reserves the vertical space
/// and downstream widgets don't shift when the real ad loads.
class _AdBannerPlaceholder extends StatelessWidget {
  const _AdBannerPlaceholder();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      height: 50,
      color: theme.colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Text(
        'Ad placeholder — AdMob in t_0f4443f0',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
