import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tower_defense_game/models/enemy.dart';
import 'package:tower_defense_game/models/game_enums.dart';

void main() {
  group('Enemy Model Tests', () {
    const startPosition = Offset(100, 100);
    const targetPosition = Offset(500, 500);

    group('Constructor', () {
      test('creates enemy with default values from type', () {
        final enemy = Enemy(
          type: EnemyType.basic,
          position: startPosition,
          target: targetPosition,
        );

        expect(enemy.type, equals(EnemyType.basic));
        expect(enemy.position, equals(startPosition));
        expect(enemy.target, equals(targetPosition));
        expect(enemy.hp, equals(EnemyType.basic.baseHp));
        expect(enemy.damage, equals(EnemyType.basic.baseDamage));
        expect(enemy.speed, equals(EnemyType.basic.baseSpeed));
        expect(enemy.isAlive, isTrue);
        expect(enemy.attackCooldown, equals(0));
      });

      test('creates enemy with custom values', () {
        final enemy = Enemy(
          type: EnemyType.basic,
          position: startPosition,
          target: targetPosition,
          hp: 150,
          damage: 25,
          speed: 100.0,
          attackCooldown: 30,
        );

        expect(enemy.hp, equals(150));
        expect(enemy.damage, equals(25));
        expect(enemy.speed, equals(100.0));
        expect(enemy.attackCooldown, equals(30));
      });

      test('throws error with negative values', () {
        expect(
          () => Enemy(
            type: EnemyType.basic,
            position: startPosition,
            target: targetPosition,
            hp: -10,
          ),
          throwsA(isA<StateError>()),
        );

        expect(
          () => Enemy(
            type: EnemyType.basic,
            position: startPosition,
            target: targetPosition,
            damage: -5,
          ),
          throwsA(isA<StateError>()),
        );

        expect(
          () => Enemy(
            type: EnemyType.basic,
            position: startPosition,
            target: targetPosition,
            speed: -50.0,
          ),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('Enemy State', () {
      test('isAlive returns true for healthy enemy', () {
        final enemy = Enemy(
          type: EnemyType.basic,
          position: startPosition,
          target: targetPosition,
        );

        expect(enemy.isAlive, isTrue);
      });

      test('canAttack returns true when alive and cooldown is zero', () {
        final enemy = Enemy(
          type: EnemyType.basic,
          position: startPosition,
          target: targetPosition,
          attackCooldown: 0,
        );

        expect(enemy.canAttack, isTrue);
      });

      test('canAttack returns false when cooldown is active', () {
        final enemy = Enemy(
          type: EnemyType.basic,
          position: startPosition,
          target: targetPosition,
          attackCooldown: 30,
        );

        expect(enemy.canAttack, isFalse);
      });

      test('canAttack returns false when dead', () {
        final enemy = Enemy(
          type: EnemyType.basic,
          position: startPosition,
          target: targetPosition,
          hp: 0,
        );

        enemy.takeDamage(enemy.hp);
        expect(enemy.isAlive, isFalse);
        expect(enemy.canAttack, isFalse);
      });
    });

    group('Distance Calculation', () {
      test('distanceToTarget calculates correct squared distance', () {
        final enemy = Enemy(
          type: EnemyType.basic,
          position: const Offset(0, 0),
          target: const Offset(3, 4),
        );

        // Distance should be 3^2 + 4^2 = 25 (squared distance)
        expect(enemy.distanceToTarget, equals(25.0));
      });

      test('hasReachedTarget returns true when within attack range', () {
        final enemy = Enemy(
          type: EnemyType.basic,
          position: const Offset(490, 490),
          target: const Offset(500, 500),
        );

        // Distance is approximately 14.14, within 50 pixel range
        expect(enemy.hasReachedTarget, isTrue);
      });

      test('hasReachedTarget returns false when outside attack range', () {
        final enemy = Enemy(
          type: EnemyType.basic,
          position: const Offset(100, 100),
          target: const Offset(500, 500),
        );

        // Distance is much greater than 50 pixels
        expect(enemy.hasReachedTarget, isFalse);
      });
    });

    group('Movement', () {
      test('moveTowardTarget updates position toward target', () {
        final enemy = Enemy(
          type: EnemyType.basic,
          position: const Offset(100, 100),
          target: const Offset(200, 100),
          speed: 50.0,
        );

        final initialX = enemy.position.dx;
        enemy.moveTowardTarget(1.0); // 1 second

        expect(enemy.position.dx, greaterThan(initialX));
        expect(
          enemy.position.dy,
          equals(100.0),
        ); // Y unchanged (moving horizontally)
      });

      test('moveTowardTarget does not move dead enemy', () {
        final enemy = Enemy(
          type: EnemyType.basic,
          position: const Offset(100, 100),
          target: const Offset(200, 100),
          speed: 50.0,
        );

        enemy.kill();
        final positionBeforeMove = enemy.position;
        enemy.moveTowardTarget(1.0);

        expect(enemy.position, equals(positionBeforeMove));
      });

      test('moveTowardTarget moves at correct speed', () {
        final enemy = Enemy(
          type: EnemyType.basic,
          position: const Offset(0, 0),
          target: const Offset(100, 0),
          speed: 50.0,
        );

        enemy.moveTowardTarget(1.0); // 1 second at 50 pixels/second

        expect(enemy.position.dx, closeTo(50.0, 0.1));
        expect(enemy.position.dy, closeTo(0.0, 0.1));
      });

      test('moveTowardTarget handles diagonal movement', () {
        final enemy = Enemy(
          type: EnemyType.basic,
          position: const Offset(0, 0),
          target: const Offset(100, 100),
          speed: 50.0,
        );

        final initialPosition = enemy.position;
        enemy.moveTowardTarget(1.0);

        // Should move toward diagonal
        expect(enemy.position.dx, greaterThan(initialPosition.dx));
        expect(enemy.position.dy, greaterThan(initialPosition.dy));
      });
    });

    group('Combat', () {
      test('takeDamage reduces HP', () {
        final enemy = Enemy(
          type: EnemyType.basic,
          position: startPosition,
          target: targetPosition,
        );

        final initialHP = enemy.hp;
        enemy.takeDamage(20);

        expect(enemy.hp, equals(initialHP - 20));
        expect(enemy.isAlive, isTrue);
      });

      test('takeDamage kills enemy when HP reaches zero', () {
        final enemy = Enemy(
          type: EnemyType.basic,
          position: startPosition,
          target: targetPosition,
          hp: 30,
        );

        enemy.takeDamage(30);

        expect(enemy.hp, equals(0));
        expect(enemy.isAlive, isFalse);
      });

      test('takeDamage cannot reduce HP below zero', () {
        final enemy = Enemy(
          type: EnemyType.basic,
          position: startPosition,
          target: targetPosition,
          hp: 30,
        );

        enemy.takeDamage(50);

        expect(enemy.hp, equals(0));
        expect(enemy.isAlive, isFalse);
      });

      test('takeDamage throws error with negative damage', () {
        final enemy = Enemy(
          type: EnemyType.basic,
          position: startPosition,
          target: targetPosition,
        );

        expect(() => enemy.takeDamage(-10), throwsA(isA<ArgumentError>()));
      });

      test('attack returns damage when can attack', () {
        final enemy = Enemy(
          type: EnemyType.basic,
          position: startPosition,
          target: targetPosition,
        );

        final damageDealt = enemy.attack();

        expect(damageDealt, equals(enemy.damage));
        expect(enemy.attackCooldown, greaterThan(0));
      });

      test('attack returns zero when on cooldown', () {
        final enemy = Enemy(
          type: EnemyType.basic,
          position: startPosition,
          target: targetPosition,
          attackCooldown: 30,
        );

        final damageDealt = enemy.attack();

        expect(damageDealt, equals(0));
      });

      test('attack sets cooldown after attacking', () {
        final enemy = Enemy(
          type: EnemyType.basic,
          position: startPosition,
          target: targetPosition,
        );

        expect(enemy.attackCooldown, equals(0));
        enemy.attack();
        expect(enemy.attackCooldown, equals(60)); // 1 second at 60 FPS
      });

      test('kill immediately kills enemy', () {
        final enemy = Enemy(
          type: EnemyType.basic,
          position: startPosition,
          target: targetPosition,
        );

        expect(enemy.isAlive, isTrue);
        enemy.kill();

        expect(enemy.hp, equals(0));
        expect(enemy.isAlive, isFalse);
      });
    });

    group('Cooldown Management', () {
      test('updateCooldown decrements cooldown', () {
        final enemy = Enemy(
          type: EnemyType.basic,
          position: startPosition,
          target: targetPosition,
          attackCooldown: 60,
        );

        enemy.updateCooldown();

        expect(enemy.attackCooldown, equals(59));
      });

      test('updateCooldown does not go below zero', () {
        final enemy = Enemy(
          type: EnemyType.basic,
          position: startPosition,
          target: targetPosition,
          attackCooldown: 0,
        );

        enemy.updateCooldown();

        expect(enemy.attackCooldown, equals(0));
      });

      test('cooldown reaches zero after multiple updates', () {
        final enemy = Enemy(
          type: EnemyType.basic,
          position: startPosition,
          target: targetPosition,
          attackCooldown: 3,
        );

        enemy.updateCooldown();
        enemy.updateCooldown();
        enemy.updateCooldown();

        expect(enemy.attackCooldown, equals(0));
        expect(enemy.canAttack, isTrue);
      });
    });

    group('Level Scaling', () {
      test('scaleForLevel increases HP and damage', () {
        final enemy = Enemy(
          type: EnemyType.basic,
          position: startPosition,
          target: targetPosition,
        );

        final initialHP = enemy.hp;
        final initialDamage = enemy.damage;

        enemy.scaleForLevel(2);

        expect(enemy.hp, greaterThan(initialHP));
        expect(enemy.damage, greaterThan(initialDamage));
      });

      test('scaleForLevel at level 1 uses base stats', () {
        final enemy = Enemy(
          type: EnemyType.basic,
          position: startPosition,
          target: targetPosition,
        );

        final baseHP = EnemyType.basic.baseHp;
        final baseDamage = EnemyType.basic.baseDamage;

        enemy.scaleForLevel(1);

        expect(enemy.hp, equals(baseHP));
        expect(enemy.damage, equals(baseDamage));
      });

      test('scaleForLevel scales exponentially', () {
        final enemy = Enemy(
          type: EnemyType.basic,
          position: startPosition,
          target: targetPosition,
        );

        enemy.scaleForLevel(5);

        // At level 5: scale = 1.0 + (5-1)*0.2 = 1.8
        final expectedHP = (EnemyType.basic.baseHp * 1.8).round();
        final expectedDamage = (EnemyType.basic.baseDamage * 1.8).round();

        expect(enemy.hp, equals(expectedHP));
        expect(enemy.damage, equals(expectedDamage));
      });

      test('scaleForLevel throws error with invalid level', () {
        final enemy = Enemy(
          type: EnemyType.basic,
          position: startPosition,
          target: targetPosition,
        );

        expect(() => enemy.scaleForLevel(0), throwsA(isA<ArgumentError>()));
        expect(() => enemy.scaleForLevel(-1), throwsA(isA<ArgumentError>()));
      });
    });

    group('Enemy Copy', () {
      test('copyWith creates new instance with updated values', () {
        final original = Enemy(
          type: EnemyType.basic,
          position: startPosition,
          target: targetPosition,
          hp: 100,
        );

        final copy = original.copyWith(hp: 150);

        expect(copy.hp, equals(150));
        expect(copy.type, equals(original.type));
        expect(copy.position, equals(original.position));

        // Original unchanged
        expect(original.hp, equals(100));
      });

      test('copyWith preserves unspecified values', () {
        final original = Enemy(
          type: EnemyType.basic,
          position: startPosition,
          target: targetPosition,
          hp: 100,
          damage: 20,
        );

        final copy = original.copyWith(hp: 150);

        expect(copy.hp, equals(150));
        expect(copy.damage, equals(20)); // Preserved
      });
    });

    group('Enemy Equality', () {
      test('enemies with same properties are equal', () {
        final enemy1 = Enemy(
          type: EnemyType.basic,
          position: startPosition,
          target: targetPosition,
          hp: 100,
          damage: 20,
        );

        final enemy2 = Enemy(
          type: EnemyType.basic,
          position: startPosition,
          target: targetPosition,
          hp: 100,
          damage: 20,
        );

        expect(enemy1, equals(enemy2));
        expect(enemy1.hashCode, equals(enemy2.hashCode));
      });

      test('enemies with different properties are not equal', () {
        final enemy1 = Enemy(
          type: EnemyType.basic,
          position: startPosition,
          target: targetPosition,
        );

        final enemy2 = Enemy(
          type: EnemyType.fast,
          position: startPosition,
          target: targetPosition,
        );

        expect(enemy1, isNot(equals(enemy2)));
      });
    });

    group('Enemy String Representation', () {
      test('toString provides readable enemy state', () {
        final enemy = Enemy(
          type: EnemyType.basic,
          position: startPosition,
          target: targetPosition,
        );

        final enemyString = enemy.toString();
        expect(enemyString, contains('Enemy'));
        expect(enemyString, contains('Basic'));
        expect(enemyString, contains('HP:'));
        expect(enemyString, contains('pos:'));
        expect(enemyString, contains('alive: true'));
      });
    });

    group('Enemy Types', () {
      test('different enemy types have different stats', () {
        final basicEnemy = Enemy(
          type: EnemyType.basic,
          position: startPosition,
          target: targetPosition,
        );

        final fastEnemy = Enemy(
          type: EnemyType.fast,
          position: startPosition,
          target: targetPosition,
        );

        final strongEnemy = Enemy(
          type: EnemyType.strong,
          position: startPosition,
          target: targetPosition,
        );

        // Fast enemy should have higher speed
        expect(fastEnemy.speed, greaterThan(basicEnemy.speed));

        // Strong enemy should have higher HP
        expect(strongEnemy.hp, greaterThan(basicEnemy.hp));
      });
    });
  });
}
