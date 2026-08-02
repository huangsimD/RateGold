import 'package:flutter/material.dart';
import 'package:rategold/l10n/l10n_extensions.dart';
import 'package:rategold/models/gold_quote.dart';
import 'package:rategold/theme/app_colors.dart';
import 'package:rategold/theme/app_theme.dart';

class GoldMarketChip extends StatelessWidget {
  const GoldMarketChip({
    super.key,
    required this.quote,
    this.onTap,
  });

  final GoldQuote quote;
  final VoidCallback? onTap;

  static const width = 140.0;
  static const height = 96.0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final unitLabel = l10n.goldUnitLabel(quote.marketCode);

    return Semantics(
      button: onTap != null,
      label: '${quote.marketLabel} gold $unitLabel, ${quote.priceDisplay}',
      child: Material(
        color: AppColors.goldContainer,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: width,
            height: height,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: quote.isStale
                  ? Border.all(color: AppColors.warning, width: 1.5)
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quote.marketLabel,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppColors.onGold,
                            fontSize: 12,
                          ),
                    ),
                    Text(
                      unitLabel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            color: AppColors.onGold.withValues(alpha: 0.75),
                          ),
                    ),
                  ],
                ),
                Text(
                  quote.priceDisplay,
                  style: AppTheme.monoPrice(size: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
