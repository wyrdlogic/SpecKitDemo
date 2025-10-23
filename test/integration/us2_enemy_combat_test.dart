import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tower_defense_game/models/game_enums.dart';
import 'package:tower_defense_game/viewmodels/enemy_viewmodel.dart';
import 'package:tower_defense_game/viewmodels/wall_viewmodel.dart';

/// Integration tests for User Story 2: Enemy Combat and Wall Health Management
///
/// Tests the complete enemy combat flow including:
/// - Enemy spawning with different types
/// - Enemy movement toward wall
/// - Wall damage from enemy attacks
/// - Enemy death and removal
/// - Combat cycle timing
void main() {
  group('US2: Enemy Combat and Wall Health Management Integration Tests', () {
    late EnemyViewModel enemyVM;
    late WallViewModel wallVM;

    setUp(() {
      enemyVM = EnemyViewModel();
      wallVM = WallViewModel(wallPosition: const Offset(400, 300));
    });

    tearDown(() {
      enemyVM.dispose();
      wallVM.dispose();
    });

    group('Enemy Spawning Flow', () {
      test('basic enemy spawns with correct attributes', () {
        const spawnPos = Offset(100, 100);
        const targetPos = Offset(400, 300);

        enemyVM.spawnEnemy(
          type: EnemyType.basic,
          position: spawnPos,
          target: targetPos,
          level: 1,
        );

        expect(enemyVM.enemies.length, equals(1));
        expect(enemyVM.activeEnemyCount, equals(1));

        final enemy = enemyVM.enemies.first;
        expect(enemy.type, equals(EnemyType.basic));
        expect(enemy.position, equals(spawnPos));
        expect(enemy.target, equals(targetPos));
        expect(enemy.isAlive, isTrue);
      });

      test('multiple enemy types can spawn simultaneously', () {
        const spawnPos = Offset(100, 100);
        const targetPos = Offset(400, 300);

        // Spawn different enemy types
        enemyVM.spawnEnemy(
          type: EnemyType.basic,
          position: spawnPos,
          target: targetPos,
          level: 1,
        );

        enemyVM.spawnEnemy(
          type: EnemyType.fast,
          position: const Offset(150, 100),
          target: targetPos,
          level: 1,
        );

        enemyVM.spawnEnemy(
          type: EnemyType.strong,
          position: const Offset(200, 100),
          target: targetPos,
          level: 1,
        );

        expect(enemyVM.enemies.length, equals(3));
        expect(enemyVM.activeEnemyCount, equals(3));

        // Verify different types
        final types = enemyVM.enemies.map((e) => e.type).toSet();
        expect(types.length, equals(3));
      });

      test('enemies scale correctly with level', () {
        const spawnPos = Offset(100, 100);
        const targetPos = Offset(400, 300);

        // Level 1 enemy
        enemyVM.spawnEnemy(
          type: EnemyType.basic,
          position: spawnPos,
          target: targetPos,
          level: 1,
        );
        final level1Enemy = enemyVM.enemies.first;
        final level1HP = level1Enemy.hp;
        final level1Damage = level1Enemy.damage;

        enemyVM.clearAll();

        // Level 5 enemy
        enemyVM.spawnEnemy(
          type: EnemyType.basic,
          position: spawnPos,
          target: targetPos,
          level: 5,
        );
        final level5Enemy = enemyVM.enemies.first;

        expect(level5Enemy.hp, greaterThan(level1HP));
        expect(level5Enemy.damage, greaterThan(level1Damage));
      });
    });

    group('Enemy Movement Flow', () {
      test('enemy moves toward target over multiple frames', () {
        const spawnPos = Offset(100, 100);
        const targetPos = Offset(400, 300);

        enemyVM.spawnEnemy(
          type: EnemyType.basic,
          position: spawnPos,
          target: targetPos,
          level: 1,
        );

        final enemy = enemyVM.enemies.first;
        final startPos = enemy.position;

        // Simulate multiple frames
        for (var i = 0; i < 30; i++) {
          enemyVM.updateEnemies(1 / 60); // 60 FPS
        }

        final endPos = enemy.position;

        // Enemy should have moved closer to target
        final startDistance = (startPos - targetPos).distance;
        final endDistance = (endPos - targetPos).distance;

        expect(endDistance, lessThan(startDistance));
      });

      test('fast enemy moves faster than basic enemy', () {
        const spawnPos = Offset(100, 100);
        const targetPos = Offset(400, 300);

        // Spawn basic enemy
        enemyVM.spawnEnemy(
          type: EnemyType.basic,
          position: spawnPos,
          target: targetPos,
          level: 1,
        );

        // Spawn fast enemy
        enemyVM.spawnEnemy(
          type: EnemyType.fast,
          position: spawnPos,
          target: targetPos,
          level: 1,
        );

        final basicEnemy = enemyVM.enemies[0];
        final fastEnemy = enemyVM.enemies[1];

        final basicStartPos = basicEnemy.position;
        final fastStartPos = fastEnemy.position;

        // Simulate frames
        for (var i = 0; i < 30; i++) {
          enemyVM.updateEnemies(1 / 60);
        }

        final basicDistance = (basicEnemy.position - basicStartPos).distance;
        final fastDistance = (fastEnemy.position - fastStartPos).distance;

        expect(fastDistance, greaterThan(basicDistance));
      });

      test('enemy reaches target position', () {
        const spawnPos = Offset(100, 100);
        const targetPos = Offset(150, 150);

        enemyVM.spawnEnemy(
          type: EnemyType.fast, // Use fast for quicker test
          position: spawnPos,
          target: targetPos,
          level: 1,
        );

        final enemy = enemyVM.enemies.first;

        // Simulate enough frames for enemy to reach target
        for (var i = 0; i < 300; i++) {
          enemyVM.updateEnemies(1 / 60);

          if (enemy.hasReachedTarget) {
            break;
          }
        }

        expect(enemy.hasReachedTarget, isTrue);
      });
    });

    group('Combat Mechanics Flow', () {
      test('enemy can attack wall when in range', () {
        const targetPos = Offset(400, 300);

        enemyVM.spawnEnemy(
          type: EnemyType.basic,
          position: targetPos, // Spawn at wall position
          target: targetPos,
          level: 1,
        );

        final enemy = enemyVM.enemies.first;
        final initialWallHP = wallVM.currentHP;

        // Enemy should be able to attack
        expect(enemy.canAttack, isTrue);

        // Simulate attack
        if (enemy.canAttack) {
          final damage = enemy.attack();
          wallVM.takeDamage(damage);
        }

        expect(wallVM.currentHP, lessThan(initialWallHP));
        expect(enemy.canAttack, isFalse); // Should be on cooldown
      });

      test('enemy attack cooldown works correctly', () {
        const targetPos = Offset(400, 300);

        enemyVM.spawnEnemy(
          type: EnemyType.basic,
          position: targetPos,
          target: targetPos,
          level: 1,
        );

        final enemy = enemyVM.enemies.first;

        // Perform attack
        enemy.attack();
        expect(enemy.canAttack, isFalse);

        // Simulate frames until cooldown expires
        for (var i = 0; i < 120; i++) {
          // 2 seconds at 60 FPS
          enemyVM.updateEnemies(1 / 60);
        }

        expect(enemy.canAttack, isTrue);
      });

      test('wall can be damaged multiple times', () {
        const targetPos = Offset(400, 300);

        enemyVM.spawnEnemy(
          type: EnemyType.basic,
          position: targetPos,
          target: targetPos,
          level: 1,
        );

        final enemy = enemyVM.enemies.first;
        final initialHP = wallVM.currentHP;

        // First attack
        wallVM.takeDamage(enemy.damage);
        final hpAfterFirstAttack = wallVM.currentHP;
        expect(hpAfterFirstAttack, lessThan(initialHP));

        // Second attack
        wallVM.takeDamage(enemy.damage);
        final hpAfterSecondAttack = wallVM.currentHP;
        expect(hpAfterSecondAttack, lessThan(hpAfterFirstAttack));
      });

      test('wall is destroyed when HP reaches zero', () {
        expect(wallVM.isDestroyed, isFalse);

        // Deal massive damage
        wallVM.takeDamage(10000);

        expect(wallVM.isDestroyed, isTrue);
        expect(wallVM.currentHP, equals(0));
      });
    });

    group('Enemy Death and Removal Flow', () {
      test('enemy dies when HP reaches zero', () {
        const spawnPos = Offset(100, 100);
        const targetPos = Offset(400, 300);

        enemyVM.spawnEnemy(
          type: EnemyType.basic,
          position: spawnPos,
          target: targetPos,
          level: 1,
        );

        final enemy = enemyVM.enemies.first;
        expect(enemy.isAlive, isTrue);

        // Kill enemy
        enemyVM.killEnemy(enemy);

        expect(enemy.isAlive, isFalse);
        expect(enemyVM.activeEnemyCount, equals(0));
      });

      test('dead enemies can be removed', () {
        const spawnPos = Offset(100, 100);
        const targetPos = Offset(400, 300);

        enemyVM.spawnEnemy(
          type: EnemyType.basic,
          position: spawnPos,
          target: targetPos,
          level: 1,
        );

        final enemy = enemyVM.enemies.first;
        enemyVM.killEnemy(enemy);

        expect(enemyVM.enemies.length, equals(1));
        expect(enemyVM.activeEnemyCount, equals(0));

        enemyVM.removeDeadEnemies();

        expect(enemyVM.enemies.length, equals(0));
      });

      test('multiple dead enemies are removed together', () {
        const spawnPos = Offset(100, 100);
        const targetPos = Offset(400, 300);

        // Spawn 3 enemies
        for (var i = 0; i < 3; i++) {
          enemyVM.spawnEnemy(
            type: EnemyType.basic,
            position: spawnPos,
            target: targetPos,
            level: 1,
          );
        }

        expect(enemyVM.enemies.length, equals(3));

        // Kill 2 enemies
        enemyVM.killEnemy(enemyVM.enemies[0]);
        enemyVM.killEnemy(enemyVM.enemies[1]);

        expect(enemyVM.activeEnemyCount, equals(1));

        // Remove dead
        enemyVM.removeDeadEnemies();

        expect(enemyVM.enemies.length, equals(1));
        expect(enemyVM.activeEnemyCount, equals(1));
      });
    });

    group('Complete Combat Cycle', () {
      test('full combat flow: spawn → move → attack → kill', () {
        const spawnPos = Offset(100, 100);
        final wallPos = wallVM.position;
        final initialWallHP = wallVM.currentHP;

        // Spawn enemy
        enemyVM.spawnEnemy(
          type: EnemyType.fast, // Fast for quicker test
          position: spawnPos,
          target: wallPos,
          level: 1,
        );

        expect(enemyVM.activeEnemyCount, equals(1));

        final enemy = enemyVM.enemies.first;

        // Move enemy to wall
        for (var i = 0; i < 300; i++) {
          enemyVM.updateEnemies(1 / 60);
          if (enemy.hasReachedTarget) break;
        }

        expect(enemy.hasReachedTarget, isTrue);

        // Enemy attacks wall
        if (enemy.canAttack) {
          final damage = enemy.attack();
          wallVM.takeDamage(damage);
        }

        expect(wallVM.currentHP, lessThan(initialWallHP));

        // Kill enemy
        enemyVM.killEnemy(enemy);
        expect(enemy.isAlive, isFalse);

        // Clean up
        enemyVM.removeDeadEnemies();
        expect(enemyVM.enemies.length, equals(0));
      });

      test('multiple enemies can attack wall simultaneously', () {
        final wallPos = wallVM.position;
        final initialWallHP = wallVM.currentHP;

        // Spawn 3 enemies at wall position
        for (var i = 0; i < 3; i++) {
          enemyVM.spawnEnemy(
            type: EnemyType.basic,
            position: wallPos,
            target: wallPos,
            level: 1,
          );
        }

        expect(enemyVM.activeEnemyCount, equals(3));

        // All enemies attack
        var totalDamage = 0;
        for (final enemy in enemyVM.aliveEnemies) {
          if (enemy.canAttack) {
            totalDamage += enemy.attack();
          }
        }

        wallVM.takeDamage(totalDamage);

        expect(wallVM.currentHP, equals(initialWallHP - totalDamage));
      });

      test('combat continues until wall is destroyed or enemies are dead', () {
        final wallPos = wallVM.position;

        // Spawn strong enemy
        enemyVM.spawnEnemy(
          type: EnemyType.strong,
          position: wallPos,
          target: wallPos,
          level: 5, // High level for more damage
        );

        final enemy = enemyVM.enemies.first;

        // Simulate combat until wall destroyed
        while (!wallVM.isDestroyed && enemy.isAlive) {
          enemyVM.updateEnemies(1 / 60);

          if (enemy.canAttack) {
            final damage = enemy.attack();
            wallVM.takeDamage(damage);
          }

          // Prevent infinite loop
          if (wallVM.currentHP < wallVM.maxHP / 2) {
            break;
          }
        }

        // Wall should have taken significant damage
        expect(wallVM.currentHP, lessThan(wallVM.maxHP));
      });
    });

    group('ViewModels Integration', () {
      test('enemy and wall viewmodels work together', () {
        final wallPos = wallVM.position;
        final initialWallHP = wallVM.currentHP;
        final initialLevel = wallVM.level;

        // Spawn enemy
        enemyVM.spawnEnemy(
          type: EnemyType.basic,
          position: wallPos,
          target: wallPos,
          level: 1,
        );

        final enemy = enemyVM.enemies.first;

        // Enemy attacks
        wallVM.takeDamage(enemy.damage);

        expect(wallVM.currentHP, lessThan(initialWallHP));
        expect(wallVM.level, equals(initialLevel));
        expect(enemyVM.activeEnemyCount, equals(1));

        // Kill enemy
        enemyVM.killEnemy(enemy);
        expect(enemyVM.activeEnemyCount, equals(0));
      });

      test('viewmodels notify listeners on state changes', () {
        var enemyNotifications = 0;
        var wallNotifications = 0;

        enemyVM.addListener(() => enemyNotifications++);
        wallVM.addListener(() => wallNotifications++);

        // Spawn enemy (should notify)
        enemyVM.spawnEnemy(
          type: EnemyType.basic,
          position: const Offset(100, 100),
          target: wallVM.position,
          level: 1,
        );

        expect(enemyNotifications, greaterThan(0));

        // Damage wall (should notify)
        wallVM.takeDamage(10);

        expect(wallNotifications, greaterThan(0));
      });

      test('clearing enemies does not affect wall state', () {
        final wallPos = wallVM.position;
        final initialWallHP = wallVM.currentHP;
        final initialLevel = wallVM.level;

        // Spawn enemies
        for (var i = 0; i < 3; i++) {
          enemyVM.spawnEnemy(
            type: EnemyType.basic,
            position: wallPos,
            target: wallPos,
            level: 1,
          );
        }

        // Clear all enemies
        enemyVM.clearAll();

        expect(enemyVM.enemies.length, equals(0));
        expect(wallVM.currentHP, equals(initialWallHP));
        expect(wallVM.level, equals(initialLevel));
      });
    });
  });
}
