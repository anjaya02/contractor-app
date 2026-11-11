import 'package:flutter/material.dart';

import '../../models/equipment.dart';
import '../view_models/network_map_state.dart';

class MapControls extends StatelessWidget {
  const MapControls({
    super.key,
    required this.state,
    required this.planController,
    required this.onLoad,
    required this.onRtomChanged,
    required this.onTypeChanged,
  });

  final NetworkMapState state;
  final TextEditingController planController;
  final VoidCallback onLoad;
  final ValueChanged<String?> onRtomChanged;
  final ValueChanged<String?> onTypeChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: planController,
                  enabled: !state.isLoading,
                  textInputAction: TextInputAction.go,
                  onSubmitted: (_) => onLoad(),
                  decoration: const InputDecoration(
                    labelText: 'Plan reference',
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: state.isLoading ? null : onLoad,
                tooltip: 'Load plan',
                style: IconButton.styleFrom(minimumSize: const Size(52, 52)),
                icon: const Icon(Icons.arrow_forward_rounded),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  key: const ValueKey('rtomFilter'),
                  value: state.selectedRtom ?? '',
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'RTOM',
                    isDense: true,
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: '',
                      child: Text('All RTOMs', overflow: TextOverflow.ellipsis),
                    ),
                    for (final area in state.rtoms)
                      DropdownMenuItem(
                        value: area,
                        child: Text(area, overflow: TextOverflow.ellipsis),
                      ),
                  ],
                  onChanged: state.status == NetworkMapStatus.success
                      ? (value) => onRtomChanged(value == '' ? null : value)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  key: const ValueKey('typeFilter'),
                  value: state.selectedType ?? '',
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Equipment type',
                    isDense: true,
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: '',
                      child: Text('All types', overflow: TextOverflow.ellipsis),
                    ),
                    for (final type in state.types)
                      DropdownMenuItem(
                        value: type,
                        child: Text(
                          Equipment.labelForType(type),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: state.status == NetworkMapStatus.success
                      ? (value) => onTypeChanged(value == '' ? null : value)
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
