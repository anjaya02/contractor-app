import 'package:flutter/foundation.dart';

typedef MapsLoader =
    Future<void> Function(
      String apiKey, {
      void Function()? onAuthorizationFailure,
    });

enum MapAvailability { loading, ready, missingKey, loadFailure, unauthorized }

class MapAvailabilityViewModel extends ChangeNotifier {
  MapAvailabilityViewModel({required String apiKey, required MapsLoader loader})
    : _apiKey = apiKey,
      _loader = loader;

  MapAvailability _state = MapAvailability.loading;
  MapAvailability get state => _state;
  bool _disposed = false;

  final String _apiKey;
  final MapsLoader _loader;
  bool _loading = false;

  Future<void> load() async {
    if (_disposed || _loading) return;
    if (_apiKey.isEmpty) {
      _setState(MapAvailability.missingKey);
      return;
    }
    _loading = true;
    _setState(MapAvailability.loading);
    try {
      await _loader(
        _apiKey,
        onAuthorizationFailure: () {
          if (!_disposed) _setState(MapAvailability.unauthorized);
        },
      );
      if (!_disposed && state != MapAvailability.unauthorized) {
        _setState(MapAvailability.ready);
      }
    } catch (_) {
      if (!_disposed && state != MapAvailability.unauthorized) {
        _setState(MapAvailability.loadFailure);
      }
    } finally {
      _loading = false;
    }
  }

  void _setState(MapAvailability value) {
    _state = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
