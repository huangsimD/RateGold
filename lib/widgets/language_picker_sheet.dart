import 'package:flutter/material.dart';
import 'package:rategold/l10n/app_language.dart';
import 'package:rategold/l10n/app_strings.dart';
import 'package:rategold/l10n/l10n_extensions.dart';
import 'package:rategold/theme/app_colors.dart';

Future<AppLanguage?> showLanguagePickerSheet(
  BuildContext context, {
  required AppLanguage currentLanguage,
}) {
  final l10n = context.l10nRead;
  return showModalBottomSheet<AppLanguage>(
    context: context,
    useSafeArea: true,
    builder: (context) => _LanguagePickerSheet(
      l10n: l10n,
      currentLanguage: currentLanguage,
    ),
  );
}

class _LanguagePickerSheet extends StatelessWidget {
  const _LanguagePickerSheet({
    required this.l10n,
    required this.currentLanguage,
  });

  final AppStrings l10n;
  final AppLanguage currentLanguage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.languageSetting, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          for (final lang in AppLanguage.values)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(lang.displayName),
              trailing: lang == currentLanguage
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () => Navigator.pop(context, lang),
            ),
        ],
      ),
    );
  }
}
