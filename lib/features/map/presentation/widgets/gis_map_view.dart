import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_theme.dart';
import '../../platform/maps_loader.dart';

class GisMapView extends StatefulWidget {
  const GisMapView({
    super.key,
    required this.markers,
    required this.mapType,
    required this.onCreated,
  });
  final Set<Marker> markers;
  final MapType mapType;
  final ValueChanged<GoogleMapController> onCreated;

  @override
  State<GisMapView> createState() => _GisMapViewState();
}

class _GisMapViewState extends State<GisMapView> {
  bool _authorizationFailed = false;
  late Future<void> _ready = _load();

  Future<void> _load() => ensureMapsReady(
    AppConfig.mapsApiKey,
    onAuthorizationFailure: () {
      if (mounted) setState(() => _authorizationFailed = true);
    },
  );

  @override
  Widget build(BuildContext context) {
    if (AppConfig.mapsApiKey.isEmpty) {
      return const _MapMessage(
        message:
            'The map is not configured for this build. Contact your administrator.',
      );
    }
    return FutureBuilder<void>(
      future: _ready,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _MapMessage(
            message:
                'The map could not load. Check your connection and try again.',
            onRetry: () => setState(() => _ready = _load()),
          );
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        return Stack(
          children: [
            Positioned.fill(
              child: GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(7.9, 80.7),
                  zoom: 7,
                ),
                markers: widget.markers,
                mapType: widget.mapType,
                onMapCreated: widget.onCreated,
                myLocationButtonEnabled: false,
                mapToolbarEnabled: false,
                zoomControlsEnabled: true,
              ),
            ),
            if (_authorizationFailed)
              const Positioned.fill(
                child: _MapMessage(
                  message:
                      'Google Maps is not available for this app. Contact your administrator.',
                ),
              ),
          ],
        );
      },
    );
  }
}

class _MapMessage extends StatelessWidget {
  const _MapMessage({required this.message, this.onRetry});
  final String message;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) => ColoredBox(
    color: const Color(0xFFE8EEEF),
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.map_outlined, color: AppColors.muted, size: 36),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null)
              TextButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    ),
  );
}
