import 'package:flutter/foundation.dart';

import '../../models/equipment.dart';

enum NetworkMapStatus { initial, loading, success, failure }

const _unchanged = Object();

@immutable
class NetworkMapState {
  const NetworkMapState({
    this.status = NetworkMapStatus.initial,
    this.planReference = '',
    this.dataset,
    this.error,
    this.selectedRtom,
    this.selectedType,
    this.isSatellite = false,
  });

  final NetworkMapStatus status;
  final String planReference;
  final EquipmentDataset? dataset;
  final String? error;
  final String? selectedRtom;
  final String? selectedType;
  final bool isSatellite;

  bool get isLoading => status == NetworkMapStatus.loading;

  List<String> get rtoms => List.unmodifiable(
    (dataset?.points.map((point) => point.rtom).toSet().toList() ?? [])..sort(),
  );

  List<String> get types => List.unmodifiable(
    (dataset?.points.map((point) => point.type).toSet().toList() ?? [])..sort(),
  );

  List<Equipment> get visiblePoints => List.unmodifiable(
    dataset?.points.where(
          (point) =>
              (selectedRtom == null || point.rtom == selectedRtom) &&
              (selectedType == null || point.type == selectedType),
        ) ??
        const <Equipment>[],
  );

  // Null clears a filter; the sentinel distinguishes that from no change.
  NetworkMapState copyWith({
    Object? selectedRtom = _unchanged,
    Object? selectedType = _unchanged,
    bool? isSatellite,
  }) => NetworkMapState(
    status: status,
    planReference: planReference,
    dataset: dataset,
    error: error,
    selectedRtom: identical(selectedRtom, _unchanged)
        ? this.selectedRtom
        : selectedRtom as String?,
    selectedType: identical(selectedType, _unchanged)
        ? this.selectedType
        : selectedType as String?,
    isSatellite: isSatellite ?? this.isSatellite,
  );
}
