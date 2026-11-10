import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../data/login_repository.dart';
import '../models/contractor_account.dart';
import 'sid_validator.dart';

class LoginController extends ChangeNotifier {
  LoginController({required LoginRepository repository})
    : _repository = repository;

  final LoginRepository _repository;
  ContractorAccount? _account;
  String? _error;
  bool _isSubmitting = false;
  bool _disposed = false;

  ContractorAccount? get account => _account;
  String? get error => _error;
  bool get isSubmitting => _isSubmitting;

  Future<void> signIn(String value) async {
    if (_isSubmitting || _disposed) return;

    final sid = value.trim();
    _error = validateSid(sid);
    if (_error != null) {
      notifyListeners();
      return;
    }

    _isSubmitting = true;
    notifyListeners();
    try {
      final account = await _repository.signIn(sid);
      if (!_disposed) _account = account;
    } on ApiException catch (error) {
      if (!_disposed) _error = error.message;
    } catch (_) {
      // Do not expose exception details or personal data to the UI/logs.
      if (!_disposed) {
        _error = 'Something went wrong. Please try again.';
      }
    } finally {
      _isSubmitting = false;
      // A request may finish after the app has released this controller.
      if (!_disposed) notifyListeners();
    }
  }

  void clearError() {
    if (_error == null || _disposed) return;
    _error = null;
    notifyListeners();
  }

  void signOut() {
    _account = null;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
