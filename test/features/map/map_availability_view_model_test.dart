import 'dart:async';

import 'package:contractor_app/features/map/presentation/view_models/map_availability_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('does not load the SDK without a configured key', () async {
    var calls = 0;
    final model = MapAvailabilityViewModel(
      apiKey: '',
      loader: (_, {onAuthorizationFailure}) async {
        calls++;
      },
    );
    addTearDown(model.dispose);
    await model.load();
    expect(model.state, MapAvailability.missingKey);
    expect(calls, 0);
  });

  test('allows retry after SDK loading fails', () async {
    var calls = 0;
    final model = MapAvailabilityViewModel(
      apiKey: '<test-key>',
      loader: (_, {onAuthorizationFailure}) async {
        if (++calls == 1) throw StateError('Test failure');
      },
    );
    addTearDown(model.dispose);
    await model.load();
    expect(model.state, MapAvailability.loadFailure);
    await model.load();
    expect(model.state, MapAvailability.ready);
  });

  test(
    'does not overwrite an authorization failure with SDK readiness',
    () async {
      final model = MapAvailabilityViewModel(
        apiKey: '<test-key>',
        loader: (_, {onAuthorizationFailure}) async {
          onAuthorizationFailure?.call();
        },
      );
      addTearDown(model.dispose);
      await model.load();
      expect(model.state, MapAvailability.unauthorized);
    },
  );

  test('handles an authorization callback after SDK readiness', () async {
    late void Function() authorizationFailure;
    final model = MapAvailabilityViewModel(
      apiKey: '<test-key>',
      loader: (_, {onAuthorizationFailure}) async {
        authorizationFailure = onAuthorizationFailure!;
      },
    );
    addTearDown(model.dispose);
    await model.load();
    authorizationFailure();
    expect(model.state, MapAvailability.unauthorized);
  });

  test(
    'blocks duplicate loads and ignores completion after disposal',
    () async {
      final pending = Completer<void>();
      var calls = 0;
      late void Function() authorizationFailure;
      final model = MapAvailabilityViewModel(
        apiKey: '<test-key>',
        loader: (_, {onAuthorizationFailure}) {
          calls++;
          authorizationFailure = onAuthorizationFailure!;
          return pending.future;
        },
      );
      final request = model.load();
      await model.load();
      expect(calls, 1);
      model.dispose();
      authorizationFailure();
      pending.complete();
      await request;
      expect(model.state, MapAvailability.loading);
    },
  );
}
