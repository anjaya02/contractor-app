import 'dart:async';

import 'package:contractor_app/core/network/api_exception.dart';
import 'package:contractor_app/features/map/models/equipment.dart';
import 'package:contractor_app/features/map/presentation/network_map_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_equipment_repository.dart';

void main() {
  late FakeEquipmentRepository repository;
  late NetworkMapController controller;
  setUp(() {
    repository = FakeEquipmentRepository();
    controller = NetworkMapController(repository: repository);
  });
  tearDown(() => controller.dispose());

  test(
    'normalises pasted spaces, derives RTOM/type options and filters equipment',
    () async {
      await controller.loadPlan(' Test\u00a0plan ');
      expect(repository.references, ['Test plan']);
      expect(controller.rtoms, ['R-TEST']);
      expect(controller.types, ['FDP', 'POLE']);
      controller.selectRtom('R-TEST');
      controller.selectType('FDP');
      expect(controller.visiblePoints.single.location, 'Test FDP');
      controller.selectRtom('R-OTHER');
      expect(controller.visiblePoints, isEmpty);
    },
  );
  test('does not request an empty plan', () async {
    await controller.loadPlan(' ');
    expect(repository.references, isEmpty);
    expect(controller.error, 'Enter a plan reference.');
  });
  test('does not duplicate a pending load', () async {
    final pending = Completer<EquipmentDataset>();
    repository.onLoad = (_) => pending.future;
    final first = controller.loadPlan('Test');
    await controller.loadPlan('Test');
    expect(repository.references.length, 1);
    pending.complete(EquipmentDataset(points: []));
    await first;
    expect(controller.isLoading, isFalse);
  });
  test('clears old results on failure and supports retry', () async {
    await controller.loadPlan('First');
    repository.onLoad = (_) async =>
        throw const ApiException(ApiFailure.unavailable);
    await controller.loadPlan('Second');
    expect(controller.dataset, isNull);
    expect(controller.error, contains('temporarily unavailable'));
    repository.onLoad = null;
    await controller.loadPlan('Second');
    expect(controller.visiblePoints.length, 2);
    expect(controller.error, isNull);
  });
}
