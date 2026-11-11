import 'dart:convert';

import 'package:contractor_app/core/network/api_client.dart';
import 'package:contractor_app/core/network/api_exception.dart';
import 'package:contractor_app/features/map/data/equipment_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  const fixture = {
    'INDEX': 'fixture-1',
    'LOCATION': 'Test point',
    'RTOM': 'R-TEST',
    'TYPE': 'FDP',
    'LATITUDE': '7.001',
    'LONGITUDE': '80.001',
    'DISCRIPTION': 'Test description',
    'OCCUPIED': '2',
    'FREE': '6',
    'LEA': 'Test LEA',
    'STATUS': 'Test status',
    'DISTANCE': '12',
  };

  ApiEquipmentRepository repositoryFor(
    Object? payload, {
    void Function(http.Request)? check,
  }) {
    final client = MockClient((request) async {
      check?.call(request);
      return http.Response(jsonEncode(payload), 200);
    });
    addTearDown(client.close);
    return ApiEquipmentRepository(api: ApiClient(client: client));
  }

  test('posts plan reference and maps the supplied field names', () async {
    final repository = repositoryFor(
      {
        'error': false,
        'data': [fixture],
      },
      check: (request) {
        expect(request.method, 'POST');
        expect(request.url.path, '/ApiGisCon/public/api/getEquipmentView');
        expect(jsonDecode(request.body), {'plevntno': 'Test plan'});
      },
    );
    final data = await repository.loadPlan('Test plan');
    expect(data.points.single.latitude, 7.001);
    expect(data.points.single.longitude, 80.001);
    expect(data.points.single.description, 'Test description');
    expect(data.points.single.free, '6');
    expect(data.skippedRecords, 0);
  });

  for (final coordinate in [
    'NaN',
    'Infinity',
    '',
    'not-a-number',
    '91',
    '-91',
  ]) {
    test(
      'skips invalid latitude $coordinate and reports the skipped count',
      () async {
        final data = await repositoryFor({
          'error': false,
          'data': [
            fixture,
            {...fixture, 'LATITUDE': coordinate},
          ],
        }).loadPlan('Test');
        expect(data.points.length, 1);
        expect(data.skippedRecords, 1);
      },
    );
  }
  test('rejects out-of-range longitude and malformed rows', () async {
    final data = await repositoryFor({
      'error': false,
      'data': [
        {...fixture, 'LONGITUDE': '181'},
        null,
        'invalid',
      ],
    }).loadPlan('Test');
    expect(data.points, isEmpty);
    expect(data.skippedRecords, 3);
  });
  for (final payload in <Object?>[
    null,
    [],
    {},
    {'error': 'false', 'data': []},
    {'error': false, 'data': {}},
  ]) {
    test('rejects malformed equipment envelopes: $payload', () async {
      await expectLater(
        repositoryFor(payload).loadPlan('Test'),
        throwsA(isA<ApiException>()),
      );
    });
  }
  test('rejects service errors even when data exists', () async {
    await expectLater(
      repositoryFor({
        'error': true,
        'data': [fixture],
      }).loadPlan('Test'),
      throwsA(
        isA<ApiException>().having(
          (e) => e.failure,
          'failure',
          ApiFailure.rejected,
        ),
      ),
    );
  });
  test('supports an empty valid plan', () async {
    final data = await repositoryFor({
      'error': false,
      'data': [],
    }).loadPlan('Test');
    expect(data.points, isEmpty);
    expect(data.skippedRecords, 0);
  });
}
