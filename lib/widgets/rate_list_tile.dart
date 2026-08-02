import 'package:flutter/material.dart';
import 'package:rategold/l10n/l10n_extensions.dart';
import 'package:rategold/models/currency_rate.dart';
import 'package:rategold/theme/app_colors.dart';
import 'package:rategold/theme/app_theme.dart';

class RateListTile extends StatelessWidget {
  const RateListTile({
    super.key,
    required this.rate,
    this.onTap,
    this.showDivider = true,
  });

  final CurrencyRate rate;
  final VoidCallback? onTap;
  final bool showDivider;

  static const height = 72.0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final displayName = l10n.currencyName(rate.code);

    return Column(
      children: [
        Semantics(
          button: onTap != null,
          label: '1 US dollar equals ${rate.rateDisplay} $displayName',
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: SizedBox(
                height: 72,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          rate.code,
                          style: AppTheme.currencyCode(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          displayName,
                          style: Theme.of(context).textTheme.bodyLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        rate.rateDisplay,
                        style: AppTheme.monoPrice(
                          size: 18,
                          color: AppColors.onSurface,
                        ),
                      ),
                      if (onTap != null) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.chevron_right,
                          color: AppColors.onSurfaceVariant,
                          size: 20,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
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
