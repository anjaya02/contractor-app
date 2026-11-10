import 'dart:async';

import 'package:contractor_app/core/network/api_exception.dart';
import 'package:contractor_app/features/auth/models/contractor_account.dart';
import 'package:contractor_app/features/auth/presentation/login_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_login_repository.dart';

void main() {
  late FakeLoginRepository repository;
  late LoginController controller;

  setUp(() {
    repository = FakeLoginRepository();
    controller = LoginController(repository: repository);
  });
  tearDown(() => controller.dispose());

  for (final input in ['', '  ', 'abc', '12 34']) {
    test('does not send an invalid SID: "$input"', () async {
      await controller.signIn(input);
      expect(repository.submittedSids, isEmpty);
      expect(controller.error, isNotNull);
      expect(controller.account, isNull);
    });
  }

  test('trims surrounding space and preserves leading zeroes', () async {
    await controller.signIn(' 001234 ');
    expect(repository.submittedSids, ['001234']);
    expect(controller.account?.sid, '001234');
    expect(controller.error, isNull);
    expect(controller.isSubmitting, isFalse);
  });

  test('blocks repeated submissions while a request is pending', () async {
    final pending = Completer<ContractorAccount>();
    repository.onSignIn = (_) => pending.future;
    final first = controller.signIn('001234');
    await controller.signIn('001234');
    expect(controller.isSubmitting, isTrue);
    expect(repository.submittedSids, ['001234']);
    pending.complete(const ContractorAccount(sid: '001234'));
    await first;
    expect(controller.isSubmitting, isFalse);
  });

  test('recovers from an API failure and allows a retry', () async {
    repository.onSignIn = (_) async =>
        throw const ApiException(ApiFailure.connection);
    await controller.signIn('001234');
    expect(controller.error, contains('internet connection'));
    expect(controller.account, isNull);
    expect(controller.isSubmitting, isFalse);

    repository.onSignIn = null;
    await controller.signIn('001234');
    expect(controller.account?.sid, '001234');
    expect(controller.error, isNull);
  });

  test('does not expose unexpected exception details', () async {
    repository.onSignIn = (_) async => throw Exception('private response');
    await controller.signIn('001234');
    expect(controller.error, 'Something went wrong. Please try again.');
  });

  test('clears the session on sign out', () async {
    await controller.signIn('001234');
    controller.signOut();
    expect(controller.account, isNull);
    expect(controller.error, isNull);
  });

  test('does not notify listeners after disposal during a request', () async {
    final pending = Completer<ContractorAccount>();
    final disposable = LoginController(
      repository: FakeLoginRepository()..onSignIn = (_) => pending.future,
    );
    var notifications = 0;
    disposable.addListener(() => notifications++);
    final request = disposable.signIn('001234');
    disposable.dispose();
    pending.complete(const ContractorAccount(sid: '001234'));
    await request;
    expect(notifications, 1);
    expect(disposable.account, isNull);
  });
}
