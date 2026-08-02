import 'package:flutter/material.dart';
import 'package:rategold/app.dart';
import 'package:rategold/services/board_controller.dart';
import 'package:rategold/services/locale_controller.dart';
import 'package:rategold/services/ops_analytics.dart';
import 'package:rategold/services/rates_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final localeController = LocaleController();
  await localeController.initialize();

  final ops = OpsAnalytics();
  await ops.initialize(locale: localeController.language.code);

  final repository = RatesRepository();
  final controller = BoardController(repository);
  await controller.initialize();

  runApp(
    RateGoldApp(
      controller: controller,
      localeController: localeController,
      ops: ops,
    ),
  );
}
