import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/ui/contractor_brand.dart';
import '../../auth/models/contractor_account.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({
    super.key,
    required this.account,
    required this.onSignOut,
  });

  final ContractorAccount account;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const ContractorBrand(),
                  const SizedBox(height: AppSpacing.section),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle_outline_rounded,
                          size: 40,
                          color: AppColors.teal,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'You’re signed in.',
                          style: textTheme.headlineMedium,
                        ),
                        if (account.displayName case final name?) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Text(name, style: textTheme.bodyLarge),
                        ],
                        const SizedBox(height: AppSpacing.xl),
                        const Divider(),
                        const SizedBox(height: AppSpacing.lg),
                        Text('Staff ID', style: textTheme.bodyMedium),
                        const SizedBox(height: AppSpacing.xs),
                        SelectableText(
                          account.sid,
                          style: textTheme.titleLarge,
                        ),
                        if (account.contractorName case final name?)
                          _AccountDetail(label: 'Contractor', value: name),
                        if (account.userRole case final role?)
                          _AccountDetail(label: 'Role', value: role),
                        if (account.rtom case final rtom?)
                          _AccountDetail(label: 'RTOM', value: rtom),
                        const SizedBox(height: AppSpacing.xl),
                        FilledButton.icon(
                          onPressed: onSignOut,
                          icon: const Icon(Icons.logout_rounded, size: 19),
                          label: const Text('Sign out'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountDetail extends StatelessWidget {
  const _AccountDetail({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.xs),
          SelectableText(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
