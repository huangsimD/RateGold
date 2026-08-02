import 'package:flutter/material.dart';
import 'package:rategold/l10n/l10n_extensions.dart';
import 'package:rategold/widgets/privacy_policy_body.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.privacyPolicy)),
      body: const PrivacyPolicyBody(),
    );
  }
}
