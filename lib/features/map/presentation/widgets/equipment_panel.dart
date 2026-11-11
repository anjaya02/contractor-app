import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../models/equipment.dart';
import '../network_map_controller.dart';

class EquipmentPanel extends StatelessWidget {
  const EquipmentPanel({
    super.key,
    required this.controller,
    required this.onSelect,
    required this.onRetry,
  });
  final NetworkMapController controller;
  final ValueChanged<Equipment> onSelect;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final points = controller.visiblePoints;
    return ColoredBox(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Equipment',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (controller.dataset != null)
                  Text(
                    '${points.length} shown',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
          const Divider(),
          if (controller.dataset != null &&
              controller.dataset!.skippedRecords > 0)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                '${controller.dataset!.skippedRecords} records have missing or invalid coordinates.',
              ),
            ),
          Expanded(
            child: controller.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      semanticsLabel: 'Loading equipment',
                    ),
                  )
                : controller.error != null
                ? SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(controller.error!),
                        TextButton(
                          onPressed: onRetry,
                          child: const Text('Try again'),
                        ),
                      ],
                    ),
                  )
                : points.isEmpty
                ? SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Text('No equipment matches this plan and filter.'),
                  )
                : ListView.separated(
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
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                      ),
                    ),
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
