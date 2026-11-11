import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/ui/contractor_brand.dart';
import '../../account/presentation/account_screen.dart';
import '../../auth/models/contractor_account.dart';
import '../../map/data/equipment_repository.dart';
import '../../map/presentation/map_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.account,
    required this.onSignOut,
    required this.equipmentRepository,
  });
  final ContractorAccount account;
  final VoidCallback onSignOut;
  final EquipmentRepository equipmentRepository;

  void _openAccount(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (routeContext) => AccountScreen(
          account: account,
          onSignOut: () {
            Navigator.of(routeContext).pop();
            onSignOut();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Expanded(child: ContractorBrand()),
                      IconButton(
                        onPressed: () => _openAccount(context),
                        tooltip: 'Account',
                        icon: const Icon(Icons.account_circle_outlined),
                      ),
                      IconButton(
                        onPressed: onSignOut,
                        tooltip: 'Sign out',
                        icon: const Icon(Icons.logout_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 56),
                  Text('Your workspace', style: text.headlineLarge),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    account.displayName ?? 'You’re signed in.',
                    style: text.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.section),
                  Text(
                    'FIELD TOOLS',
                    style: text.bodySmall?.copyWith(
                      color: AppColors.teal,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Material(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      key: const ValueKey('openMap'),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              MapScreen(repository: equipmentRepository),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.navy,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.map_outlined,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.lg),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Network map', style: text.titleLarge),
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(
                                    'Open a plan, explore RTOM locations and inspect network equipment.',
                                    style: text.bodyMedium,
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  const Row(
                                    children: [
                                      Text(
                                        'Open map',
                                        style: TextStyle(
                                          color: AppColors.teal,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 18,
                                        color: AppColors.teal,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.section),
                  const Divider(),
                  const SizedBox(height: AppSpacing.md),
                  Text('Service ID ${account.sid}', style: text.bodySmall),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
