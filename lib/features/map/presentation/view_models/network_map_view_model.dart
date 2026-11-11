import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/equipment_repository.dart';
import 'network_map_state.dart';

class NetworkMapViewModel extends ChangeNotifier {
  NetworkMapViewModel({required EquipmentRepository repository})
    : _repository = repository;

  NetworkMapState _state = const NetworkMapState();
  NetworkMapState get state => _state;
  bool _disposed = false;

  final EquipmentRepository _repository;

  Future<void> loadPlan(String reference) async {
    if (_disposed || state.isLoading) return;
    // Plan references copied from email can contain non-breaking spaces.
    final plan = reference.replaceAll('\u00a0', ' ').trim();
    if (plan.isEmpty) {
      _setState(
        NetworkMapState(
          status: NetworkMapStatus.failure,
          error: 'Enter a plan reference.',
          isSatellite: state.isSatellite,
        ),
      );
      return;
    }

    _setState(
      NetworkMapState(
        status: NetworkMapStatus.loading,
        planReference: plan,
        isSatellite: state.isSatellite,
      ),
    );
    try {
      final dataset = await _repository.loadPlan(plan);
      if (!_disposed) {
        _setState(
          NetworkMapState(
            status: NetworkMapStatus.success,
            planReference: plan,
            dataset: dataset,
            isSatellite: state.isSatellite,
          ),
        );
      }
    } on ApiException catch (failure) {
      if (!_disposed) {
        _fail(plan, switch (failure.failure) {
          ApiFailure.rejected =>
            'This plan could not be loaded. Check the reference and try again.',
          ApiFailure.invalidResponse =>
            'The service returned equipment data we could not read.',
          ApiFailure.unavailable =>
            'Equipment is temporarily unavailable. Please try again later.',
          _ => failure.message,
        });
      }
    } catch (_) {
      if (!_disposed) {
        _fail(plan, 'Could not load equipment. Please try again.');
      }
    }
  }

  void _fail(String plan, String message) => _setState(
    NetworkMapState(
      status: NetworkMapStatus.failure,
      planReference: plan,
      error: message,
      isSatellite: state.isSatellite,
    ),
  );

  void selectRtom(String? rtom) {
    if (_disposed || state.status != NetworkMapStatus.success) return;
    if (rtom == state.selectedRtom ||
        (rtom != null && !state.rtoms.contains(rtom))) {
      return;
    }
    _setState(state.copyWith(selectedRtom: rtom));
  }

  void selectType(String? type) {
    if (_disposed || state.status != NetworkMapStatus.success) return;
    if (type == state.selectedType ||
        (type != null && !state.types.contains(type))) {
      return;
    }
    _setState(state.copyWith(selectedType: type));
  }

  void toggleSatellite() {
    if (!_disposed) _setState(state.copyWith(isSatellite: !state.isSatellite));
  }

  void _setState(NetworkMapState value) {
    _state = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
