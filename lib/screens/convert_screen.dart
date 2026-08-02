import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rategold/data/currency_catalog.dart';
import 'package:rategold/l10n/l10n_extensions.dart';
import 'package:rategold/models/sync_status.dart';
import 'package:rategold/services/board_controller.dart';
import 'package:rategold/services/conversion_service.dart';
import 'package:rategold/theme/app_colors.dart';
import 'package:rategold/widgets/currency_picker_sheet.dart';
import 'package:rategold/widgets/empty_state_panel.dart';
import 'package:rategold/widgets/sync_status_bar.dart';

class ConvertScreen extends StatefulWidget {
  const ConvertScreen({super.key});

  @override
  State<ConvertScreen> createState() => _ConvertScreenState();
}

class _ConvertScreenState extends State<ConvertScreen> {
  final _amountController = TextEditingController(text: '500');
  String? _fromCode;
  String? _toCode;
  bool _initializedFromRoute = false;
  String? _inputError;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initializedFromRoute) return;
    _initializedFromRoute = true;

    final params = GoRouterState.of(context).uri.queryParameters;
    final controller = context.read<BoardController>();
    final favorites = controller.snapshot.favoriteCodes;
    final base = controller.snapshot.baseCurrency;
    final profile = controller.regionProfile;

    if (params['amount'] == null && _amountController.text == '500') {
      _amountController.text = profile.defaultConvertAmount
          .round()
          .toString();
    }

    _fromCode = _pickCode(
      params['from'],
      favorites,
      base,
      fallback: profile.convertFrom,
    );
    _toCode = _pickCode(
      params['to'],
      favorites.where((c) => c != _fromCode).toList(),
      base,
      fallback: profile.convertTo,
    );
  }

  String _pickCode(
    String? preferred,
    List<String> favorites,
    String base, {
    required String fallback,
  }) {
    if (preferred != null && preferred.isNotEmpty) return preferred;
    if (favorites.isNotEmpty) return favorites.first;
    return base == fallback ? 'AED' : fallback;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  List<String> _availableCodes(BoardController controller) {
    final snapshot = controller.ratesForConversion ?? controller.ratesSnapshot;
    if (snapshot == null) {
      return [
        controller.snapshot.baseCurrency,
        ...CurrencyCatalog.allCodes,
      ];
    }
    return {
      snapshot.base,
      ...snapshot.rates.keys,
      ...CurrencyCatalog.allCodes,
    }.toList()
      ..sort();
  }

  double? _parseAmount() {
    final text = _amountController.text.trim();
    if (text.isEmpty) return null;
    final value = double.tryParse(text.replaceAll(',', ''));
    if (value == null || value < 0) return null;
    return value;
  }

  void _onAmountChanged() {
    setState(() {
      _inputError = null;
    });
  }

  Future<void> _pickCurrency({required bool isFrom}) async {
    final l10n = context.l10nRead;
    final controller = context.read<BoardController>();
    final codes = _availableCodes(controller);
    final selected = await showCurrencyPickerSheet(
      context,
      codes: codes,
      selectedCode: isFrom ? _fromCode : _toCode,
      title: isFrom ? l10n.fromCurrency : l10n.toCurrency,
    );
    if (selected == null || !mounted) return;
    setState(() {
      if (isFrom) {
        _fromCode = selected;
        if (_toCode == selected) {
          _toCode = codes.firstWhere(
            (c) => c != selected,
            orElse: () => controller.snapshot.baseCurrency,
          );
        }
      } else {
        _toCode = selected;
        if (_fromCode == selected) {
          _fromCode = codes.firstWhere(
            (c) => c != selected,
            orElse: () => controller.snapshot.baseCurrency,
          );
        }
      }
    });
  }

  void _swapCurrencies() {
    setState(() {
      final from = _fromCode;
      _fromCode = _toCode;
      _toCode = from;
    });
  }

  void _setQuickAmount(int value) {
    _amountController.text = value.toString();
    setState(() => _inputError = null);
  }

  Future<void> _copyResult(String text) async {
    final l10n = context.l10nRead;
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.copiedToClipboard),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BoardController>(
      builder: (context, controller, _) {
        final l10n = context.l10n;
        final snapshot = controller.ratesForConversion;
        final from = _fromCode ?? controller.snapshot.baseCurrency;
        final to = _toCode ?? 'PHP';
        final amount = _parseAmount();
        ConversionResult? result;

        if (snapshot != null && amount != null) {
          result = ConversionService.convert(
            snapshot: snapshot,
            amount: amount,
            fromCode: from,
            toCode: to,
          );
        }

        final resultText = result == null
            ? '—'
            : ConversionService.formatAmount(result.result, to);
        final ratesUnavailable = snapshot == null;
        final pairUnavailable =
            !ratesUnavailable && amount != null && result == null;

        return Scaffold(
          appBar: AppBar(title: Text(l10n.convertTitle)),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              if (ratesUnavailable || controller.snapshot.syncStatus.connection !=
                  SyncConnectionState.online)
                SyncStatusBar(
                  status: controller.snapshot.syncStatus,
                  statusLabel: l10n.syncStatusLabel(controller.snapshot.syncStatus),
                ),
              if (ratesUnavailable)
                EmptyStatePanel(
                  icon: Icons.cloud_off_outlined,
                  title: l10n.ratesUnavailable,
                  subtitle: l10n.ratesUnavailableHint,
                )
              else ...[
              Text(l10n.fromLabel, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              _CurrencyAmountRow(
                code: from,
                controller: _amountController,
                readOnly: false,
                onCurrencyTap: () => _pickCurrency(isFrom: true),
                onChanged: _onAmountChanged,
                errorText: _inputError,
              ),
              const SizedBox(height: 12),
              Center(
                child: IconButton.filledTonal(
                  icon: const Icon(Icons.swap_vert_rounded),
                  iconSize: 28,
                  style: IconButton.styleFrom(
                    minimumSize: const Size(48, 48),
                  ),
                  onPressed: _swapCurrencies,
                ),
              ),
              const SizedBox(height: 12),
              Text(l10n.toLabel, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              _CurrencyAmountRow(
                code: to,
                displayValue: resultText,
                readOnly: true,
                onCurrencyTap: () => _pickCurrency(isFrom: false),
              ),
              const SizedBox(height: 16),
              if (result != null) ...[
                Text(
                  ConversionService.formatCrossRate(
                    result.crossRate,
                    from,
                    to,
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.asOfLabel(
                    controller.lastSuccessfulSync ?? snapshot!.fetchedAt,
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ] else if (pairUnavailable) ...[
                Text(
                  l10n.rateUnavailableFor(from, to),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.warning,
                      ),
                ),
              ] else if (amount == null) ...[
                Text(
                  _inputError ?? l10n.enterValidAmount,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.error,
                      ),
                ),
              ],
              const SizedBox(height: 4),
              Text(
                l10n.indicativeOnly,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final value in [100, 500, 1000])
                    FilterChip(
                      label: Text('$value'),
                      selected: _amountController.text == value.toString(),
                      onSelected: (_) => _setQuickAmount(value),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: result == null
                    ? null
                    : () => _copyResult(resultText.replaceAll(',', '')),
                child: SizedBox(
                  width: double.infinity,
                  child: Text(l10n.copyResult, textAlign: TextAlign.center),
                ),
              ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _CurrencyAmountRow extends StatelessWidget {
  const _CurrencyAmountRow({
    required this.code,
    required this.readOnly,
    required this.onCurrencyTap,
    this.controller,
    this.displayValue,
    this.onChanged,
    this.errorText,
  });

  final String code;
  final bool readOnly;
  final VoidCallback onCurrencyTap;
  final TextEditingController? controller;
  final String? displayValue;
  final VoidCallback? onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final monoStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontFamily: 'monospace',
          color: readOnly ? AppColors.gold : AppColors.onSurface,
        );

    return Material(
      color: AppColors.surfaceContainer,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            InkWell(
              onTap: onCurrencyTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      code,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.expand_more, size: 20),
                  ],
                ),
              ),
            ),
            Container(width: 1, height: 32, color: AppColors.outline),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: readOnly
                    ? Align(
                        alignment: Alignment.centerRight,
                        child: Text(displayValue ?? '—', style: monoStyle),
                      )
                    : TextField(
                        controller: controller,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}'),
                          ),
                        ],
                        textAlign: TextAlign.right,
                        style: monoStyle,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '0',
                          errorText: errorText,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (_) => onChanged?.call(),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
