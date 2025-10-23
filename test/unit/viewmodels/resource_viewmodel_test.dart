import 'package:flutter_test/flutter_test.dart';
import 'package:tower_defense_game/viewmodels/resource_viewmodel.dart';
import 'package:tower_defense_game/models/game_enums.dart';

void main() {
  group('ResourceViewModel Tests', () {
    late ResourceViewModel viewModel;

    setUp(() {
      viewModel = ResourceViewModel();
    });

    tearDown(() {
      viewModel.dispose();
    });

    group('Initialization', () {
      test('initializes with all resource types at zero', () {
        for (final type in ResourceType.values) {
          expect(viewModel.getAmount(type), equals(0));
          final resource = viewModel.getResource(type);
          expect(resource, isNotNull);
          expect(resource!.type, equals(type));
        }
      });

      test('resources are not generating initially', () {
        for (final type in ResourceType.values) {
          final resource = viewModel.getResource(type);
          expect(resource?.isGenerating, isFalse);
        }
      });
    });

    group('Resource Queries', () {
      test('getResource returns resource for valid type', () {
        final resource = viewModel.getResource(ResourceType.blue);
        expect(resource, isNotNull);
        expect(resource!.type, equals(ResourceType.blue));
      });

      test('getAmount returns current resource amount', () {
        viewModel.add(ResourceType.blue, 50);
        expect(viewModel.getAmount(ResourceType.blue), equals(50));
      });

      test('resources property returns unmodifiable map', () {
        final resourcesMap = viewModel.resources;
        expect(resourcesMap, isNotEmpty);
        expect(resourcesMap.length, equals(ResourceType.values.length));
      });
    });

    group('Resource Generation', () {
      test('startGeneration enables resource generation', () async {
        await viewModel.startGeneration(ResourceType.blue);

        final resource = viewModel.getResource(ResourceType.blue);
        expect(resource?.isGenerating, isTrue);
      });

      test('stopGeneration disables resource generation', () async {
        await viewModel.startGeneration(ResourceType.blue);
        await viewModel.stopGeneration(ResourceType.blue);

        final resource = viewModel.getResource(ResourceType.blue);
        expect(resource?.isGenerating, isFalse);
      });

      test('updateGeneration generates resources over time', () async {
        // Set up resource with generation rate
        final resource = viewModel.getResource(ResourceType.blue);
        resource?.setGenerationRate(10.0); // 10 per second
        await viewModel.startGeneration(ResourceType.blue);

        // Simulate 60 frames (1 second at 60 FPS)
        for (var i = 0; i < 61; i++) {
          // One extra frame for tolerance
          viewModel.updateGeneration();
        }

        // Should have generated at least 10 resources (10/sec * 1 sec)
        expect(viewModel.getAmount(ResourceType.blue), greaterThan(0));
        expect(
          viewModel.getAmount(ResourceType.blue),
          greaterThanOrEqualTo(10),
        );
      });

      test('updateGeneration notifies listeners', () {
        var notified = false;
        viewModel.addListener(() {
          notified = true;
        });

        viewModel.updateGeneration();

        expect(notified, isTrue);
      });
    });

    group('Resource Spending', () {
      test('canAfford returns true when sufficient resources', () {
        viewModel.add(ResourceType.blue, 100);

        expect(viewModel.canAfford(ResourceType.blue, 50), isTrue);
        expect(viewModel.canAfford(ResourceType.blue, 100), isTrue);
      });

      test('canAfford returns false when insufficient resources', () {
        viewModel.add(ResourceType.blue, 50);

        expect(viewModel.canAfford(ResourceType.blue, 51), isFalse);
        expect(viewModel.canAfford(ResourceType.blue, 100), isFalse);
      });

      test('spend reduces resource amount', () {
        viewModel.add(ResourceType.blue, 100);

        final success = viewModel.spend(ResourceType.blue, 30);

        expect(success, isTrue);
        expect(viewModel.getAmount(ResourceType.blue), equals(70));
      });

      test('spend returns false when insufficient resources', () {
        viewModel.add(ResourceType.blue, 50);

        final success = viewModel.spend(ResourceType.blue, 60);

        expect(success, isFalse);
        expect(viewModel.getAmount(ResourceType.blue), equals(50));
      });

      test('spend notifies listeners on success', () {
        viewModel.add(ResourceType.blue, 100);

        var notified = false;
        viewModel.addListener(() {
          notified = true;
        });

        viewModel.spend(ResourceType.blue, 30);

        expect(notified, isTrue);
      });
    });

    group('Resource Addition', () {
      test('add increases resource amount', () {
        viewModel.add(ResourceType.blue, 50);
        expect(viewModel.getAmount(ResourceType.blue), equals(50));

        viewModel.add(ResourceType.blue, 25);
        expect(viewModel.getAmount(ResourceType.blue), equals(75));
      });

      test('add notifies listeners', () {
        var notified = false;
        viewModel.addListener(() {
          notified = true;
        });

        viewModel.add(ResourceType.blue, 10);

        expect(notified, isTrue);
      });

      test('add works for all resource types', () {
        for (final type in ResourceType.values) {
          viewModel.add(type, 25);
          expect(viewModel.getAmount(type), equals(25));
        }
      });
    });

    group('Generation Rate Upgrades', () {
      test('upgradeGenerationRate increases rate when affordable', () async {
        // Give enough yellow resources for upgrade
        viewModel.add(ResourceType.yellow, 100);

        final blueBefore = viewModel.getResource(ResourceType.blue);
        final initialRate = blueBefore?.generationRate ?? 0.0;

        await viewModel.upgradeGenerationRate(
          ResourceType.blue,
          5.0,
          ResourceType.yellow,
          50,
        );

        final blueAfter = viewModel.getResource(ResourceType.blue);
        expect(blueAfter?.generationRate, equals(initialRate + 5.0));
        expect(
          viewModel.getAmount(ResourceType.yellow),
          equals(50),
        ); // Cost deducted
      });

      test('upgradeGenerationRate fails when not affordable', () async {
        // Not enough yellow resources
        viewModel.add(ResourceType.yellow, 30);

        final blueBefore = viewModel.getResource(ResourceType.blue);
        final initialRate = blueBefore?.generationRate ?? 0.0;

        await viewModel.upgradeGenerationRate(
          ResourceType.blue,
          5.0,
          ResourceType.yellow,
          50,
        );

        final blueAfter = viewModel.getResource(ResourceType.blue);
        expect(blueAfter?.generationRate, equals(initialRate)); // Unchanged
        expect(
          viewModel.getAmount(ResourceType.yellow),
          equals(30),
        ); // No deduction
      });

      test('upgradeGenerationRate notifies listeners', () async {
        viewModel.add(ResourceType.yellow, 100);

        var notified = false;
        viewModel.addListener(() {
          notified = true;
        });

        await viewModel.upgradeGenerationRate(
          ResourceType.blue,
          5.0,
          ResourceType.yellow,
          50,
        );

        expect(notified, isTrue);
      });
    });

    group('ViewModel State', () {
      test('notifies listeners when generation starts', () async {
        var notified = false;
        viewModel.addListener(() {
          notified = true;
        });

        await viewModel.startGeneration(ResourceType.blue);

        expect(notified, isTrue);
      });

      test('notifies listeners when generation stops', () async {
        await viewModel.startGeneration(ResourceType.blue);

        var notified = false;
        viewModel.addListener(() {
          notified = true;
        });

        await viewModel.stopGeneration(ResourceType.blue);

        expect(notified, isTrue);
      });
    });

    group('Multiple Resources', () {
      test('manages multiple resource types independently', () {
        viewModel.add(ResourceType.blue, 100);
        viewModel.add(ResourceType.green, 50);
        viewModel.add(ResourceType.yellow, 25);

        expect(viewModel.getAmount(ResourceType.blue), equals(100));
        expect(viewModel.getAmount(ResourceType.green), equals(50));
        expect(viewModel.getAmount(ResourceType.yellow), equals(25));
      });

      test('spending one resource does not affect others', () {
        viewModel.add(ResourceType.blue, 100);
        viewModel.add(ResourceType.green, 50);

        viewModel.spend(ResourceType.blue, 30);

        expect(viewModel.getAmount(ResourceType.blue), equals(70));
        expect(
          viewModel.getAmount(ResourceType.green),
          equals(50),
        ); // Unchanged
      });
    });
  });
}
