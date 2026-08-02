import 'package:flutter/material.dart';
import 'package:rategold/theme/app_colors.dart';

class EmptyStatePanel extends StatelessWidget {
  const EmptyStatePanel({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
      child: Column(
        children: [
          Icon(
            icon,
            size: 48,
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
          if (action != null) ...[
            const SizedBox(height: 16),
            action!,
          ],
        ],
      ),
    );
  }
}

class StaleCaption extends StatelessWidget {
  const StaleCaption({super.key, this.message = 'May be outdated'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(Icons.schedule, size: 14, color: AppColors.warning),
          const SizedBox(width: 4),
          Text(
            message,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.warning,
                  fontSize: 11,
                ),
          ),
        ],
      ),
    );
  }
}
