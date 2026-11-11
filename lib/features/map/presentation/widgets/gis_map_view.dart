import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_theme.dart';
import '../../platform/maps_loader.dart';
import '../view_models/map_availability_view_model.dart';

class GisMapView extends StatelessWidget {
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
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => MapAvailabilityViewModel(
      apiKey: AppConfig.mapsApiKey,
      loader: ensureMapsReady,
    )..load(),
    child: Selector<MapAvailabilityViewModel, MapAvailability>(
      selector: (_, model) => model.state,
      builder: (context, availability, _) {
        switch (availability) {
          case MapAvailability.missingKey:
            return const _MapMessage(
              message:
                  'The map is not configured for this build. Contact your administrator.',
            );
          case MapAvailability.loadFailure:
            return _MapMessage(
              message:
                  'The map could not load. Check your connection and try again.',
              onRetry: context.read<MapAvailabilityViewModel>().load,
            );
          case MapAvailability.unauthorized:
            return const _MapMessage(
              message:
                  'Google Maps is not available for this app. Contact your administrator.',
            );
          case MapAvailability.loading:
            return const Center(child: CircularProgressIndicator());
          case MapAvailability.ready:
            return GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(7.9, 80.7),
                zoom: 7,
              ),
              markers: markers,
              mapType: mapType,
              onMapCreated: onCreated,
              myLocationButtonEnabled: false,
              mapToolbarEnabled: false,
              zoomControlsEnabled: true,
            );
        }
      },
    ),
  );
}

class _MapMessage extends StatelessWidget {
  const _MapMessage({required this.message, this.onRetry});
  final String message;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) => ColoredBox(
    color: const Color(0xFFE8EEEF),
    child: Center(
      child: SingleChildScrollView(
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
