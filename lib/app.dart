import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rategold/l10n/app_language.dart';
import 'package:rategold/router/app_router.dart';
import 'package:rategold/services/board_controller.dart';
import 'package:rategold/services/locale_controller.dart';
import 'package:rategold/services/ops_analytics.dart';
import 'package:rategold/theme/app_theme.dart';

class RateGoldApp extends StatefulWidget {
  const RateGoldApp({
    super.key,
    required this.controller,
    required this.localeController,
    required this.ops,
  });

  final BoardController controller;
  final LocaleController localeController;
  final OpsAnalytics ops;

  @override
  State<RateGoldApp> createState() => _RateGoldAppState();
}

class _RateGoldAppState extends State<RateGoldApp> {
  late final GoRouter _router = createRouter(ops: widget.ops);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: widget.controller),
        ChangeNotifierProvider.value(value: widget.localeController),
        Provider.value(value: widget.ops),
      ],
      child: Consumer<LocaleController>(
        builder: (context, locale, _) {
          widget.ops.setLocale(locale.language.code);
          return MaterialApp.router(
            title: 'RateGold',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            locale: locale.language.locale,
            supportedLocales: AppLanguage.supportedLocales,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
