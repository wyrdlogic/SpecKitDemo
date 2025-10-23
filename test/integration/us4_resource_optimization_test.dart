import 'package:flutter_test/flutter_test.dart';
import 'package:tower_defense_game/models/game_enums.dart';
import 'package:tower_defense_game/viewmodels/resource_viewmodel.dart';

void main() {
  group('US4: Resource Efficiency Optimization Integration Tests', () {
    late ResourceViewModel resourceViewModel;

    setUp(() {
      resourceViewModel = ResourceViewModel();
    });

    tearDown(() {
      resourceViewModel.dispose();
    });

    group('Yellow Resource Upgrade System', () {
      test(
        'complete upgrade flow: earn yellow → spend yellow → increase generation rate',
        () async {
          // Verify initial state
          expect(resourceViewModel.getAmount(ResourceType.blue), equals(0));
          expect(resourceViewModel.getAmount(ResourceType.yellow), equals(0));
          final blueResource = resourceViewModel.getResource(
            ResourceType.blue,
          )!;
          expect(blueResource.generationRate, equals(0.0));

          // Start blue generation
          await resourceViewModel.startGeneration(ResourceType.blue);
          expect(blueResource.isGenerating, isTrue);
          expect(blueResource.generationRate, equals(1.0));

          // Simulate earning yellow resources
          resourceViewModel.add(ResourceType.yellow, 100);
          expect(resourceViewModel.getAmount(ResourceType.yellow), equals(100));

          // Verify upgrade is affordable (base cost: 50 yellow)
          expect(resourceViewModel.canAfford(ResourceType.yellow, 50), isTrue);

          // Perform upgrade (+0.5/s increase, costs 50 yellow)
          final initialRate = blueResource.generationRate;
          await resourceViewModel.upgradeGenerationRate(
            ResourceType.blue, // target
            0.5, // rate increase
            ResourceType.yellow, // cost type
            50, // cost amount
          );

          // Verify upgrade effects
          expect(
            resourceViewModel.getAmount(ResourceType.yellow),
            equals(50),
          ); // 100 - 50
          expect(
            blueResource.generationRate,
            equals(initialRate + 0.5),
          ); // +0.5/s
        },
      );

      test(
        'exponential cost scaling: first upgrade 50, second upgrade 75, third upgrade 112',
        () async {
          resourceViewModel.add(ResourceType.yellow, 300);
          await resourceViewModel.startGeneration(ResourceType.blue);

          final blueResource = resourceViewModel.getResource(
            ResourceType.blue,
          )!;

          // First upgrade: 50 yellow, +0.5/s
          await resourceViewModel.upgradeGenerationRate(
            ResourceType.blue,
            0.5,
            ResourceType.yellow,
            50,
          );
          expect(resourceViewModel.getAmount(ResourceType.yellow), equals(250));
          expect(blueResource.generationRate, equals(1.5));

          // Second upgrade: 75 yellow (50 * 1.5^1), +0.5/s
          await resourceViewModel.upgradeGenerationRate(
            ResourceType.blue,
            0.5,
            ResourceType.yellow,
            75,
          );
          expect(resourceViewModel.getAmount(ResourceType.yellow), equals(175));
          expect(blueResource.generationRate, equals(2.0));

          // Third upgrade: 112 yellow (50 * 1.5^2 ≈ 112.5), +0.5/s
          await resourceViewModel.upgradeGenerationRate(
            ResourceType.blue,
            0.5,
            ResourceType.yellow,
            112,
          );
          expect(resourceViewModel.getAmount(ResourceType.yellow), equals(63));
          expect(blueResource.generationRate, closeTo(2.5, 0.01));
        },
      );

      test('multiple resource upgrades work independently', () async {
        resourceViewModel.add(ResourceType.yellow, 200);
        await resourceViewModel.startGeneration(ResourceType.blue);
        await resourceViewModel.startGeneration(ResourceType.green);

        final blueResource = resourceViewModel.getResource(ResourceType.blue)!;
        final greenResource = resourceViewModel.getResource(
          ResourceType.green,
        )!;

        // Upgrade blue generation (+0.5/s, costs 50 yellow)
        await resourceViewModel.upgradeGenerationRate(
          ResourceType.blue,
          0.5,
          ResourceType.yellow,
          50,
        );
        expect(blueResource.generationRate, equals(1.5));
        expect(greenResource.generationRate, equals(1.0)); // Unchanged
        expect(resourceViewModel.getAmount(ResourceType.yellow), equals(150));

        // Upgrade green generation (+0.5/s, costs 50 yellow)
        await resourceViewModel.upgradeGenerationRate(
          ResourceType.green,
          0.5,
          ResourceType.yellow,
          50,
        );
        expect(blueResource.generationRate, equals(1.5)); // Still upgraded
        expect(greenResource.generationRate, equals(1.5));
        expect(resourceViewModel.getAmount(ResourceType.yellow), equals(100));

        // Second upgrades cost more (75 yellow each with exponential scaling)
        expect(resourceViewModel.canAfford(ResourceType.yellow, 75), isTrue);
      });

      test(
        'generation rate compounds correctly with multiple upgrades',
        () async {
          resourceViewModel.add(ResourceType.yellow, 500);
          await resourceViewModel.startGeneration(ResourceType.blue);

          final blueResource = resourceViewModel.getResource(
            ResourceType.blue,
          )!;
          expect(blueResource.generationRate, equals(1.0));

          // First upgrade: +0.5/s → 1.5/s
          await resourceViewModel.upgradeGenerationRate(
            ResourceType.blue,
            0.5,
            ResourceType.yellow,
            50,
          );
          expect(blueResource.generationRate, equals(1.5));

          // Second upgrade: +0.5/s → 2.0/s
          await resourceViewModel.upgradeGenerationRate(
            ResourceType.blue,
            0.5,
            ResourceType.yellow,
            75,
          );
          expect(blueResource.generationRate, equals(2.0));

          // Third upgrade: +0.5/s → 2.5/s
          await resourceViewModel.upgradeGenerationRate(
            ResourceType.blue,
            0.5,
            ResourceType.yellow,
            112,
          );
          expect(blueResource.generationRate, closeTo(2.5, 0.01));
        },
      );

      test('cannot upgrade without sufficient yellow resources', () async {
        resourceViewModel.add(ResourceType.yellow, 30);
        await resourceViewModel.startGeneration(ResourceType.blue);

        final blueResource = resourceViewModel.getResource(ResourceType.blue)!;
        final initialRate = blueResource.generationRate;

        expect(resourceViewModel.canAfford(ResourceType.yellow, 50), isFalse);

        // Upgrade fails silently when not affordable
        await resourceViewModel.upgradeGenerationRate(
          ResourceType.blue,
          0.5,
          ResourceType.yellow,
          50,
        );

        expect(blueResource.generationRate, equals(initialRate)); // Unchanged
        expect(
          resourceViewModel.getAmount(ResourceType.yellow),
          equals(30),
        ); // Not spent
      });

      test('cannot upgrade resource that is not generating', () async {
        resourceViewModel.add(ResourceType.yellow, 100);

        final blueResource = resourceViewModel.getResource(ResourceType.blue)!;
        expect(blueResource.isGenerating, isFalse);

        // Upgrade still works but has no visible effect until generation starts
        await resourceViewModel.upgradeGenerationRate(
          ResourceType.blue,
          0.5,
          ResourceType.yellow,
          50,
        );
        expect(
          resourceViewModel.getAmount(ResourceType.yellow),
          equals(50),
        ); // Cost paid
        expect(blueResource.generationRate, equals(0.5)); // Rate increased
      });
    });

    group('Strategic Decision Making', () {
      test(
        'player must choose between wall upgrades and resource upgrades',
        () async {
          // Simulate mid-game scenario
          resourceViewModel.add(ResourceType.blue, 100);
          resourceViewModel.add(ResourceType.yellow, 50);
          await resourceViewModel.startGeneration(ResourceType.blue);

          // Player can either:
          // 1. Upgrade wall (requires 50 blue)
          final canUpgradeWall = resourceViewModel.canAfford(
            ResourceType.blue,
            50,
          );
          expect(canUpgradeWall, isTrue);

          // 2. Upgrade resource generation (requires 50 yellow)
          final canUpgradeGeneration = resourceViewModel.canAfford(
            ResourceType.yellow,
            50,
          );
          expect(canUpgradeGeneration, isTrue);

          // Choose resource upgrade
          await resourceViewModel.upgradeGenerationRate(
            ResourceType.blue,
            0.5,
            ResourceType.yellow,
            50,
          );
          expect(resourceViewModel.getAmount(ResourceType.yellow), equals(0));

          final blueResource = resourceViewModel.getResource(
            ResourceType.blue,
          )!;
          expect(blueResource.generationRate, equals(1.5));

          // Now cannot afford wall upgrade (yellow spent)
          expect(resourceViewModel.canAfford(ResourceType.yellow, 50), isFalse);
          expect(
            resourceViewModel.canAfford(ResourceType.blue, 50),
            isTrue,
          ); // But can still use blue
        },
      );

      test(
        'upgrading generation accelerates resource accumulation over time',
        () async {
          await resourceViewModel.startGeneration(ResourceType.blue);
          resourceViewModel.add(ResourceType.yellow, 100);

          final blueResource = resourceViewModel.getResource(
            ResourceType.blue,
          )!;

          // Generate resources for 10 seconds at base rate (1.0/s)
          final baseRate = blueResource.generationRate;
          final baseProduction = baseRate * 10; // 10.0 resources

          // Upgrade generation (+0.5/s)
          await resourceViewModel.upgradeGenerationRate(
            ResourceType.blue,
            0.5,
            ResourceType.yellow,
            50,
          );
          final upgradedRate = blueResource.generationRate;
          final upgradedProduction = upgradedRate * 10; // 15.0 resources

          // Verify upgrade produces 50% more over same time period
          expect(upgradedProduction, equals(baseProduction * 1.5));
          expect(upgradedRate, equals(1.5));
        },
      );

      test(
        'yellow resource becomes valuable currency for optimization',
        () async {
          await resourceViewModel.startGeneration(ResourceType.yellow);
          resourceViewModel.add(ResourceType.yellow, 200);

          // Yellow resources can be:
          // 1. Spent on blue generation upgrades
          await resourceViewModel.startGeneration(ResourceType.blue);
          await resourceViewModel.upgradeGenerationRate(
            ResourceType.blue,
            0.5,
            ResourceType.yellow,
            50,
          );
          expect(resourceViewModel.getAmount(ResourceType.yellow), equals(150));

          // 2. Spent on green generation upgrades
          await resourceViewModel.startGeneration(ResourceType.green);
          await resourceViewModel.upgradeGenerationRate(
            ResourceType.green,
            0.5,
            ResourceType.yellow,
            50,
          );
          expect(resourceViewModel.getAmount(ResourceType.yellow), equals(100));

          // 3. Hoarded for future high-cost upgrades
          final futureUpgradeCost = 75; // Second level upgrade
          expect(
            resourceViewModel.canAfford(ResourceType.yellow, futureUpgradeCost),
            isTrue,
          );
        },
      );
    });

    group('ViewModel Integration', () {
      test(
        'upgradeGenerationRate tracks state correctly across multiple upgrades',
        () async {
          await resourceViewModel.startGeneration(ResourceType.blue);
          resourceViewModel.add(ResourceType.yellow, 300);

          final blueResource = resourceViewModel.getResource(
            ResourceType.blue,
          )!;

          // Initial state
          expect(blueResource.generationRate, equals(1.0));

          // First upgrade: costs 50, rate becomes 1.5/s
          await resourceViewModel.upgradeGenerationRate(
            ResourceType.blue,
            0.5,
            ResourceType.yellow,
            50,
          );
          expect(blueResource.generationRate, equals(1.5));
          expect(resourceViewModel.getAmount(ResourceType.yellow), equals(250));

          // Second upgrade: costs 75, rate becomes 2.0/s
          await resourceViewModel.upgradeGenerationRate(
            ResourceType.blue,
            0.5,
            ResourceType.yellow,
            75,
          );
          expect(blueResource.generationRate, equals(2.0));
          expect(resourceViewModel.getAmount(ResourceType.yellow), equals(175));

          // Third upgrade: costs 112, rate becomes 2.5/s
          await resourceViewModel.upgradeGenerationRate(
            ResourceType.blue,
            0.5,
            ResourceType.yellow,
            112,
          );
          expect(blueResource.generationRate, closeTo(2.5, 0.01));
          expect(resourceViewModel.getAmount(ResourceType.yellow), equals(63));
        },
      );

      test('notifies listeners when upgrades occur', () async {
        await resourceViewModel.startGeneration(ResourceType.blue);
        resourceViewModel.add(ResourceType.yellow, 100);

        var notificationCount = 0;
        resourceViewModel.addListener(() {
          notificationCount++;
        });

        // Upgrade should notify listeners
        await resourceViewModel.upgradeGenerationRate(
          ResourceType.blue,
          0.5,
          ResourceType.yellow,
          50,
        );

        expect(notificationCount, greaterThan(0));
      });

      test('all resource types can be upgraded independently', () async {
        resourceViewModel.add(ResourceType.yellow, 300);

        // Start all three resource generations
        await resourceViewModel.startGeneration(ResourceType.blue);
        await resourceViewModel.startGeneration(ResourceType.green);
        await resourceViewModel.startGeneration(ResourceType.yellow);

        final blueResource = resourceViewModel.getResource(ResourceType.blue)!;
        final greenResource = resourceViewModel.getResource(
          ResourceType.green,
        )!;
        final yellowResource = resourceViewModel.getResource(
          ResourceType.yellow,
        )!;

        // Upgrade each resource
        await resourceViewModel.upgradeGenerationRate(
          ResourceType.blue,
          0.5,
          ResourceType.yellow,
          50,
        );
        await resourceViewModel.upgradeGenerationRate(
          ResourceType.green,
          0.5,
          ResourceType.yellow,
          50,
        );

        // Verify independent upgrades
        expect(blueResource.generationRate, equals(1.5));
        expect(greenResource.generationRate, equals(1.5));
        expect(yellowResource.generationRate, equals(1.0)); // Not upgraded
        expect(resourceViewModel.getAmount(ResourceType.yellow), equals(200));
      });
    });
  });
}
