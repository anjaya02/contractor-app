import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

@JS('gisMapsReady')
external set _onReady(JSFunction callback);

@JS('gm_authFailure')
external set _onAuthorizationFailure(JSFunction callback);

Future<void>? _loading;

Future<void> ensureMapsReady(
  String apiKey, {
  void Function()? onAuthorizationFailure,
}) {
  _onAuthorizationFailure = (() => onAuthorizationFailure?.call()).toJS;
  return _loading ??= _load(apiKey);
}

Future<void> _load(String apiKey) async {
  final ready = Completer<void>();
  final script = web.HTMLScriptElement()
    ..async = true
    ..defer = true
    ..src = Uri.https('maps.googleapis.com', '/maps/api/js', {
      'key': apiKey,
      'v': 'weekly',
      'loading': 'async',
      'callback': 'gisMapsReady',
    }).toString();
  _onReady = (() {
    if (!ready.isCompleted) ready.complete();
  }).toJS;
  final errors = script.onError.listen((_) {
    if (!ready.isCompleted) {
      ready.completeError(StateError('Map script could not load.'));
    }
  });
  web.document.head!.appendChild(script);
  try {
    await ready.future.timeout(const Duration(seconds: 25));
  } catch (_) {
    script.remove();
    _loading = null;
    rethrow;
  } finally {
    await errors.cancel();
  }
}
