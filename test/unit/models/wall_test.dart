import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tower_defense_game/models/wall.dart';

void main() {
  group('Wall Model Tests', () {
    group('Constructor', () {
      test('creates wall with default values', () {
        const position = Offset(100, 200);
        final wall = Wall(position: position);

        expect(wall.position, equals(position));
        expect(wall.level, equals(1));
        expect(wall.currentHP, equals(150)); // 100 * 1.5 = 150 for level 1
        expect(wall.maxHP, equals(150));
        expect(wall.isDestroyed, isFalse);
      });

      test('creates wall with custom HP values', () {
        const position = Offset(50, 75);
        final wall = Wall(
          position: position,
          currentHP: 80,
          maxHP: 120,
          level: 2,
        );

        expect(wall.position, equals(position));
        expect(wall.level, equals(2));
        expect(wall.currentHP, equals(80));
        expect(wall.maxHP, equals(120));
      });

      test('throws error with invalid level', () {
        expect(
          () => Wall(position: const Offset(100, 100), level: 0),
          throwsA(isA<StateError>()),
        );
      });

      test('throws error with invalid HP values', () {
        expect(
          () =>
              Wall(position: const Offset(100, 100), currentHP: -5, maxHP: 100),
          throwsA(isA<StateError>()),
        );

        expect(
          () => Wall(
            position: const Offset(100, 100),
            currentHP: 150,
            maxHP: 100,
          ),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('HP Calculation', () {
      test('calculates correct max HP for different levels', () {
        final wall1 = Wall(position: const Offset(0, 0), level: 1);
        expect(wall1.maxHP, equals(150)); // 100 * 1.5

        final wall2 = Wall(position: const Offset(0, 0), level: 2);
        expect(wall2.maxHP, equals(300)); // 100 * (1.5 * 2)

        final wall3 = Wall(position: const Offset(0, 0), level: 3);
        expect(wall3.maxHP, equals(450)); // 100 * (1.5 * 3)
      });

      test('health percentage calculates correctly', () {
        final wall = Wall(
          position: const Offset(0, 0),
          currentHP: 75,
          maxHP: 150,
        );

        expect(wall.healthPercentage, equals(0.5));
      });

      test('health percentage handles edge cases', () {
        final wallDead = Wall(
          position: const Offset(0, 0),
          currentHP: 0,
          maxHP: 150,
        );
        expect(wallDead.healthPercentage, equals(0.0));

        final wallFull = Wall(
          position: const Offset(0, 0),
          currentHP: 150,
          maxHP: 150,
        );
        expect(wallFull.healthPercentage, equals(1.0));
      });
    });

    group('Wall State', () {
      test('detects destroyed state correctly', () {
        final wallAlive = Wall(
          position: const Offset(0, 0),
          currentHP: 50,
          maxHP: 150,
        );
        expect(wallAlive.isDestroyed, isFalse);

        final wallDead = Wall(
          position: const Offset(0, 0),
          currentHP: 0,
          maxHP: 150,
        );
        expect(wallDead.isDestroyed, isTrue);
      });
    });

    group('Wall Appearance', () {
      test('returns correct colors for different levels', () {
        final wall1 = Wall(position: const Offset(0, 0), level: 1);
        expect(wall1.color, equals(Colors.grey));

        final wall2 = Wall(position: const Offset(0, 0), level: 2);
        expect(wall2.color, equals(Colors.brown));

        final wall3 = Wall(position: const Offset(0, 0), level: 3);
        expect(wall3.color, equals(Colors.orange));

        final wall4 = Wall(position: const Offset(0, 0), level: 4);
        expect(wall4.color, equals(Colors.red));

        final wall5 = Wall(position: const Offset(0, 0), level: 5);
        expect(wall5.color, equals(Colors.purple));

        // Test clamping for high levels
        final wall10 = Wall(position: const Offset(0, 0), level: 10);
        expect(wall10.color, equals(Colors.purple));
      });
    });

    group('Wall Upgrade', () {
      test('upgrade increases level and max HP', () {
        final wall = Wall(position: const Offset(0, 0), level: 1);
        final initialMaxHP = wall.maxHP;
        final initialCurrentHP = wall.currentHP;

        wall.upgrade();

        expect(wall.level, equals(2));
        expect(wall.maxHP, greaterThan(initialMaxHP));
        // Current HP should increase proportionally
        expect(wall.currentHP, greaterThanOrEqualTo(initialCurrentHP));
      });

      test('upgrade preserves position', () {
        const position = Offset(123, 456);
        final wall = Wall(position: position);

        wall.upgrade();

        expect(wall.position, equals(position));
      });
    });

    group('Wall Damage and Healing', () {
      test('takeDamage reduces current HP', () {
        final wall = Wall(
          position: const Offset(0, 0),
          currentHP: 100,
          maxHP: 150,
        );

        wall.takeDamage(30);
        expect(wall.currentHP, equals(70));
        expect(wall.maxHP, equals(150)); // Max HP unchanged
      });

      test('takeDamage cannot reduce HP below zero', () {
        final wall = Wall(
          position: const Offset(0, 0),
          currentHP: 20,
          maxHP: 150,
        );

        wall.takeDamage(50);
        expect(wall.currentHP, equals(0));
        expect(wall.isDestroyed, isTrue);
      });

      test('heal increases current HP up to max', () {
        final wall = Wall(
          position: const Offset(0, 0),
          currentHP: 50,
          maxHP: 150,
        );

        wall.heal(30);
        expect(wall.currentHP, equals(80));
        expect(wall.maxHP, equals(150)); // Max HP unchanged
      });

      test('heal cannot exceed max HP', () {
        final wall = Wall(
          position: const Offset(0, 0),
          currentHP: 140,
          maxHP: 150,
        );

        wall.heal(30);
        expect(wall.currentHP, equals(150)); // Capped at max
      });

      test('fullHeal restores to maximum HP', () {
        final wall = Wall(
          position: const Offset(0, 0),
          currentHP: 50,
          maxHP: 150,
        );

        wall.fullHeal();
        expect(wall.currentHP, equals(wall.maxHP));
      });

      test('damage and heal throw errors with invalid amounts', () {
        final wall = Wall(position: const Offset(0, 0));

        expect(() => wall.takeDamage(-5), throwsA(isA<ArgumentError>()));
        expect(() => wall.heal(-10), throwsA(isA<ArgumentError>()));
      });
    });

    group('Wall Equality', () {
      test('walls with same properties are equal', () {
        final wall1 = Wall(
          position: const Offset(100, 200),
          currentHP: 80,
          maxHP: 150,
          level: 2,
        );

        final wall2 = Wall(
          position: const Offset(100, 200),
          currentHP: 80,
          maxHP: 150,
          level: 2,
        );

        expect(wall1, equals(wall2));
        expect(wall1.hashCode, equals(wall2.hashCode));
      });

      test('walls with different properties are not equal', () {
        final wall1 = Wall(position: const Offset(100, 200), level: 1);
        final wall2 = Wall(position: const Offset(100, 200), level: 2);

        expect(wall1, isNot(equals(wall2)));
      });
    });

    group('Wall String Representation', () {
      test('toString provides readable wall state', () {
        final wall = Wall(
          position: const Offset(100, 200),
          currentHP: 80,
          maxHP: 150,
          level: 2,
        );

        final wallString = wall.toString();
        expect(wallString, contains('Wall'));
        expect(wallString, contains('level: 2'));
        expect(wallString, contains('HP: 80/150'));
        expect(wallString, contains('position: Offset(100.0, 200.0)'));
      });
    });
  });
}
