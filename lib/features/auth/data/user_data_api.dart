import 'package:http/http.dart' as http;

import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';

class UserDataApi {
  UserDataApi({
    required http.Client client,
    Uri? baseUrl,
    Duration timeout = AppConfig.requestTimeout,
  }) : _api = ApiClient(client: client, baseUrl: baseUrl, timeout: timeout);

  final ApiClient _api;

  Future<Object?> getUserData(String sid) {
    // SID stays a string so leading zeroes are not lost.
    return _api.post('getUserData', {
      'sid': sid,
      'appversion': AppConfig.version,
    });
  }
}
