import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/app_config.dart';
import '../../../core/network/api_exception.dart';

class UserDataApi {
  UserDataApi({
    required http.Client client,
    Uri? baseUrl,
    Duration timeout = AppConfig.requestTimeout,
  }) : _client = client,
       _baseUrl = baseUrl ?? AppConfig.apiBaseUrl,
       _timeout = timeout;

  final http.Client _client;
  final Uri _baseUrl;
  final Duration _timeout;

  Future<Object?> getUserData(String sid) async {
    try {
      final response = await _client
          .post(
            _baseUrl.resolve('getUserData'),
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json; charset=UTF-8',
            },
            // SID stays a string so leading zeroes are not lost.
            body: jsonEncode({'sid': sid, 'appversion': AppConfig.version}),
          )
          .timeout(_timeout);

      if (response.statusCode == 429) {
        throw const ApiException(ApiFailure.rateLimited);
      }
      if (response.statusCode == 404 || response.statusCode >= 500) {
        throw const ApiException(ApiFailure.unavailable);
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw const ApiException(ApiFailure.rejected);
      }

      // A valid JSON response still needs the backend's success/identity checks.
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on TimeoutException {
      throw const ApiException(ApiFailure.timeout);
    } on http.ClientException {
      throw const ApiException(ApiFailure.connection);
    } on FormatException {
      throw const ApiException(ApiFailure.invalidResponse);
    }
  }
}
