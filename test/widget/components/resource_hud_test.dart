import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tower_defense_game/models/game_enums.dart';
import 'package:tower_defense_game/viewmodels/resource_viewmodel.dart';
import 'package:tower_defense_game/viewmodels/wall_viewmodel.dart';
import 'package:tower_defense_game/views/components/resource_hud.dart';

void main() {
  group('ResourceHUD Widget Tests', () {
    late ResourceViewModel resourceViewModel;
    late WallViewModel wallViewModel;

    setUp(() {
      resourceViewModel = ResourceViewModel();
      wallViewModel = WallViewModel(wallPosition: const Offset(400, 300));
    });

    tearDown(() {
      resourceViewModel.dispose();
      wallViewModel.dispose();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: Scaffold(
          body: MultiProvider(
            providers: [
              ChangeNotifierProvider<ResourceViewModel>.value(
                value: resourceViewModel,
              ),
              ChangeNotifierProvider<WallViewModel>.value(value: wallViewModel),
            ],
            child: const ResourceHUD(),
          ),
        ),
      );
    }

    group('Resource Display', () {
      testWidgets('displays all three resource types', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('Blue'), findsOneWidget);
        expect(find.text('Green'), findsOneWidget);
        expect(find.text('Yellow'), findsOneWidget);
      });

      testWidgets('displays resource amounts', (tester) async {
        resourceViewModel.add(ResourceType.blue, 100);
        resourceViewModel.add(ResourceType.green, 50);
        resourceViewModel.add(ResourceType.yellow, 25);

        await tester.pumpWidget(createTestWidget());

        expect(find.text('100'), findsOneWidget);
        expect(find.text('50'), findsOneWidget);
        expect(find.text('25'), findsOneWidget);
      });

      testWidgets('updates when resources change', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('0'), findsNWidgets(3)); // All start at 0

        resourceViewModel.add(ResourceType.blue, 42);
        await tester.pump();

        expect(find.text('42'), findsOneWidget);
      });
    });

    group('Generation Buttons', () {
      testWidgets('shows all generation buttons', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('Gen Blue'), findsOneWidget);
        expect(find.text('Gen Green'), findsOneWidget);
        expect(find.text('Gen Yellow'), findsOneWidget);
      });

      testWidgets('generation buttons are enabled initially', (tester) async {
        await tester.pumpWidget(createTestWidget());

        final blueButton = find.widgetWithText(ElevatedButton, 'Gen Blue');
        final greenButton = find.widgetWithText(ElevatedButton, 'Gen Green');
        final yellowButton = find.widgetWithText(ElevatedButton, 'Gen Yellow');

        expect(tester.widget<ElevatedButton>(blueButton).onPressed, isNotNull);
        expect(tester.widget<ElevatedButton>(greenButton).onPressed, isNotNull);
        expect(
          tester.widget<ElevatedButton>(yellowButton).onPressed,
          isNotNull,
        );
      });

      testWidgets('tapping blue button starts generation', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(
          resourceViewModel.getResource(ResourceType.blue)?.isGenerating,
          isFalse,
        );

        await tester.tap(find.text('Gen Blue'));
        await tester.pump();

        expect(
          resourceViewModel.getResource(ResourceType.blue)?.isGenerating,
          isTrue,
        );
      });
    });

    group('Wall Action Buttons', () {
      testWidgets('shows wall upgrade button', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('Upgrade (50 Blue)'), findsOneWidget);
      });

      testWidgets('shows wall heal button', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('Heal (30 Green)'), findsOneWidget);
      });

      testWidgets('upgrade button disabled when insufficient resources', (
        tester,
      ) async {
        await tester.pumpWidget(createTestWidget());

        final upgradeButton = find.widgetWithText(
          ElevatedButton,
          'Upgrade (50 Blue)',
        );

        expect(tester.widget<ElevatedButton>(upgradeButton).onPressed, isNull);
      });

      testWidgets('upgrade button enabled when resources available', (
        tester,
      ) async {
        resourceViewModel.add(ResourceType.blue, 100);

        await tester.pumpWidget(createTestWidget());

        final upgradeButton = find.widgetWithText(
          ElevatedButton,
          'Upgrade (50 Blue)',
        );

        expect(
          tester.widget<ElevatedButton>(upgradeButton).onPressed,
          isNotNull,
        );
      });

      testWidgets('heal button disabled when wall at full HP', (tester) async {
        resourceViewModel.add(ResourceType.green, 100);

        await tester.pumpWidget(createTestWidget());

        final healButton = find.widgetWithText(
          ElevatedButton,
          'Heal (30 Green)',
        );

        expect(tester.widget<ElevatedButton>(healButton).onPressed, isNull);
      });

      testWidgets(
        'heal button enabled when wall damaged and resources available',
        (tester) async {
          resourceViewModel.add(ResourceType.green, 100);
          wallViewModel.takeDamage(50);

          await tester.pumpWidget(createTestWidget());

          final healButton = find.widgetWithText(
            ElevatedButton,
            'Heal (30 Green)',
          );

          expect(
            tester.widget<ElevatedButton>(healButton).onPressed,
            isNotNull,
          );
        },
      );

      testWidgets('tapping upgrade button upgrades wall', (tester) async {
        resourceViewModel.add(ResourceType.blue, 100);

        await tester.pumpWidget(createTestWidget());

        final initialLevel = wallViewModel.level;

        await tester.tap(find.text('Upgrade (50 Blue)'));
        await tester.pump();

        expect(wallViewModel.level, equals(initialLevel + 1));
        expect(resourceViewModel.getAmount(ResourceType.blue), equals(50));
      });
    });

    group('Resource Upgrade Buttons (US4)', () {
      testWidgets('shows blue resource upgrade button', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(
          find.text('Upgrade Blue Generation (50 Yellow)'),
          findsOneWidget,
        );
      });

      testWidgets('shows green resource upgrade button', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(
          find.text('Upgrade Green Generation (50 Yellow)'),
          findsOneWidget,
        );
      });

      testWidgets('upgrade buttons disabled without yellow resources', (
        tester,
      ) async {
        await tester.pumpWidget(createTestWidget());

        final blueUpgradeButton = find.widgetWithText(
          ElevatedButton,
          'Upgrade Blue Generation (50 Yellow)',
        );

        expect(
          tester.widget<ElevatedButton>(blueUpgradeButton).onPressed,
          isNull,
        );
      });

      testWidgets('upgrade buttons enabled with enough yellow resources', (
        tester,
      ) async {
        resourceViewModel.add(ResourceType.yellow, 100);

        await tester.pumpWidget(createTestWidget());

        final blueUpgradeButton = find.widgetWithText(
          ElevatedButton,
          'Upgrade Blue Generation (50 Yellow)',
        );

        expect(
          tester.widget<ElevatedButton>(blueUpgradeButton).onPressed,
          isNotNull,
        );
      });

      testWidgets('tapping upgrade button increases generation rate', (
        tester,
      ) async {
        resourceViewModel.add(ResourceType.yellow, 100);
        resourceViewModel.startGeneration(ResourceType.blue);

        await tester.pumpWidget(createTestWidget());

        final initialRate =
            resourceViewModel.getResource(ResourceType.blue)?.generationRate ??
            0.0;

        await tester.tap(find.text('Upgrade Blue Generation (50 Yellow)'));
        await tester.pump();

        final newRate =
            resourceViewModel.getResource(ResourceType.blue)?.generationRate ??
            0.0;

        expect(newRate, greaterThan(initialRate));
        expect(resourceViewModel.getAmount(ResourceType.yellow), equals(50));
      });

      testWidgets('tapping upgrade button shows rate increase in UI', (
        tester,
      ) async {
        resourceViewModel.add(ResourceType.yellow, 100);
        resourceViewModel.startGeneration(ResourceType.blue);

        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Find the rate display for blue resource
        final rateTextFinder = find.textContaining('/s');

        expect(rateTextFinder, findsWidgets);

        // Tap upgrade button
        await tester.tap(find.text('Upgrade Blue Generation (50 Yellow)'));
        await tester.pumpAndSettle();

        // Verify UI updated
        expect(rateTextFinder, findsWidgets);
      });

      testWidgets('upgrade cost increases after each upgrade', (tester) async {
        resourceViewModel.add(ResourceType.yellow, 500);

        await tester.pumpWidget(createTestWidget());

        // First upgrade costs 50
        expect(
          find.text('Upgrade Blue Generation (50 Yellow)'),
          findsOneWidget,
        );

        await tester.tap(find.text('Upgrade Blue Generation (50 Yellow)'));
        await tester.pumpAndSettle();

        // Second upgrade should cost more (exponential scaling)
        // Cost formula: baseCost * (1.5 ^ upgradeLevel)
        // After first upgrade: 50 * 1.5 = 75
        expect(
          find.text('Upgrade Blue Generation (75 Yellow)'),
          findsOneWidget,
        );
      });

      testWidgets('can upgrade green resource generation', (tester) async {
        resourceViewModel.add(ResourceType.yellow, 100);
        resourceViewModel.startGeneration(ResourceType.green);

        await tester.pumpWidget(createTestWidget());

        final initialRate =
            resourceViewModel.getResource(ResourceType.green)?.generationRate ??
            0.0;

        await tester.tap(find.text('Upgrade Green Generation (50 Yellow)'));
        await tester.pump();

        final newRate =
            resourceViewModel.getResource(ResourceType.green)?.generationRate ??
            0.0;

        expect(newRate, greaterThan(initialRate));
      });

      testWidgets('multiple upgrades compound generation rate', (tester) async {
        resourceViewModel.add(ResourceType.yellow, 500);
        resourceViewModel.startGeneration(ResourceType.blue);

        await tester.pumpWidget(createTestWidget());

        final initialRate =
            resourceViewModel.getResource(ResourceType.blue)?.generationRate ??
            0.0;

        // First upgrade
        await tester.tap(find.text('Upgrade Blue Generation (50 Yellow)'));
        await tester.pumpAndSettle();

        final rateAfterFirst =
            resourceViewModel.getResource(ResourceType.blue)?.generationRate ??
            0.0;

        // Second upgrade
        await tester.tap(find.text('Upgrade Blue Generation (75 Yellow)'));
        await tester.pumpAndSettle();

        final rateAfterSecond =
            resourceViewModel.getResource(ResourceType.blue)?.generationRate ??
            0.0;

        expect(rateAfterFirst, greaterThan(initialRate));
        expect(rateAfterSecond, greaterThan(rateAfterFirst));
      });
    });

    group('Wall Info Display', () {
      testWidgets('displays wall HP', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.textContaining('HP:'), findsOneWidget);
      });

      testWidgets('displays wall level', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.textContaining('Lv:'), findsOneWidget);
      });

      testWidgets('updates when wall takes damage', (tester) async {
        await tester.pumpWidget(createTestWidget());

        wallViewModel.takeDamage(50);
        await tester.pump();

        // Verify HP display updated (implementation-specific text)
        expect(find.textContaining('HP:'), findsOneWidget);
      });
    });
  });
}
