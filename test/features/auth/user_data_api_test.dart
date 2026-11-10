import 'dart:async';
import 'dart:convert';

import 'package:contractor_app/core/network/api_exception.dart';
import 'package:contractor_app/features/auth/data/user_data_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  Matcher failsWith(ApiFailure failure) => throwsA(
    isA<ApiException>().having((error) => error.failure, 'failure', failure),
  );

  test(
    'sends the supplied JSON contract and preserves leading zeroes',
    () async {
      final client = MockClient((request) async {
        expect(request.method, 'POST');
        expect(
          request.url.toString(),
          'https://serviceportal.slt.lk/ApiGisCon/public/api/getUserData',
        );
        expect(
          request.headers['content-type'],
          'application/json; charset=UTF-8',
        );
        expect(request.headers['accept'], 'application/json');
        expect(jsonDecode(request.body), {
          'sid': '001234',
          'appversion': '1.0.0',
        });
        return http.Response('{"fixture":"transport-only"}', 200);
      });
      addTearDown(client.close);

      expect(await UserDataApi(client: client).getUserData('001234'), {
        'fixture': 'transport-only',
      });
    },
  );

  for (final entry in {
    400: ApiFailure.rejected,
    401: ApiFailure.rejected,
    403: ApiFailure.rejected,
    404: ApiFailure.unavailable,
    429: ApiFailure.rateLimited,
    500: ApiFailure.unavailable,
    503: ApiFailure.unavailable,
  }.entries) {
    test(
      'handles HTTP ${entry.key} without exposing the response body',
      () async {
        final client = MockClient(
          (_) async => http.Response('private', entry.key),
        );
        addTearDown(client.close);
        await expectLater(
          UserDataApi(client: client).getUserData('001234'),
          failsWith(entry.value),
        );
      },
    );
  }

  for (final body in ['', '<html>Sign in</html>', '{broken']) {
    test('rejects a non-JSON success response: ${body.length} bytes', () async {
      final client = MockClient((_) async => http.Response(body, 200));
      addTearDown(client.close);
      await expectLater(
        UserDataApi(client: client).getUserData('001234'),
        failsWith(ApiFailure.invalidResponse),
      );
    });
  }

  test('reports a connection failure', () async {
    final client = MockClient(
      (_) async => throw http.ClientException('offline'),
    );
    addTearDown(client.close);
    await expectLater(
      UserDataApi(client: client).getUserData('001234'),
      failsWith(ApiFailure.connection),
    );
  });

  test('times out instead of waiting indefinitely', () async {
    final pending = Completer<http.Response>();
    final client = MockClient((_) => pending.future);
    addTearDown(client.close);
    final api = UserDataApi(
      client: client,
      timeout: const Duration(milliseconds: 5),
    );
    await expectLater(api.getUserData('001234'), failsWith(ApiFailure.timeout));
    pending.complete(http.Response('{}', 200));
  });
}
