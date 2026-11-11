import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../models/equipment.dart';

abstract class EquipmentRepository {
  Future<EquipmentDataset> loadPlan(String planReference);
}

class ApiEquipmentRepository implements EquipmentRepository {
  ApiEquipmentRepository({required ApiClient api}) : _api = api;
  final ApiClient _api;

  @override
  Future<EquipmentDataset> loadPlan(String planReference) async {
    final payload = await _api.post('getEquipmentView', {
      'plevntno': planReference,
    });
    if (payload is! Map<String, dynamic>) {
      throw const ApiException(ApiFailure.invalidResponse);
    }
    if (payload['error'] == true) throw const ApiException(ApiFailure.rejected);
    final records = payload['data'];
    if (payload['error'] != false || records is! List) {
      throw const ApiException(ApiFailure.invalidResponse);
    }
    final points = <Equipment>[];
    var skipped = 0;
    for (final record in records) {
      final point = record is Map<String, dynamic>
          ? Equipment.tryFromJson(record)
          : null;
      if (point == null) {
        skipped++;
      } else {
        points.add(point);
      }
    }
    return EquipmentDataset(points: points, skippedRecords: skipped);
  }
}
