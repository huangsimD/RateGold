import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:rategold/l10n/app_strings.dart';
import 'package:rategold/services/locale_controller.dart';

extension L10nContext on BuildContext {
  AppStrings get l10n => watch<LocaleController>().strings;
  AppStrings get l10nRead => read<LocaleController>().strings;
}
