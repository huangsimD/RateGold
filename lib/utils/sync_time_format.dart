import 'package:intl/intl.dart';

abstract final class SyncTimeFormat {
  static String lastSyncLabel(DateTime? time) {
    if (time == null) return 'Never';
    final now = DateTime.now();
    final local = time.toLocal();
    if (_isSameDay(local, now)) {
      return 'Today ${DateFormat('HH:mm').format(local)}';
    }
    if (_isSameDay(local, now.subtract(const Duration(days: 1)))) {
      return 'Yesterday ${DateFormat('HH:mm').format(local)}';
    }
    return DateFormat('d MMM yyyy · HH:mm').format(local);
  }

  static String asOfLabel(DateTime? time) {
    if (time == null) return 'Rate unavailable';
    return 'As of ${lastSyncLabel(time)}';
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
