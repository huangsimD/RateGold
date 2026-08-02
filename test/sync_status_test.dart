import 'package:flutter_test/flutter_test.dart';
import 'package:rategold/models/sync_status.dart';

void main() {
  test('isStale is true when lastUpdated exceeds threshold', () {
    final status = SyncStatus(
      connection: SyncConnectionState.online,
      lastUpdated: DateTime.now().subtract(const Duration(hours: 25)),
    );

    expect(status.isStale, isTrue);
    expect(status.statusLabel, contains('may be outdated'));
  });

  test('offline label includes formatted date', () {
    final status = SyncStatus(
      connection: SyncConnectionState.offline,
      lastUpdated: DateTime(2026, 7, 1, 18, 20),
    );

    expect(status.statusLabel, startsWith('Offline · Rates as of'));
    expect(status.statusLabel, contains('1 Jul'));
  });

  test('sync failed label is fixed copy', () {
    final status = SyncStatus(
      connection: SyncConnectionState.syncFailed,
      lastUpdated: DateTime(2026, 7, 4),
    );

    expect(status.statusLabel, 'Sync failed · Showing saved data');
  });
}
