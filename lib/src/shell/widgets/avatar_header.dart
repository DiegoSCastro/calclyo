import 'package:flutter/material.dart';

/// Top-left avatar + "Sign in" stub shown in the [AppShell] app bar.
///
/// Real auth lands post-MVP. For v0.2 the widget is visible, sized, and
/// labelled for accessibility, but tapping it is a no-op.
class AvatarHeader extends StatelessWidget {
  const AvatarHeader({
    required this.initials,
    this.onTap,
    super.key,
  });

  /// One or two letters rendered inside the circle.
  final String initials;

  /// Stub callback. Not wired in v0.2.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: 'Sign in',
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: theme.colorScheme.primaryContainer,
                foregroundColor: theme.colorScheme.onPrimaryContainer,
                child: Text(
                  initials,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Sign in',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
