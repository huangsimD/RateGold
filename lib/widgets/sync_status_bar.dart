import 'package:flutter/material.dart';
import 'package:rategold/models/sync_status.dart';
import 'package:rategold/theme/app_colors.dart';

class SyncStatusBar extends StatelessWidget {
  const SyncStatusBar({
    super.key,
    required this.status,
    required this.statusLabel,
    this.onDismiss,
    this.showDismiss = false,
  });

  final SyncStatus status;
  final String statusLabel;
  final VoidCallback? onDismiss;
  final bool showDismiss;

  @override
  Widget build(BuildContext context) {
    final isOffline = status.connection == SyncConnectionState.offline;
    final isFailed = status.connection == SyncConnectionState.syncFailed;

    final bg = isOffline
        ? AppColors.offlineBannerBg
        : isFailed
            ? AppColors.error.withValues(alpha: 0.08)
            : status.isStale
                ? AppColors.warning.withValues(alpha: 0.1)
                : AppColors.primaryContainer.withValues(alpha: 0.5);

    final dotColor = switch (status.connection) {
      SyncConnectionState.online when status.isStale => AppColors.warning,
      SyncConnectionState.online => AppColors.success,
      SyncConnectionState.offline => AppColors.offlineBannerText,
      SyncConnectionState.syncFailed => AppColors.error,
    };

    final icon = switch (status.connection) {
      SyncConnectionState.online when status.isStale =>
        Icons.schedule_outlined,
      SyncConnectionState.online => null,
      SyncConnectionState.offline => Icons.cloud_off_outlined,
      SyncConnectionState.syncFailed => Icons.warning_amber_rounded,
    };

    return Semantics(
      label: statusLabel,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 40),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: dotColor),
              const SizedBox(width: 8),
            ] else ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                statusLabel,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isOffline
                          ? AppColors.offlineBannerText
                          : AppColors.onSurface,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (showDismiss && onDismiss != null)
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                color: AppColors.onSurfaceVariant,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                tooltip: 'Dismiss',
                onPressed: onDismiss,
              ),
          ],
        ),
      ),
    );
  }
}
