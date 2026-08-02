import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rategold/app.dart';
import 'package:rategold/services/board_controller.dart';
import 'package:rategold/services/locale_controller.dart';
import 'package:rategold/services/rates_repository.dart';

/// Optional emulator-only screenshot harness.
///
/// On physical devices (especially Huawei), prefer:
///   flutter install -d <id>
///   powershell -File tool/capture_store_screenshots.ps1 -Device <id>
///
/// `flutter test integration_test/...` reinstalls a test APK every run and
/// often hangs on `takeScreenshot`.

Future<void> main() async {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final localeController = LocaleController();
  await localeController.initialize();

  // Offline + seed cache: stable UI without network sync spinner.
  final repository = RatesRepository(
    networkChecker: () async => false,
    minSyncInterval: Duration.zero,
  );
  final controller = BoardController(repository);
  await controller.initialize();

  group('Store screenshots', () {
    testWidgets('capture board, convert, settings, gold markets', (tester) async {
      await tester.pumpWidget(
        RateGoldApp(
          controller: controller,
          localeController: localeController,
        ),
      );

      for (var i = 0; i < 40; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await binding.convertFlutterSurfaceToImage();

      Future<void> settle() async {
        for (var i = 0; i < 15; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
      }

      Future<void> snap(String name) async {
        await binding.takeScreenshot(name);
      }

      Future<void> tapNav(String key) async {
        await tester.tap(find.byKey(Key(key)));
        await settle();
      }

      await snap('01_board');

      await tapNav('nav_convert');
      await snap('02_convert');

      await tapNav('nav_settings');
      await snap('03_settings');

      await tapNav('nav_board');
      await tester.tap(find.text('See all'));
      await settle();
      await snap('04_gold_markets');
    });
  });
}
