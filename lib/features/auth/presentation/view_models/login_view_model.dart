import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/login_repository.dart';
import '../sid_validator.dart';
import 'login_state.dart';

class LoginViewModel extends ChangeNotifier {
  LoginViewModel({required LoginRepository repository})
    : _repository = repository;

  LoginState _state = const LoginState.initial();
  LoginState get state => _state;
  bool _disposed = false;

  final LoginRepository _repository;
  int _requestId = 0;

  Future<void> signIn(String value) async {
    if (_disposed || state.isSubmitting || state.account != null) return;
    final sid = value.trim();
    final validationError = validateSid(sid);
    if (validationError != null) {
      _setState(LoginState.failure(validationError));
      return;
    }

    final requestId = ++_requestId;
    _setState(const LoginState.submitting());
    try {
      final account = await _repository.signIn(sid);
      if (!_disposed && requestId == _requestId) {
        _setState(LoginState.authenticated(account));
      }
    } on ApiException catch (failure) {
      if (!_disposed && requestId == _requestId) {
        _setState(LoginState.failure(failure.message));
      }
    } catch (_) {
      if (!_disposed && requestId == _requestId) {
        _setState(
          const LoginState.failure('Something went wrong. Please try again.'),
        );
      }
    }
  }

  void clearError() {
    if (!_disposed && state.status == LoginStatus.failure) {
      _setState(const LoginState.initial());
    }
  }

  void signOut() {
    if (_disposed) return;
    // A late login response must not recreate a session after sign-out.
    _requestId++;
    _setState(const LoginState.initial());
  }

  void _setState(LoginState value) {
    _state = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
