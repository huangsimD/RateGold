import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rategold/l10n/l10n_extensions.dart';
import 'package:rategold/models/gold_quote.dart';
import 'package:rategold/services/board_controller.dart';
import 'package:rategold/theme/app_colors.dart';
import 'package:rategold/theme/app_theme.dart';
import 'package:rategold/widgets/empty_state_panel.dart';

class GoldMarketsScreen extends StatelessWidget {
  const GoldMarketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Consumer<BoardController>(
      builder: (context, controller, _) {
        final quotes = controller.snapshot.goldQuotes;
        final gold = controller.goldSnapshot;

        return Scaffold(
          appBar: AppBar(title: Text(l10n.goldMarketsTitle)),
          body: quotes.isEmpty
              ? EmptyStatePanel(
                  icon: Icons.diamond_outlined,
                  title: l10n.goldUnavailable,
                  subtitle: l10n.goldUnavailableHint,
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  children: [
                    if (gold != null) ...[
                      Text(
                        l10n.goldSpotUsd(gold.usdPerOz),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.asOfLabel(gold.updatedAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        l10n.goldSourceLabel(gold.source),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 16),
                    ],
                    Text(
                      l10n.goldInrUnitNote,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Material(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(16),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          for (var i = 0; i < quotes.length; i++)
                            _GoldMarketRow(
                              quote: quotes[i],
                              showDivider: i < quotes.length - 1,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.indicativeOnly,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                    ),
                    if (quotes.any((q) => q.isStale)) ...[
                      const SizedBox(height: 8),
                      Text(
                        l10n.staleCaption,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.warning,
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

class _GoldMarketRow extends StatelessWidget {
  const _GoldMarketRow({
    required this.quote,
    required this.showDivider,
  });

  final GoldQuote quote;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final unitLabel = l10n.goldUnitLabel(quote.marketCode);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.goldContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: quote.isStale
                      ? Border.all(color: AppColors.warning, width: 1.5)
                      : null,
                ),
                child: Text(
                  quote.marketCode,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.onGold,
                        fontSize: 11,
                      ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.currencyName(quote.marketCode),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Text(
                      unitLabel,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Text(
                quote.priceDisplay,
                style: AppTheme.monoPrice(size: 18),
              ),
            ],
          ),
        ),
        if (showDivider)
          const Divider(
            height: 1,
            thickness: 1,
            indent: 16,
            endIndent: 16,
            color: AppColors.outline,
          ),
      ],
    );
  }
}
