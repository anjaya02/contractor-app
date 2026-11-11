import 'package:contractor_app/core/theme/app_theme.dart';
import 'package:contractor_app/features/map/presentation/map_screen.dart';
import 'package:flutter/material.dart';
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
          home: MapScreen(repository: repository),
        ),
      );
      await tester.pumpAndSettle();
      expect(repository.references.length, 1);
      expect(find.text('2 shown'), findsOneWidget);
      await tester.tap(find.text('Test pole'));
      await tester.pumpAndSettle();
      expect(find.text('Coordinates'), findsOneWidget);
      await tester.ensureVisible(find.text('Close'));
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
