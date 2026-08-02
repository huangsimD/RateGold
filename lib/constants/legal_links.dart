/// Legal URLs and version labels for store compliance.
abstract final class LegalLinks {
  /// Override at release: `--dart-define=PRIVACY_POLICY_URL=https://...`
  static const privacyPolicyUrl = String.fromEnvironment(
    'PRIVACY_POLICY_URL',
    defaultValue: 'https://privacy-two-pi.vercel.app/',
  );

  static const appVersion = '1.0.0';

  /// Bundled HTML for reference / future use. In-app UI: [PrivacyPolicyBody].
  static const privacyPolicyAsset = 'assets/legal/privacy_policy.html';
}
