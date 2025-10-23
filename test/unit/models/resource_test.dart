import 'package:flutter_test/flutter_test.dart';
import 'package:tower_defense_game/models/resource.dart';
import 'package:tower_defense_game/models/game_enums.dart';

void main() {
  group('Resource Model Tests', () {
    group('Constructor', () {
      test('creates resource with default values', () {
        final resource = Resource(type: ResourceType.blue);

        expect(resource.type, equals(ResourceType.blue));
        expect(resource.amount, equals(0));
        expect(resource.generationRate, equals(0.0));
        expect(resource.isGenerating, isFalse);
      });

      test('creates resource with custom values', () {
        final resource = Resource(
          type: ResourceType.green,
          amount: 100,
          generationRate: 5.5,
          isGenerating: true,
        );

        expect(resource.type, equals(ResourceType.green));
        expect(resource.amount, equals(100));
        expect(resource.generationRate, equals(5.5));
        expect(resource.isGenerating, isTrue);
      });

      test('throws error with negative amount', () {
        expect(
          () => Resource(type: ResourceType.blue, amount: -10),
          throwsA(isA<StateError>()),
        );
      });

      test('throws error with negative generation rate', () {
        expect(
          () => Resource(type: ResourceType.blue, generationRate: -1.5),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('Resource Spending', () {
      test('canAfford returns true when sufficient resources', () {
        final resource = Resource(type: ResourceType.blue, amount: 100);

        expect(resource.canAfford(50), isTrue);
        expect(resource.canAfford(100), isTrue);
        expect(resource.canAfford(0), isTrue);
      });

      test('canAfford returns false when insufficient resources', () {
        final resource = Resource(type: ResourceType.blue, amount: 50);

        expect(resource.canAfford(51), isFalse);
        expect(resource.canAfford(100), isFalse);
      });

      test('canAfford returns false with negative cost', () {
        final resource = Resource(type: ResourceType.blue, amount: 100);

        expect(resource.canAfford(-10), isFalse);
      });

      test('spend reduces amount when affordable', () {
        final resource = Resource(type: ResourceType.blue, amount: 100);

        final success = resource.spend(30);

        expect(success, isTrue);
        expect(resource.amount, equals(70));
      });

      test('spend returns false when not affordable', () {
        final resource = Resource(type: ResourceType.blue, amount: 50);

        final success = resource.spend(60);

        expect(success, isFalse);
        expect(resource.amount, equals(50)); // Amount unchanged
      });

      test('spend handles exact amount', () {
        final resource = Resource(type: ResourceType.blue, amount: 100);

        final success = resource.spend(100);

        expect(success, isTrue);
        expect(resource.amount, equals(0));
      });
    });

    group('Resource Addition', () {
      test('add increases resource amount', () {
        final resource = Resource(type: ResourceType.blue, amount: 50);

        resource.add(25);

        expect(resource.amount, equals(75));
      });

      test('add throws error with negative amount', () {
        final resource = Resource(type: ResourceType.blue, amount: 50);

        expect(() => resource.add(-10), throwsA(isA<ArgumentError>()));
      });

      test('add handles zero', () {
        final resource = Resource(type: ResourceType.blue, amount: 50);

        resource.add(0);

        expect(resource.amount, equals(50));
      });
    });

    group('Resource Generation', () {
      test('startGeneration enables resource generation', () {
        final resource = Resource(type: ResourceType.blue);

        expect(resource.isGenerating, isFalse);

        resource.startGeneration();

        expect(resource.isGenerating, isTrue);
      });

      test('stopGeneration disables resource generation', () {
        final resource = Resource(type: ResourceType.blue, isGenerating: true);

        resource.stopGeneration();

        expect(resource.isGenerating, isFalse);
      });

      test('generateResources does nothing when not generating', () {
        final resource = Resource(
          type: ResourceType.blue,
          amount: 10,
          generationRate: 5.0,
          isGenerating: false,
        );

        resource.generateResources();

        expect(resource.amount, equals(10)); // No change
      });

      test('generateResources does nothing with zero rate', () {
        final resource = Resource(
          type: ResourceType.blue,
          amount: 10,
          generationRate: 0.0,
          isGenerating: true,
        );

        resource.generateResources();

        expect(resource.amount, equals(10)); // No change
      });

      test('generateResources increases amount over time', () {
        final resource = Resource(
          type: ResourceType.blue,
          amount: 10,
          generationRate: 10.0, // 10 per second
          isGenerating: true,
        );

        // Simulate 60 frames (1 second at 60 FPS)
        for (var i = 0; i < 60; i++) {
          resource.generateResources();
        }

        // Should have generated 10 resources (10/sec * 1 sec)
        expect(resource.amount, greaterThan(10));
        expect(resource.amount, greaterThanOrEqualTo(20)); // 10 initial + 10 generated
      });
    });

    group('Generation Rate Management', () {
      test('upgradeGenerationRate increases rate', () {
        final resource = Resource(type: ResourceType.blue, generationRate: 5.0);

        resource.upgradeGenerationRate(2.5);

        expect(resource.generationRate, equals(7.5));
      });

      test('upgradeGenerationRate throws error with negative value', () {
        final resource = Resource(type: ResourceType.blue);

        expect(
          () => resource.upgradeGenerationRate(-1.0),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('setGenerationRate sets specific rate', () {
        final resource = Resource(type: ResourceType.blue, generationRate: 5.0);

        resource.setGenerationRate(10.0);

        expect(resource.generationRate, equals(10.0));
      });

      test('setGenerationRate throws error with negative value', () {
        final resource = Resource(type: ResourceType.blue);

        expect(
          () => resource.setGenerationRate(-5.0),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('Resource Reset', () {
      test('reset returns resource to initial state', () {
        final resource = Resource(
          type: ResourceType.blue,
          amount: 100,
          generationRate: 5.0,
          isGenerating: true,
        );

        resource.reset();

        expect(resource.amount, equals(0));
        expect(resource.generationRate, equals(0.0));
        expect(resource.isGenerating, isFalse);
      });
    });

    group('Resource Copy', () {
      test('copyWith creates new instance with updated values', () {
        final original = Resource(
          type: ResourceType.blue,
          amount: 50,
          generationRate: 3.0,
        );

        final copy = original.copyWith(amount: 100, generationRate: 5.0);

        expect(copy.type, equals(ResourceType.blue));
        expect(copy.amount, equals(100));
        expect(copy.generationRate, equals(5.0));

        // Original unchanged
        expect(original.amount, equals(50));
        expect(original.generationRate, equals(3.0));
      });

      test('copyWith preserves unspecified values', () {
        final original = Resource(
          type: ResourceType.green,
          amount: 75,
          generationRate: 4.0,
          isGenerating: true,
        );

        final copy = original.copyWith(amount: 100);

        expect(copy.type, equals(ResourceType.green));
        expect(copy.amount, equals(100));
        expect(copy.generationRate, equals(4.0));
        expect(copy.isGenerating, isTrue);
      });
    });

    group('Resource Equality', () {
      test('resources with same properties are equal', () {
        final resource1 = Resource(
          type: ResourceType.blue,
          amount: 50,
          generationRate: 3.0,
          isGenerating: true,
        );

        final resource2 = Resource(
          type: ResourceType.blue,
          amount: 50,
          generationRate: 3.0,
          isGenerating: true,
        );

        expect(resource1, equals(resource2));
        expect(resource1.hashCode, equals(resource2.hashCode));
      });

      test('resources with different properties are not equal', () {
        final resource1 = Resource(type: ResourceType.blue, amount: 50);
        final resource2 = Resource(type: ResourceType.blue, amount: 75);

        expect(resource1, isNot(equals(resource2)));
      });

      test('resources with different types are not equal', () {
        final resource1 = Resource(type: ResourceType.blue, amount: 50);
        final resource2 = Resource(type: ResourceType.green, amount: 50);

        expect(resource1, isNot(equals(resource2)));
      });
    });

    group('Resource String Representation', () {
      test('toString provides readable resource state', () {
        final resource = Resource(
          type: ResourceType.blue,
          amount: 100,
          generationRate: 5.5,
          isGenerating: true,
        );

        final resourceString = resource.toString();
        expect(resourceString, contains('Resource'));
        expect(resourceString, contains('Blue')); // Display name
        expect(resourceString, contains('amount: 100'));
        expect(resourceString, contains('rate: 5.5'));
        expect(resourceString, contains('generating: true'));
      });
    });
  });
}
