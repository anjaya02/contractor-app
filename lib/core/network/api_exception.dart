enum ApiFailure {
  connection,
  timeout,
  rejected,
  unavailable,
  rateLimited,
  invalidResponse,
}

class ApiException implements Exception {
  const ApiException(this.failure);

  final ApiFailure failure;

  String get message => switch (failure) {
    ApiFailure.connection =>
      'Could not connect. Check your internet connection and try again.',
    ApiFailure.timeout => 'The connection took too long. Please try again.',
    ApiFailure.rejected =>
      'We could not verify your service ID. Check your details or contact your administrator.',
    ApiFailure.unavailable =>
      'Sign-in is temporarily unavailable. Please try again later.',
    ApiFailure.rateLimited =>
      'Too many attempts. Please wait a moment before trying again.',
    ApiFailure.invalidResponse =>
      'We could not verify your account. Please contact your administrator.',
  };
}
