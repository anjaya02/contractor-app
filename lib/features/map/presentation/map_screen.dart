import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/config/app_config.dart';
import '../data/equipment_repository.dart';
import '../models/equipment.dart';
import 'network_map_controller.dart';
import 'widgets/equipment_panel.dart';
import 'widgets/gis_map_view.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key, required this.repository});
  final EquipmentRepository repository;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final _controller = NetworkMapController(repository: widget.repository);
  final _plan = TextEditingController(text: AppConfig.initialPlan);
  GoogleMapController? _map;
  MapType _mapType = MapType.normal;

  @override
  void initState() {
    super.initState();
    _loadPlan();
  }

  Future<void> _loadPlan() async {
    await _controller.loadPlan(_plan.text);
    if (mounted) _fitEquipment();
  }

  Future<void> _moveCamera(CameraUpdate update) async {
    try {
      await _map?.animateCamera(update);
    } catch (_) {
      // A navigation or platform-view disposal can interrupt an animation.
    }
  }

  void _fitEquipment() {
    final points = _controller.visiblePoints;
    if (points.isEmpty || _map == null) return;
    if (points.length == 1) {
      _moveCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(points.first.latitude, points.first.longitude),
          17,
        ),
      );
      return;
    }
    var minLat = points.first.latitude, maxLat = minLat;
    var minLng = points.first.longitude, maxLng = minLng;
    for (final point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }
    if (minLat == maxLat && minLng == maxLng) {
      _moveCamera(CameraUpdate.newLatLngZoom(LatLng(minLat, minLng), 17));
    } else {
      _moveCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(minLat, minLng),
            northeast: LatLng(maxLat, maxLng),
          ),
          48,
        ),
      );
    }
  }

  void _selectRtom(String? area) {
    _controller.selectRtom(area);
    _fitEquipment();
  }

  void _showEquipment(Equipment point) {
    _moveCamera(
      CameraUpdate.newLatLngZoom(LatLng(point.latitude, point.longitude), 18),
    );
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: 640),
      builder: (_) => EquipmentDetails(equipment: point),
    );
  }

  Set<Marker> get _markers {
    final points = _controller.visiblePoints;
    return {
      for (var index = 0; index < points.length; index++)
        Marker(
          markerId: MarkerId('equipment-$index'),
          position: LatLng(points[index].latitude, points[index].longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            points[index].type == 'POLE' ? 210 : 175,
          ),
          infoWindow: InfoWindow(
            title: points[index].location,
            snippet: '${points[index].typeLabel} · ${points[index].rtom}',
          ),
          onTap: () => _showEquipment(points[index]),
        ),
    };
  }

  @override
  void dispose() {
    _controller.dispose();
    _plan.dispose();
    _map?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Network map'),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _fitEquipment,
            icon: const Icon(Icons.fit_screen_rounded),
            tooltip: 'Fit equipment',
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 900;
            final map = Stack(
              children: [
                Positioned.fill(
                  child: GisMapView(
                    markers: _markers,
                    mapType: _mapType,
                    onCreated: (map) {
                      _map = map;
                      _fitEquipment();
                    },
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    child: TextButton.icon(
                      onPressed: () => setState(
                        () => _mapType = _mapType == MapType.normal
                            ? MapType.hybrid
                            : MapType.normal,
                      ),
                      icon: Icon(
                        _mapType == MapType.normal
                            ? Icons.satellite_alt_outlined
                            : Icons.map_outlined,
                        size: 18,
                      ),
                      label: Text(
                        _mapType == MapType.normal ? 'Satellite' : 'Map',
                      ),
                    ),
                  ),
                ),
              ],
            );
            final panel = EquipmentPanel(
              controller: _controller,
              onSelect: _showEquipment,
              onRetry: _loadPlan,
            );
            return Column(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: constraints.maxHeight * 0.43,
                  ),
                  child: SingleChildScrollView(child: _controls()),
                ),
                Expanded(
                  child: wide
                      ? Row(
                          children: [
                            Expanded(child: map),
                            SizedBox(width: 350, child: panel),
                          ],
                        )
                      : Column(
                          children: [
                            Expanded(child: map),
                            SizedBox(
                              height: constraints.maxHeight < 550 ? 160 : 220,
                              child: panel,
                            ),
                          ],
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _controls() {
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
                  controller: _plan,
                  enabled: !_controller.isLoading,
                  textInputAction: TextInputAction.go,
                  onSubmitted: (_) => _loadPlan(),
                  decoration: const InputDecoration(
                    labelText: 'Plan reference',
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _controller.isLoading ? null : _loadPlan,
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
                  value: _controller.selectedRtom ?? '',
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'RTOM',
                    isDense: true,
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: '',
                      child: Text(
                        'All equipment',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    for (final area in _controller.rtoms)
                      DropdownMenuItem(
                        value: area,
                        child: Text(area, overflow: TextOverflow.ellipsis),
                      ),
                  ],
                  onChanged: (value) => _selectRtom(value == '' ? null : value),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _controller.selectedType ?? '',
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
                    for (final type in _controller.types)
                      DropdownMenuItem(
                        value: type,
                        child: Text(
                          Equipment.labelForType(type),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (value) {
                    _controller.selectType(value == '' ? null : value);
                    _fitEquipment();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
