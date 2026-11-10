import '../../../core/network/api_exception.dart';
import '../models/contractor_account.dart';

ContractorAccount decodeUserData(
  Object? payload, {
  required String requestedSid,
}) {
  if (payload is! Map<String, dynamic>) {
    throw const ApiException(ApiFailure.invalidResponse);
  }

  // This API returns HTTP 201 for both LOGIN SUCCESS and NOT AUTHORIZED.
  // The JSON error flag, not the HTTP status or message, decides the outcome.
  if (payload['error'] == true) {
    throw const ApiException(ApiFailure.rejected);
  }
  final data = payload['data'];
  if (payload['error'] != false || data is! List || data.length != 1) {
    throw const ApiException(ApiFailure.invalidResponse);
  }

  final user = data.single;
  if (user is! Map<String, dynamic> ||
      user['SID'] is! String ||
      user['SID'] != requestedSid) {
    throw const ApiException(ApiFailure.invalidResponse);
  }

  return ContractorAccount(
    sid: user['SID'] as String,
    displayName: _optionalText(user['NAME']),
    contractorName: _optionalText(user['CON_NAME']),
    userRole: _optionalText(user['USER_ROLE']),
    rtom: _optionalText(user['RTOM']),
  );
}

String? _optionalText(Object? value) {
  return value is String && value.trim().isNotEmpty ? value.trim() : null;
}
