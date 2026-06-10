/// Human-friendly "2 min ago" / "yesterday" formatter. Pure function so
/// the screen and tests can both use it without depending on
/// `package:intl` (which is not in the project).
String formatRelativeTime(DateTime then, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  final diff = reference.difference(then);

  if (diff.isNegative) {
    // Clock skew or future-dated entry — render as "just now".
    return 'just now';
  }

  final seconds = diff.inSeconds;
  if (seconds < 45) {
    return 'just now';
  }
  final minutes = diff.inMinutes;
  if (minutes < 60) {
    return '$minutes min ago';
  }
  final hours = diff.inHours;
  if (hours < 24) {
    return hours == 1 ? '1 hour ago' : '$hours hours ago';
  }
  final days = diff.inDays;
  if (days == 1) {
    return 'yesterday';
  }
  if (days < 7) {
    return '$days days ago';
  }
  if (days < 30) {
    final weeks = (days / 7).floor();
    return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
  }
  if (days < 365) {
    final months = (days / 30).floor();
    return months == 1 ? '1 month ago' : '$months months ago';
  }
  final years = (days / 365).floor();
  return years == 1 ? '1 year ago' : '$years years ago';
}
