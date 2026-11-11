import 'dart:async';

import 'package:contractor_app/core/network/api_exception.dart';
import 'package:contractor_app/features/map/models/equipment.dart';
import 'package:contractor_app/features/map/presentation/view_models/network_map_view_model.dart';
import 'package:contractor_app/features/map/presentation/view_models/network_map_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_equipment_repository.dart';

void main() {
  late FakeEquipmentRepository repository;
  late NetworkMapViewModel model;
  setUp(() {
    repository = FakeEquipmentRepository();
    model = NetworkMapViewModel(repository: repository);
  });
  tearDown(() => model.dispose());

  test(
    'normalises pasted spaces, derives RTOM/type options and filters equipment',
    () async {
      await model.loadPlan(' Test\u00a0plan ');
      expect(repository.references, ['Test plan']);
      expect(model.state.rtoms, ['R-TEST']);
      expect(model.state.types, ['FDP', 'POLE']);
      model.selectRtom('R-TEST');
      model.selectType('FDP');
      expect(model.state.visiblePoints.single.location, 'Test FDP');
      model.selectRtom('R-OTHER');
      expect(model.state.selectedRtom, 'R-TEST');
    },
  );
  test('does not request an empty plan', () async {
    await model.loadPlan(' ');
    expect(repository.references, isEmpty);
    expect(model.state.error, 'Enter a plan reference.');
  });
  test('does not duplicate a pending load', () async {
    final pending = Completer<EquipmentDataset>();
    repository.onLoad = (_) => pending.future;
    final first = model.loadPlan('Test');
    await model.loadPlan('Test');
    expect(repository.references.length, 1);
    pending.complete(EquipmentDataset(points: []));
    await first;
    expect(model.state.isLoading, isFalse);
  });
  test('clears old results on failure and supports retry', () async {
    await model.loadPlan('First');
    repository.onLoad = (_) async =>
        throw const ApiException(ApiFailure.unavailable);
    await model.loadPlan('Second');
    expect(model.state.dataset, isNull);
    expect(model.state.error, contains('temporarily unavailable'));
    repository.onLoad = null;
    await model.loadPlan('Second');
    expect(model.state.visiblePoints.length, 2);
    expect(model.state.error, isNull);
  });

  test('a new plan resets filters while preserving satellite mode', () async {
    await model.loadPlan('First');
    model.selectRtom('R-TEST');
    model.selectType('FDP');
    model.toggleSatellite();
    await model.loadPlan('Second');
    expect(model.state.selectedRtom, isNull);
    expect(model.state.selectedType, isNull);
    expect(model.state.isSatellite, isTrue);
    expect(model.state.visiblePoints.length, 2);
  });

  test(
    'clearing one filter preserves the other and leaves old state unchanged',
    () async {
      await model.loadPlan('Test');
      model.selectRtom('R-TEST');
      model.selectType('FDP');
      final previous = model.state;
      model.selectType(null);
      expect(model.state.selectedRtom, 'R-TEST');
      expect(model.state.selectedType, isNull);
      expect(previous.selectedType, 'FDP');
      expect(previous.visiblePoints.single.type, 'FDP');
      expect(() => previous.visiblePoints.clear(), throwsUnsupportedError);
      expect(() => previous.dataset!.points.clear(), throwsUnsupportedError);
    },
  );

  test('ignores a response after leaving the map', () async {
    final pending = Completer<EquipmentDataset>();
    repository.onLoad = (_) => pending.future;
    final disposable = NetworkMapViewModel(repository: repository);
    final request = disposable.loadPlan('Test');
    disposable.dispose();
    pending.complete(EquipmentDataset(points: []));
    await request;
    expect(disposable.state.dataset, isNull);
  });

  test('rejects filter values not provided by the equipment API', () async {
    await model.loadPlan('Test');
    final previous = model.state;
    model.selectRtom('R-UNKNOWN');
    model.selectType('UNKNOWN');
    expect(model.state, previous);
  });

  test('notifies loading and success in order', () async {
    final statuses = <NetworkMapStatus>[];
    model.addListener(() => statuses.add(model.state.status));
    await model.loadPlan('Test');
    expect(statuses, [NetworkMapStatus.loading, NetworkMapStatus.success]);
  });
}
