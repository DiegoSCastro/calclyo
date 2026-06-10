import 'package:flutter/material.dart';

/// Placeholder for the Achievements screen. Real implementation lands in
/// t_5c46fe43. v0.2 only needs the route to resolve to a visible screen.
class AchievementsView extends StatelessWidget {
  const AchievementsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Achievements')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🏆 Achievements', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Coming soon',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
