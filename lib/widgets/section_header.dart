import 'package:flutter/material.dart';
import 'package:rategold/theme/app_colors.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.trailingLabel,
    this.onTrailingTap,
  });

  final String title;
  final String? trailingLabel;
  final VoidCallback? onTrailingTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const Spacer(),
          if (trailingLabel != null)
            TextButton(
              onPressed: onTrailingTap,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(48, 48),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: AppColors.primary,
              ),
              child: Text(
                trailingLabel!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
        ],
      ),
    );
  }
}
