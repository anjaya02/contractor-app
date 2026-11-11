class Equipment {
  const Equipment({
    required this.id,
    required this.location,
    required this.type,
    required this.rtom,
    required this.latitude,
    required this.longitude,
    this.description,
    this.distance,
    this.occupied,
    this.free,
    this.lea,
    this.status,
  });

  final String id;
  final String location;
  final String type;
  final String rtom;
  final double latitude;
  final double longitude;
  final String? description;
  final String? distance;
  final String? occupied;
  final String? free;
  final String? lea;
  final String? status;

  String get typeLabel => labelForType(type);

  // Only MH has been defined by the project team; preserve other API codes.
  static String labelForType(String type) =>
      type == 'MH' ? 'MH (Manhole)' : type;

  static Equipment? tryFromJson(Map<String, dynamic> json) {
    final lat = double.tryParse('${json['LATITUDE']}');
    final lng = double.tryParse('${json['LONGITUDE']}');
    if (lat == null ||
        lng == null ||
        !lat.isFinite ||
        !lng.isFinite ||
        lat.abs() > 90 ||
        lng.abs() > 180) {
      return null;
    }

    String? text(String key) {
      final value = json[key];
      return value is String && value.trim().isNotEmpty ? value.trim() : null;
    }

    return Equipment(
      id: text('INDEX') ?? '',
      location: text('LOCATION') ?? 'Unnamed equipment',
      type: text('TYPE') ?? 'Other',
      rtom: text('RTOM') ?? 'Unspecified',
      latitude: lat,
      longitude: lng,
      // The service spells this field DISCRIPTION; keep that detail at the boundary.
      description: text('DISCRIPTION'),
      distance: text('DISTANCE'),
      occupied: text('OCCUPIED'),
      free: text('FREE'),
      lea: text('LEA'),
      status: text('STATUS'),
    );
  }
}

class EquipmentDataset {
  EquipmentDataset({required List<Equipment> points, this.skippedRecords = 0})
    : points = List.unmodifiable(points);

  final List<Equipment> points;
  final int skippedRecords;
}
