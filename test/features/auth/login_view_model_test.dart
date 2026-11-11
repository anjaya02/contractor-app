import 'dart:async';

import 'package:contractor_app/core/network/api_exception.dart';
import 'package:contractor_app/features/auth/models/contractor_account.dart';
import 'package:contractor_app/features/auth/presentation/view_models/login_view_model.dart';
import 'package:contractor_app/features/auth/presentation/view_models/login_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_login_repository.dart';

void main() {
  late FakeLoginRepository repository;
  late LoginViewModel model;

  setUp(() {
    repository = FakeLoginRepository();
    model = LoginViewModel(repository: repository);
  });
  tearDown(() => model.dispose());

  for (final input in ['', '  ', 'abc', '12 34']) {
    test('does not send an invalid SID: "$input"', () async {
      await model.signIn(input);
      expect(repository.submittedSids, isEmpty);
      expect(model.state.error, isNotNull);
      expect(model.state.account, isNull);
    });
  }

  test('trims surrounding space and preserves leading zeroes', () async {
    await model.signIn(' 001234 ');
    expect(repository.submittedSids, ['001234']);
    expect(model.state.account?.sid, '001234');
    expect(model.state.error, isNull);
    expect(model.state.isSubmitting, isFalse);
  });

  test('blocks repeated submissions while a request is pending', () async {
    final pending = Completer<ContractorAccount>();
    repository.onSignIn = (_) => pending.future;
    final first = model.signIn('001234');
    await model.signIn('001234');
    expect(model.state.isSubmitting, isTrue);
    expect(repository.submittedSids, ['001234']);
    pending.complete(const ContractorAccount(sid: '001234'));
    await first;
    expect(model.state.isSubmitting, isFalse);
  });

  test('recovers from an API failure and allows a retry', () async {
    repository.onSignIn = (_) async =>
        throw const ApiException(ApiFailure.connection);
    await model.signIn('001234');
    expect(model.state.error, contains('internet connection'));
    expect(model.state.account, isNull);
    expect(model.state.isSubmitting, isFalse);

    repository.onSignIn = null;
    await model.signIn('001234');
    expect(model.state.account?.sid, '001234');
    expect(model.state.error, isNull);
  });

  test('does not expose unexpected exception details', () async {
    repository.onSignIn = (_) async => throw Exception('private response');
    await model.signIn('001234');
    expect(model.state.error, 'Something went wrong. Please try again.');
  });

  test('clears the session on sign out', () async {
    await model.signIn('001234');
    model.signOut();
    expect(model.state.account, isNull);
    expect(model.state.error, isNull);
  });

  test('ignores a login response completed after disposal', () async {
    final pending = Completer<ContractorAccount>();
    final disposable = LoginViewModel(repository: repository);
    repository.onSignIn = (_) => pending.future;
    final request = disposable.signIn('001234');
    disposable.dispose();
    pending.complete(const ContractorAccount(sid: '001234'));
    await request;
    expect(disposable.state.account, isNull);
  });

  test(
    'sign-out invalidates an in-flight response even after another login',
    () async {
      final firstResponse = Completer<ContractorAccount>();
      repository.onSignIn = (_) => firstResponse.future;
      final firstRequest = model.signIn('001234');
      model.signOut();
      repository.onSignIn = null;
      await model.signIn('005678');
      firstResponse.complete(const ContractorAccount(sid: '001234'));
      await firstRequest;
      expect(model.state.account?.sid, '005678');
    },
  );

  test(
    'notifies submission and successful API verification in order',
    () async {
      final statuses = <LoginStatus>[];
      model.addListener(() => statuses.add(model.state.status));
      await model.signIn('001234');
      expect(statuses, [LoginStatus.submitting, LoginStatus.authenticated]);
    },
  );
}
