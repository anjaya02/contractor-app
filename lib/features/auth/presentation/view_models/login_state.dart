import 'package:flutter/foundation.dart';

import '../../models/contractor_account.dart';

enum LoginStatus { initial, submitting, authenticated, failure }

@immutable
class LoginState {
  const LoginState._({required this.status, this.account, this.error});

  const LoginState.initial() : this._(status: LoginStatus.initial);
  const LoginState.submitting() : this._(status: LoginStatus.submitting);
  const LoginState.authenticated(ContractorAccount account)
    : this._(status: LoginStatus.authenticated, account: account);
  const LoginState.failure(String message)
    : this._(status: LoginStatus.failure, error: message);

  final LoginStatus status;
  final ContractorAccount? account;
  final String? error;

  bool get isSubmitting => status == LoginStatus.submitting;
}
