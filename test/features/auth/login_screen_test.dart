import 'dart:async';

import 'package:contractor_app/app/contractor_app.dart';
import 'package:contractor_app/core/network/api_exception.dart';
import 'package:contractor_app/features/auth/models/contractor_account.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_login_repository.dart';

void main() {
  Future<void> showApp(
    WidgetTester tester,
    FakeLoginRepository repository, {
    Size size = const Size(390, 844),
    double textScale = 1,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: ContractorApp(loginRepository: repository),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> submit(WidgetTester tester) async {
    final button = find.widgetWithText(FilledButton, 'Sign in');
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pump();
  }

  testWidgets('requires an SID before making a request', (tester) async {
    final repository = FakeLoginRepository();
    await showApp(tester, repository);
    await submit(tester);
    expect(find.text('Enter your staff ID.'), findsOneWidget);
    expect(repository.submittedSids, isEmpty);
  });

  testWidgets('shows pending state, account and a clean sign out', (
    tester,
  ) async {
    final pending = Completer<ContractorAccount>();
    final repository = FakeLoginRepository()..onSignIn = (_) => pending.future;
    await showApp(tester, repository);
    await tester.enterText(find.byKey(const ValueKey('sidField')), '001234');
    await submit(tester);

    expect(find.text('Signing in…'), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    expect(
      tester.widget<TextFormField>(find.byType(TextFormField)).enabled,
      isFalse,
    );
    expect(repository.submittedSids, ['001234']);

    pending.complete(
      const ContractorAccount(sid: '001234', displayName: 'Test Contractor'),
    );
    await tester.pumpAndSettle();
    expect(find.text('You’re signed in.'), findsOneWidget);
    expect(find.text('001234'), findsOneWidget);

    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back.'), findsOneWidget);
    expect(
      tester.widget<TextFormField>(find.byType(TextFormField)).controller?.text,
      isEmpty,
    );
  });

  testWidgets('keeps the entered SID when a request fails', (tester) async {
    final repository = FakeLoginRepository()
      ..onSignIn = (_) async =>
          throw const ApiException(ApiFailure.unavailable);
    await showApp(tester, repository);
    await tester.enterText(find.byKey(const ValueKey('sidField')), '001234');
    await submit(tester);
    await tester.pumpAndSettle();

    expect(
      find.text('Sign-in is temporarily unavailable. Please try again later.'),
      findsOneWidget,
    );
    expect(
      tester.widget<TextFormField>(find.byType(TextFormField)).controller?.text,
      '001234',
    );
    expect(find.text('You’re signed in.'), findsNothing);

    repository.onSignIn = null;
    await submit(tester);
    await tester.pumpAndSettle();
    expect(find.text('You’re signed in.'), findsOneWidget);
  });

  testWidgets('opens and closes practical sign-in help', (tester) async {
    await showApp(tester, FakeLoginRepository());
    await tester.ensureVisible(find.text('Need help signing in?'));
    await tester.tap(find.text('Need help signing in?'));
    await tester.pumpAndSettle();
    expect(find.text('Help with signing in'), findsOneWidget);
    await tester.tap(find.text('Got it'));
    await tester.pumpAndSettle();
    expect(find.text('Help with signing in'), findsNothing);
  });

  for (final size in [
    const Size(320, 568),
    const Size(390, 844),
    const Size(1024, 768),
  ]) {
    testWidgets('fits ${size.width} logical pixels with larger text', (
      tester,
    ) async {
      await showApp(tester, FakeLoginRepository(), size: size, textScale: 2);
      expect(
        MediaQuery.textScalerOf(
          tester.element(find.text('Welcome back.')),
        ).scale(10),
        20,
      );
      await tester.ensureVisible(find.widgetWithText(FilledButton, 'Sign in'));
      expect(tester.takeException(), isNull);
    });
  }
}
