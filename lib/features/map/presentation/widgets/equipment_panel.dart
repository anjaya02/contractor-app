import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../models/equipment.dart';
import '../view_models/network_map_state.dart';

class EquipmentPanel extends StatelessWidget {
  const EquipmentPanel({
    super.key,
    required this.state,
    required this.onSelect,
    required this.onRetry,
  });
  final NetworkMapState state;
  final ValueChanged<Equipment> onSelect;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final points = state.visiblePoints;
    return ColoredBox(
      color: Colors.white,
      child: CustomScrollView(
        // New results can be shorter than the previous scrolled list.
        key: ValueKey((state.dataset, state.selectedRtom, state.selectedType)),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Equipment',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  if (state.dataset != null)
                    Text(
                      '${points.length} shown',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: Divider()),
          if (state.dataset != null && state.dataset!.skippedRecords > 0)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  '${state.dataset!.skippedRecords} records have missing or invalid coordinates.',
                ),
              ),
            ),
          if (state.isLoading)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: CircularProgressIndicator(
                  semanticsLabel: 'Loading equipment',
                ),
              ),
            )
          else if (state.error != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(state.error!),
                    TextButton(
                      onPressed: onRetry,
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            )
          else if (points.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No equipment matches this plan and filter.'),
              ),
            )
          else
            SliverList.separated(
              itemCount: points.length,
              separatorBuilder: (_, _) => const Divider(),
              itemBuilder: (context, index) => ListTile(
                onTap: () => onSelect(points[index]),
                leading: Icon(
                  points[index].type == 'POLE'
                      ? Icons.cell_tower_outlined
                      : Icons.device_hub_outlined,
                  color: AppColors.teal,
                ),
                title: Text(
                  points[index].location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '${points[index].typeLabel} · ${points[index].rtom}',
                ),
                trailing: const Icon(Icons.chevron_right_rounded, size: 20),
              ),
            ),
        ],
      ),
    );
  }
}

class EquipmentDetails extends StatelessWidget {
  const EquipmentDetails({super.key, required this.equipment});
  final Equipment equipment;

  @override
  Widget build(BuildContext context) {
    final rows = <String, String?>{
      'Type': equipment.typeLabel,
      'RTOM': equipment.rtom,
      'Index': equipment.id,
      'LEA': equipment.lea,
      'Status': equipment.status,
      'Description': equipment.description,
      'Distance': equipment.distance,
      'Occupied': equipment.occupied,
      'Free': equipment.free,
      'Coordinates':
          '${equipment.latitude.toStringAsFixed(6)}, ${equipment.longitude.toStringAsFixed(6)}',
    };
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              equipment.location,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            for (final row in rows.entries)
              if (row.value != null && row.value!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        row.key,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      SelectableText(
                        row.value!,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}
