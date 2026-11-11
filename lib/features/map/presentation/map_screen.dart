import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/config/app_config.dart';
import '../data/equipment_repository.dart';
import '../models/equipment.dart';
import 'view_models/network_map_view_model.dart';
import 'view_models/network_map_state.dart';
import 'widgets/map_controls.dart';
import 'widgets/equipment_panel.dart';
import 'widgets/gis_map_view.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (context) =>
        NetworkMapViewModel(repository: context.read<EquipmentRepository>())
          ..loadPlan(AppConfig.initialPlan),
    child: const _MapView(),
  );
}

class _MapView extends StatefulWidget {
  const _MapView();

  @override
  State<_MapView> createState() => _MapViewState();
}

class _MapViewState extends State<_MapView> {
  final _plan = TextEditingController(text: AppConfig.initialPlan);
  GoogleMapController? _map;
  late final NetworkMapViewModel _model;
  late NetworkMapState _previousState;

  @override
  void initState() {
    super.initState();
    _model = context.read<NetworkMapViewModel>();
    _previousState = _model.state;
    _model.addListener(_onMapChanged);
  }

  void _onMapChanged() {
    final current = _model.state;
    final pointsChanged =
        _previousState.dataset != current.dataset ||
        _previousState.selectedRtom != current.selectedRtom ||
        _previousState.selectedType != current.selectedType;
    _previousState = current;
    if (!pointsChanged) return;
    // Update the platform map before fitting the camera to the new selection.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _fitEquipment();
    });
  }

  Future<void> _loadPlan() =>
      context.read<NetworkMapViewModel>().loadPlan(_plan.text);

  Future<void> _moveCamera(CameraUpdate update) async {
    try {
      await _map?.animateCamera(update);
    } catch (_) {
      // A navigation or platform-view disposal can interrupt an animation.
    }
  }

  void _fitEquipment([NetworkMapState? state]) {
    final points =
        (state ?? context.read<NetworkMapViewModel>().state).visiblePoints;
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

  Set<Marker> _markersFor(List<Equipment> points) {
    return {
      for (var index = 0; index < points.length; index++)
        Marker(
          markerId: MarkerId(
            '${points[index].id}-${points[index].rtom}-${points[index].type}-'
            '${points[index].location}-${points[index].latitude}-${points[index].longitude}',
          ),
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
    _model.removeListener(_onMapChanged);
    _plan.dispose();
    // GoogleMap owns and disposes its platform controller.
    _map = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Network map',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.white,
        actions: [
          Selector<NetworkMapViewModel, bool>(
            selector: (_, model) => model.state.visiblePoints.isNotEmpty,
            builder: (context, hasPoints, _) => TextButton(
              onPressed: hasPoints ? () => _fitEquipment() : null,
              child: const Text('Fit points'),
            ),
          ),
        ],
      ),
      body: Selector<NetworkMapViewModel, NetworkMapState>(
        selector: (_, model) => model.state,
        builder: (context, state, _) => LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 900;
            final map = Stack(
              children: [
                Positioned.fill(
                  child: GisMapView(
                    markers: _markersFor(state.visiblePoints),
                    mapType: state.isSatellite
                        ? MapType.hybrid
                        : MapType.normal,
                    onCreated: (map) {
                      if (!mounted) return;
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
                      onPressed: context
                          .read<NetworkMapViewModel>()
                          .toggleSatellite,
                      icon: Icon(
                        !state.isSatellite
                            ? Icons.satellite_alt_outlined
                            : Icons.map_outlined,
                        size: 18,
                      ),
                      label: Text(!state.isSatellite ? 'Satellite' : 'Map'),
                    ),
                  ),
                ),
              ],
            );
            final panel = EquipmentPanel(
              state: state,
              onSelect: _showEquipment,
              onRetry: _loadPlan,
            );
            return Column(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: constraints.maxHeight * 0.43,
                  ),
                  child: SingleChildScrollView(
                    child: MapControls(
                      state: state,
                      planController: _plan,
                      onLoad: _loadPlan,
                      onRtomChanged: context
                          .read<NetworkMapViewModel>()
                          .selectRtom,
                      onTypeChanged: context
                          .read<NetworkMapViewModel>()
                          .selectType,
                    ),
                  ),
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
}
