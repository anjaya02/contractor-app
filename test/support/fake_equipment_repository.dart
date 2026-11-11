import 'package:contractor_app/features/map/data/equipment_repository.dart';
import 'package:contractor_app/features/map/models/equipment.dart';

class FakeEquipmentRepository implements EquipmentRepository {
  final references = <String>[];
  Future<EquipmentDataset> Function(String reference)? onLoad;

  @override
  Future<EquipmentDataset> loadPlan(String planReference) async {
    references.add(planReference);
    if (onLoad case final handler?) return handler(planReference);
    return EquipmentDataset(
      points: const [
        Equipment(
          id: 'test-1',
          location: 'Test pole',
          type: 'POLE',
          rtom: 'R-TEST',
          latitude: 7,
          longitude: 80,
        ),
        Equipment(
          id: 'test-2',
          location: 'Test FDP',
          type: 'FDP',
          rtom: 'R-TEST',
          latitude: 7.01,
          longitude: 80.01,
        ),
      ],
    );
  }
}
