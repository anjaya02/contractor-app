import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class ContractorBrand extends StatelessWidget {
  const ContractorBrand({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.navy,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.cable_rounded, color: Colors.white, size: 26),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Contractor', style: Theme.of(context).textTheme.titleLarge),
              Text(
                'SLT · SERVICE OPERATIONS',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
