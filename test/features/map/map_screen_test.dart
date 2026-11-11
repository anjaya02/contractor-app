import 'package:contractor_app/core/theme/app_theme.dart';
import 'package:contractor_app/core/network/api_exception.dart';
import 'package:contractor_app/features/map/presentation/view_models/network_map_view_model.dart';
import 'package:contractor_app/features/map/presentation/widgets/map_controls.dart';
import 'package:contractor_app/features/map/presentation/map_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:contractor_app/features/map/data/equipment_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_equipment_repository.dart';

void main() {
  for (final size in [
    const Size(390, 844),
    const Size(1100, 800),
    const Size(320, 568),
  ]) {
    testWidgets('loads a plan, opens details and fits ${size.width}px', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repository = FakeEquipmentRepository();
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Provider<EquipmentRepository>.value(
            value: repository,
            child: const MapScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(repository.references.length, 1);
      expect(find.text('2 shown'), findsOneWidget);
      expect(find.text('Fit points'), findsOneWidget);
      expect(find.byIcon(Icons.fit_screen_rounded), findsNothing);
      await tester.tap(find.text('Test pole'));
      await tester.pumpAndSettle();
      expect(find.text('Coordinates'), findsOneWidget);
      await tester.ensureVisible(find.text('Close'));
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  Future<void> showMap(
    WidgetTester tester,
    FakeEquipmentRepository repository, {
    double textScale = 1,
  }) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: MaterialApp(
          theme: AppTheme.light,
          home: Provider<EquipmentRepository>.value(
            value: repository,
            child: const MapScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'changing filters and reloading keeps controls and point counts in sync',
    (tester) async {
      final repository = FakeEquipmentRepository();
      await showMap(tester, repository);
      await tester.tap(find.byKey(const ValueKey('typeFilter')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('FDP').last);
      await tester.pumpAndSettle();
      expect(find.text('1 shown'), findsOneWidget);
      await tester.tap(find.byTooltip('Load plan'));
      await tester.pumpAndSettle();
      final model = tester
          .element(find.byType(MapControls))
          .read<NetworkMapViewModel>();
      expect(model.state.selectedType, isNull);
      expect(find.text('All types'), findsOneWidget);
      expect(find.text('2 shown'), findsOneWidget);
      expect(repository.references.length, 2);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('shows a failed load and recovers through retry', (tester) async {
    final repository = FakeEquipmentRepository()
      ..onLoad = (_) async => throw const ApiException(ApiFailure.connection);
    await showMap(tester, repository);
    expect(find.text('Try again'), findsOneWidget);
    repository.onLoad = null;
    await tester.ensureVisible(find.text('Try again'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('2 shown'), findsOneWidget);
    expect(find.text('Try again'), findsNothing);
  });

  testWidgets('handles larger text on a small map screen', (tester) async {
    await showMap(tester, FakeEquipmentRepository(), textScale: 2);
    expect(
      MediaQuery.textScalerOf(
        tester.element(find.text('Fit points')),
      ).scale(10),
      20,
    );
    expect(tester.takeException(), isNull);
  });
}
