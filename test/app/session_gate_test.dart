import 'package:contractor_app/app/contractor_app.dart';
import 'package:contractor_app/features/auth/presentation/view_models/login_view_model.dart';
import 'package:contractor_app/features/map/presentation/view_models/network_map_view_model.dart';
import 'package:contractor_app/features/map/presentation/widgets/map_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../support/fake_equipment_repository.dart';
import '../support/fake_login_repository.dart';

Future<void> signIn(
  WidgetTester tester,
  FakeEquipmentRepository equipment,
) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ContractorApp(
      loginRepository: FakeLoginRepository(),
      equipmentRepository: equipment,
    ),
  );
  await tester.pumpAndSettle();
  await tester.enterText(find.byKey(const ValueKey('sidField')), '001234');
  final button = find.widgetWithText(FilledButton, 'Sign in');
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('sign-out removes all protected routes and clears the session', (
    tester,
  ) async {
    await signIn(tester, FakeEquipmentRepository());
    await tester.tap(find.byKey(const ValueKey('openMap')));
    await tester.pumpAndSettle();
    final context = tester.element(find.byType(MapControls));
    context.read<LoginViewModel>().signOut();
    await tester.pumpAndSettle();
    expect(find.text('Welcome back.'), findsOneWidget);
    expect(find.byType(MapControls), findsNothing);
    expect(
      Navigator.of(tester.element(find.text('Welcome back.'))).canPop(),
      isFalse,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('reopening the map creates fresh route state', (tester) async {
    final equipment = FakeEquipmentRepository();
    await signIn(tester, equipment);
    await tester.tap(find.byKey(const ValueKey('openMap')));
    await tester.pumpAndSettle();
    final first = tester
        .element(find.byType(MapControls))
        .read<NetworkMapViewModel>();
    first.selectType('FDP');
    first.toggleSatellite();
    await tester.pumpAndSettle();
    expect(find.text('1 shown'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('openMap')));
    await tester.pumpAndSettle();
    final second = tester
        .element(find.byType(MapControls))
        .read<NetworkMapViewModel>();
    expect(identical(first, second), isFalse);
    expect(second.state.selectedType, isNull);
    expect(second.state.isSatellite, isFalse);
    expect(equipment.references.length, 2);
    expect(find.text('2 shown'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('system back returns from the map to the workspace', (
    tester,
  ) async {
    await signIn(tester, FakeEquipmentRepository());
    await tester.tap(find.byKey(const ValueKey('openMap')));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Your workspace'), findsOneWidget);
    expect(find.byType(MapControls), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
