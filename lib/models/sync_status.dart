enum SyncConnectionState { online, offline, syncFailed }

class SyncStatus {
  const SyncStatus({
    required this.connection,
    required this.lastUpdated,
    this.timezoneLabel = 'UTC',
    this.staleAfter = const Duration(hours: 24),
  });

  final SyncConnectionState connection;
  final DateTime lastUpdated;
  final String timezoneLabel;
  final Duration staleAfter;

  bool get isOnline => connection == SyncConnectionState.online;

  bool get isStale =>
      DateTime.now().difference(lastUpdated.toLocal()) >= staleAfter;

  String get statusLabel {
    return switch (connection) {
      SyncConnectionState.online when isStale =>
        'Online · Updated ${_formatDateTime(lastUpdated)} · may be outdated',
      SyncConnectionState.online =>
        'Online · Updated ${_formatTime(lastUpdated)} $timezoneLabel',
      SyncConnectionState.offline =>
        'Offline · Rates as of ${_formatDateTime(lastUpdated)}',
      SyncConnectionState.syncFailed =>
        'Sync failed · Showing saved data',
    };
  }

  static String _formatTime(DateTime dt) {
    final local = dt.toLocal();
    final h = local.hour.toString().padLeft(2, '0');
    final m = local.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  static String _formatDateTime(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final local = dt.toLocal();
    return '${local.day} ${months[local.month - 1]} ${_formatTime(local)}';
  }
}
