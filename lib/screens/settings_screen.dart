import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rategold/constants/legal_links.dart';
import 'package:rategold/data/currency_catalog.dart';
import 'package:rategold/l10n/l10n_extensions.dart';
import 'package:rategold/services/board_controller.dart';
import 'package:rategold/services/locale_controller.dart';
import 'package:rategold/theme/app_colors.dart';
import 'package:rategold/widgets/currency_picker_sheet.dart';
import 'package:rategold/widgets/language_picker_sheet.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _pickLanguage(BuildContext context) async {
    final localeController = context.read<LocaleController>();
    final selected = await showLanguagePickerSheet(
      context,
      currentLanguage: localeController.language,
    );
    if (selected == null || !context.mounted) return;
    await localeController.setLanguage(selected);
  }

  Future<void> _pickBaseCurrency(BuildContext context) async {
    final l10n = context.l10nRead;
    final controller = context.read<BoardController>();
    final selected = await showCurrencyPickerSheet(
      context,
      codes: CurrencyCatalog.baseCurrencyOptions,
      selectedCode: controller.snapshot.baseCurrency,
      title: l10n.baseCurrency,
    );
    if (selected == null || !context.mounted) return;
    if (selected == controller.snapshot.baseCurrency) return;

    await controller.updateBaseCurrency(selected);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.baseCurrencySet(selected))),
    );
  }

  Future<void> _syncNow(BuildContext context) async {
    final l10n = context.l10nRead;
    final controller = context.read<BoardController>();
    final result = await controller.refresh(force: true);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.syncResultMessage(result)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _showDisclaimer(BuildContext context) async {
    final l10n = context.l10nRead;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        title: Text(
          l10n.disclaimerTitle,
          style: Theme.of(dialogContext).textTheme.titleMedium?.copyWith(
                color: AppColors.onSurface,
              ),
        ),
        content: SingleChildScrollView(
          child: Text(
            l10n.disclaimerBody,
            style: Theme.of(dialogContext).textTheme.bodyLarge?.copyWith(
                  color: AppColors.onSurface,
                  height: 1.5,
                ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              l10n.done,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Consumer<BoardController>(
      builder: (context, controller, _) {
        final data = controller.snapshot;
        final favoriteCount = data.favoriteCodes.length;
        final locale = context.watch<LocaleController>().language;
        final lastSync = l10n.lastSyncLabel(controller.lastSuccessfulSync);

        return Scaffold(
          appBar: AppBar(title: Text(l10n.settingsTitle)),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              Text(l10n.preferences, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              _SettingsGroup(
                children: [
                  _SettingsTile(
                    title: l10n.languageSetting,
                    trailing: locale.displayName,
                    onTap: () => _pickLanguage(context),
                  ),
                  _SettingsTile(
                    title: l10n.baseCurrency,
                    trailing: data.baseCurrency,
                    onTap: () => _pickBaseCurrency(context),
                  ),
                  _SettingsTile(
                    title: l10n.manageFavorites,
                    trailing:
                        '$favoriteCount/${CurrencyCatalog.maxFavorites}',
                    onTap: () => context.push('/settings/favorites'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(l10n.dataSection, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              _SettingsGroup(
                children: [
                  _SettingsTile(
                    title: l10n.syncNow,
                    trailingIcon: Icons.refresh,
                    showChevron: false,
                    enabled: !data.isLoading,
                    onTap: data.isLoading ? null : () => _syncNow(context),
                  ),
                  ListTile(
                    minTileHeight: 56,
                    title: Text(
                      l10n.lastSync,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    subtitle: Text(
                      lastSync,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(l10n.aboutSection, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              _SettingsGroup(
                children: [
                  _SettingsTile(
                    title: l10n.privacyPolicy,
                    onTap: () => context.push('/settings/privacy'),
                  ),
                  _SettingsTile(
                    title: l10n.dataSourcesDisclaimer,
                    onTap: () => _showDisclaimer(context),
                  ),
                  ListTile(
                    minTileHeight: 56,
                    title: Text(
                      l10n.versionLabel(LegalLinks.appVersion),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                l10n.brandSlogan,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainer,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.title,
    this.trailing,
    this.trailingIcon,
    this.onTap,
    this.showChevron = true,
    this.enabled = true,
  });

  final String title;
  final String? trailing;
  final IconData? trailingIcon;
  final VoidCallback? onTap;
  final bool showChevron;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minTileHeight: 56,
      enabled: enabled,
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
      trailing: trailingIcon != null
          ? Icon(trailingIcon, color: AppColors.primary, size: 22)
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (trailing != null)
                  Text(
                    trailing!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                if (showChevron) ...[
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.onSurfaceVariant,
                    size: 20,
                  ),
                ],
              ],
            ),
      onTap: onTap,
    );
  }
}
