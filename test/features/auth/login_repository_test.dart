import 'dart:convert';

import 'package:contractor_app/core/network/api_exception.dart';
import 'package:contractor_app/features/auth/data/login_repository.dart';
import 'package:contractor_app/features/auth/data/user_data_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  // Synthetic values follow the verified API shape, with no real profile data.
  const user = {
    'SID': '001234',
    'NAME': 'Test Contractor',
    'CON_NAME': 'Example Services',
    'USER_ROLE': 'Test Role',
    'RTOM': 'Test RTOM',
  };

  ApiLoginRepository repositoryFor(Object? payload) {
    final client = MockClient(
      (_) async => http.Response(jsonEncode(payload), 201),
    );
    addTearDown(client.close);
    return ApiLoginRepository(api: UserDataApi(client: client));
  }

  Matcher failsWith(ApiFailure failure) => throwsA(
    isA<ApiException>().having((error) => error.failure, 'failure', failure),
  );

  test('maps a successful HTTP 201 response to the account', () async {
    final repository = repositoryFor({
      'error': false,
      'message': 'LOGIN SUCCESS',
      'data': [user],
    });
    final account = await repository.signIn('001234');
    expect(account.sid, '001234');
    expect(account.displayName, 'Test Contractor');
    expect(account.contractorName, 'Example Services');
    expect(account.userRole, 'Test Role');
    expect(account.rtom, 'Test RTOM');
  });

  test('rejects NOT AUTHORIZED even though its HTTP status is 201', () async {
    final repository = repositoryFor({
      'error': true,
      'message': 'NOT AUTHORIZED',
    });
    await expectLater(
      repository.signIn('001234'),
      failsWith(ApiFailure.rejected),
    );
  });

  test(
    'rejects the error flag even if data and a success message are present',
    () async {
      final repository = repositoryFor({
        'error': true,
        'message': 'LOGIN SUCCESS',
        'data': [user],
      });
      await expectLater(
        repository.signIn('001234'),
        failsWith(ApiFailure.rejected),
      );
    },
  );

  final malformedPayloads = <Object?>[
    null,
    [],
    {},
    {'success': true},
    {
      'message': 'LOGIN SUCCESS',
      'data': [user],
    },
    {
      'error': 'false',
      'data': [user],
    },
    {'error': false},
    {'error': false, 'data': []},
    {'error': false, 'data': user},
    {
      'error': false,
      'data': [user, user],
    },
    {
      'error': false,
      'data': [null],
    },
    {
      'error': false,
      'data': [
        {'NAME': 'Test Contractor'},
      ],
    },
    {
      'error': false,
      'data': [
        {...user, 'SID': 1234},
      ],
    },
    {
      'error': false,
      'data': [
        {...user, 'SID': '999999'},
      ],
    },
  ];

  for (var index = 0; index < malformedPayloads.length; index++) {
    test('rejects malformed or mismatched identity response $index', () async {
      await expectLater(
        repositoryFor(malformedPayloads[index]).signIn('001234'),
        failsWith(ApiFailure.invalidResponse),
      );
    });
  }

  test(
    'handles missing optional profile fields without inventing values',
    () async {
      final account = await repositoryFor({
        'error': false,
        'data': [
          {'SID': '001234', 'NAME': '  '},
        ],
      }).signIn('001234');
      expect(account.sid, '001234');
      expect(account.displayName, isNull);
      expect(account.contractorName, isNull);
      expect(account.userRole, isNull);
      expect(account.rtom, isNull);
    },
  );
}
