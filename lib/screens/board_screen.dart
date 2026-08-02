import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rategold/l10n/l10n_extensions.dart';
import 'package:rategold/models/gold_quote.dart';
import 'package:rategold/models/sync_status.dart';
import 'package:rategold/services/board_controller.dart';
import 'package:rategold/theme/app_colors.dart';
import 'package:rategold/widgets/board_skeleton.dart';
import 'package:rategold/widgets/empty_state_panel.dart';
import 'package:rategold/widgets/gold_market_chip.dart';
import 'package:rategold/widgets/rate_list_tile.dart';
import 'package:rategold/widgets/section_header.dart';
import 'package:rategold/widgets/sync_status_bar.dart';

class BoardScreen extends StatelessWidget {
  const BoardScreen({super.key});

  Future<void> _onRefresh(BuildContext context) async {
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

  void _onGoldTap(BuildContext context, GoldQuote quote) {
    final l10n = context.l10nRead;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.goldTapMessage(
            quote.marketLabel,
            l10n.goldUnitLabel(quote.marketCode),
            quote.priceDisplay,
          ),
        ),
      ),
    );
  }

  void _onRateTap(BuildContext context, String code) {
    context.go('/convert?from=$code');
  }

  bool _showStatusBar(BoardController controller, SyncStatus status) {
    if (status.connection == SyncConnectionState.syncFailed) {
      return controller.showSyncFailureBanner;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Consumer<BoardController>(
      builder: (context, controller, _) {
        final data = controller.snapshot;
        final isRefreshing = data.isLoading;
        final showInitialSync =
            !controller.isReady && data.rates.isEmpty && data.goldQuotes.isEmpty;
        final showSkeleton = data.isLoading && data.rates.isEmpty && !showInitialSync;

        if (showInitialSync) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.appTitle)),
            body: BoardFirstSyncView(l10n: l10n),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.appTitle),
            actions: [
              IconButton(
                icon: isRefreshing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh_rounded),
                tooltip: l10n.syncNow,
                onPressed: isRefreshing ? null : () => _onRefresh(context),
              ),
            ],
          ),
          body: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => _onRefresh(context),
            child: showSkeleton
                ? BoardSkeleton(baseCurrency: data.baseCurrency, l10n: l10n)
                : ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    children: [
                      if (_showStatusBar(controller, data.syncStatus))
                        SyncStatusBar(
                          status: data.syncStatus,
                          statusLabel: l10n.syncStatusLabel(data.syncStatus),
                          showDismiss: data.syncStatus.connection ==
                              SyncConnectionState.syncFailed,
                          onDismiss: controller.dismissSyncFailureBanner,
                        ),
                      if (_showStatusBar(controller, data.syncStatus))
                        const SizedBox(height: 24),
                      SectionHeader(
                        title: l10n.goldToday,
                        trailingLabel: l10n.seeAll,
                        onTrailingTap: () => context.push('/gold'),
                      ),
                      if (data.goldQuotes.isEmpty)
                        EmptyStatePanel(
                          icon: Icons.diamond_outlined,
                          title: l10n.goldUnavailable,
                          subtitle: l10n.goldUnavailableHint,
                        )
                      else ...[
                        SizedBox(
                          height: GoldMarketChip.height,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: data.goldQuotes.length,
                            separatorBuilder: (_, _) => const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final quote = data.goldQuotes[index];
                              return GoldMarketChip(
                                quote: quote,
                                onTap: () => _onGoldTap(context, quote),
                              );
                            },
                          ),
                        ),
                        if (data.goldQuotes.any((q) => q.isStale))
                          StaleCaption(message: l10n.staleCaption),
                      ],
                      const SizedBox(height: 24),
                      SectionHeader(title: l10n.myRates(data.baseCurrency)),
                      if (data.rates.isEmpty)
                        EmptyStatePanel(
                          icon: Icons.currency_exchange_outlined,
                          title: l10n.emptyFavoritesTitle,
                          subtitle: l10n.emptyFavoritesHint,
                          action: OutlinedButton.icon(
                            onPressed: () =>
                                context.push('/settings/favorites'),
                            icon: const Icon(Icons.add, size: 20),
                            label: Text(l10n.addCurrency),
                          ),
                        )
                      else ...[
                        if (data.syncStatus.isStale)
                          StaleCaption(message: l10n.ratesStaleCaption),
                        Material(
                          color: AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(16),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            children: [
                              for (var i = 0; i < data.rates.length; i++)
                                RateListTile(
                                  rate: data.rates[i],
                                  showDivider: i < data.rates.length - 1,
                                  onTap: () =>
                                      _onRateTap(context, data.rates[i].code),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        OutlinedButton.icon(
                          onPressed: () => context.push('/settings/favorites'),
                          icon: const Icon(Icons.add, size: 20),
                          label: Text(l10n.addCurrency),
                        ),
                      ],
                    ],
                  ),
          ),
        );
      },
    );
  }
}
