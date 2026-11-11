import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../data/equipment_repository.dart';
import '../models/equipment.dart';

class NetworkMapController extends ChangeNotifier {
  NetworkMapController({required EquipmentRepository repository})
    : _repository = repository;
  final EquipmentRepository _repository;
  EquipmentDataset? dataset;
  bool isLoading = false;
  String? error;
  String? selectedRtom;
  String? selectedType;
  bool _disposed = false;

  List<String> get rtoms =>
      (dataset?.points.map((point) => point.rtom).toSet().toList() ?? [])
        ..sort();

  List<String> get types =>
      (dataset?.points.map((p) => p.type).toSet().toList() ?? [])..sort();
  List<Equipment> get visiblePoints =>
      dataset?.points
          .where(
            (point) =>
                (selectedRtom == null || point.rtom == selectedRtom) &&
                (selectedType == null || point.type == selectedType),
          )
          .toList() ??
      [];

  Future<void> loadPlan(String reference) async {
    if (isLoading || _disposed) return;
    // Emails can include non-breaking spaces when a plan reference is copied.
    final plan = reference.replaceAll('\u00a0', ' ').trim();
    if (plan.isEmpty) {
      error = 'Enter a plan reference.';
      notifyListeners();
      return;
    }
    isLoading = true;
    error = null;
    dataset = null;
    selectedRtom = null;
    selectedType = null;
    notifyListeners();
    try {
      final loaded = await _repository.loadPlan(plan);
      if (!_disposed) dataset = loaded;
    } on ApiException catch (failure) {
      if (!_disposed) {
        error = switch (failure.failure) {
          ApiFailure.rejected =>
            'This plan could not be loaded. Check the reference and try again.',
          ApiFailure.invalidResponse =>
            'The service returned equipment data we could not read.',
          ApiFailure.unavailable =>
            'Equipment is temporarily unavailable. Please try again later.',
          _ => failure.message,
        };
      }
    } catch (_) {
      if (!_disposed) error = 'Could not load equipment. Please try again.';
    } finally {
      isLoading = false;
      if (!_disposed) notifyListeners();
    }
  }

  void selectRtom(String? area) {
    selectedRtom = area;
    notifyListeners();
  }

  void selectType(String? type) {
    selectedType = type;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
