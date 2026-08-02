import 'package:flutter_test/flutter_test.dart';
import 'package:rategold/services/ops_analytics.dart';

void main() {
  test('OpsAnalytics.enabled is false without OPS_BASE_URL define', () {
    expect(OpsAnalytics.enabled, isFalse);
  });

  test('initialize completes as no-op when disabled', () async {
    final ops = OpsAnalytics();
    await ops.initialize(locale: 'en');
    await ops.screenView('board');
    await ops.track('app_open');
  });
}
