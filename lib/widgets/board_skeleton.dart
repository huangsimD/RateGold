import 'package:flutter/material.dart';
import 'package:rategold/l10n/app_strings.dart';
import 'package:rategold/theme/app_colors.dart';
import 'package:rategold/widgets/gold_market_chip.dart';
import 'package:rategold/widgets/rate_list_tile.dart';
import 'package:rategold/widgets/section_header.dart';
import 'package:rategold/widgets/shimmer.dart';

class BoardSkeleton extends StatelessWidget {
  const BoardSkeleton({
    super.key,
    this.baseCurrency = 'USD',
    required this.l10n,
  });

  final String baseCurrency;
  final AppStrings l10n;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        ShimmerBox(
          width: double.infinity,
          height: 40,
          borderRadius: BorderRadius.circular(12),
        ),
        const SizedBox(height: 24),
        SectionHeader(title: l10n.goldToday),
        const SizedBox(height: 12),
        SizedBox(
          height: GoldMarketChip.height,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, _) => ShimmerBox(
              width: GoldMarketChip.width,
              height: GoldMarketChip.height,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        const SizedBox(height: 24),
        SectionHeader(title: l10n.myRates(baseCurrency)),
        const SizedBox(height: 8),
        Material(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < 4; i++)
                _RateRowSkeleton(showDivider: i < 3),
            ],
          ),
        ),
      ],
    );
  }
}

class _RateRowSkeleton extends StatelessWidget {
  const _RateRowSkeleton({required this.showDivider});

  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: RateListTile.height,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                ShimmerBox(
                  width: 40,
                  height: 40,
                  borderRadius: BorderRadius.circular(20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      ShimmerBox(width: 48, height: 14),
                      SizedBox(height: 6),
                      ShimmerBox(width: 120, height: 12),
                    ],
                  ),
                ),
                const ShimmerBox(width: 64, height: 18),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(height: 1, thickness: 1, color: AppColors.outline),
      ],
    );
  }
}

class BoardFirstSyncView extends StatelessWidget {
  const BoardFirstSyncView({super.key, required this.l10n});

  final AppStrings l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_download_outlined,
              size: 64,
              color: AppColors.primary.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.firstSyncTitle,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const LinearProgressIndicator(),
            const SizedBox(height: 12),
            Text(
              l10n.firstSyncHint,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
