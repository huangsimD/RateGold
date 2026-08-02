import 'package:flutter/material.dart';
import 'package:rategold/theme/app_colors.dart';

/// In-app privacy policy (mirrors assets/legal/privacy_policy.html).
class PrivacyPolicyBody extends StatelessWidget {
  const PrivacyPolicyBody({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          width: double.infinity,
          color: AppColors.primary,
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'RateGold Privacy Policy',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.onPrimary,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Last updated: 4 July 2026 · Version 1.0',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.onPrimary.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'RateGold is an offline-friendly exchange-rate and gold-price board. '
                'This policy explains what the app handles and what we do not collect.',
                style: theme.textTheme.bodyLarge,
              ),
              _sectionTitle(context, 'Summary'),
              _card(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'No account required',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: AppColors.onGold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _bullet('No registration, login, or user profiles'),
                  _bullet('No advertising or analytics SDKs in v1.0'),
                  _bullet('No sale of personal data'),
                  _bullet('Preferences and cached rates stay on your device'),
                ],
              ),
              _sectionTitle(context, 'Information stored on your device'),
              Text(
                'Saved locally so the app works offline:',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              _bullet('Language preference'),
              _bullet('Base currency and favorite currency list'),
              _bullet('Cached exchange-rate and gold-price snapshots'),
              _bullet('Timestamp of the last successful sync'),
              const SizedBox(height: 8),
              Text(
                'Data stays in private app storage (SharedPreferences and app documents). '
                'We operate no backend for RateGold v1.0.',
                style: theme.textTheme.bodyLarge,
              ),
              _sectionTitle(context, 'Network use & third-party services'),
              Text(
                'When online and you refresh rates, the app may contact:',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              _bullet(
                'Frankfurter API (frankfurter.app) — public FX rates; '
                'requests use currency codes only, not your identity.',
              ),
              _bullet(
                'Google Fonts (fonts.google.com) — Inter font files; '
                'standard connection data may be processed by Google.',
              ),
              const SizedBox(height: 8),
              Text(
                'Gold prices use bundled seed data combined with synced FX rates.',
                style: theme.textTheme.bodyLarge,
              ),
              _sectionTitle(context, 'Information we do not collect'),
              _bullet('Name, email, phone, or government ID'),
              _bullet('Precise location or contacts'),
              _bullet('Photos, files, or messages'),
              _bullet('Payment or bank-account details'),
              _bullet('Advertising identifiers for tracking'),
              _sectionTitle(context, 'Permissions'),
              _bullet('Internet — sync public rates and load fonts'),
              _bullet('Network state — show online / offline status'),
              const SizedBox(height: 8),
              Text(
                'No location, camera, microphone, or contacts access.',
                style: theme.textTheme.bodyLarge,
              ),
              _sectionTitle(context, 'Children'),
              Text(
                'Not directed at children under 13. We do not knowingly collect '
                'personal information from children.',
                style: theme.textTheme.bodyLarge,
              ),
              _sectionTitle(context, 'Data retention & deletion'),
              Text(
                'Clear app storage or uninstall to remove all local data. '
                'Android: Settings → Apps → RateGold → Storage → Clear data.',
                style: theme.textTheme.bodyLarge,
              ),
              _sectionTitle(context, 'Changes'),
              Text(
                'We may update this policy when the app changes. The date at the '
                'top will be revised accordingly.',
                style: theme.textTheme.bodyLarge,
              ),
              _sectionTitle(context, 'Financial disclaimer & data sources'),
              _card(
                children: [
                  Text(
                    'Exchange rates and gold prices are for general information only. '
                    'They are not investment advice, bank quotes, remittance rates, '
                    'or offers to buy or sell gold or currency.',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Always confirm with your bank or jeweller before transacting.',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sources: FX from Frankfurter (ECB reference data). Gold from '
                    'bundled reference data updated at sync time.',
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
              _sectionTitle(context, 'Contact'),
              SelectableText(
                'Questions: daxian2026@gmail.com',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'RateGold · com.rategold.app · Rates & gold. Offline when it matters.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.primary,
              fontSize: 18,
            ),
      ),
    );
  }

  Widget _card({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        border: Border.all(color: AppColors.outline),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  ', style: TextStyle(color: AppColors.onSurface)),
          Expanded(
            child: Text(text, style: const TextStyle(color: AppColors.onSurface)),
          ),
        ],
      ),
    );
  }
}
