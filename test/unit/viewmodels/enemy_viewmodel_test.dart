import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tower_defense_game/viewmodels/enemy_viewmodel.dart';
import 'package:tower_defense_game/models/enemy.dart';
import 'package:tower_defense_game/models/game_enums.dart';

void main() {
  group('EnemyViewModel Tests', () {
    late EnemyViewModel viewModel;
    const testPosition = Offset(100, 100);
    const targetPosition = Offset(500, 500);

    setUp(() {
      viewModel = EnemyViewModel();
    });

    tearDown(() {
      viewModel.dispose();
    });

    group('Initialization', () {
      test('initializes with empty enemy list', () {
        expect(viewModel.enemies, isEmpty);
        expect(viewModel.activeEnemyCount, equals(0));
      });
    });

    group('Enemy Management', () {
      test('addEnemy adds enemy to list', () {
        final enemy = Enemy(
          type: EnemyType.basic,
          position: testPosition,
          target: targetPosition,
        );

        viewModel.addEnemy(enemy);

        expect(viewModel.enemies, contains(enemy));
        expect(viewModel.activeEnemyCount, equals(1));
      });

      test('addEnemy notifies listeners', () {
        final enemy = Enemy(
          type: EnemyType.basic,
          position: testPosition,
          target: targetPosition,
        );

        var notified = false;
        viewModel.addListener(() {
          notified = true;
        });

        viewModel.addEnemy(enemy);

        expect(notified, isTrue);
      });

      test('removeEnemy removes enemy from list', () {
        final enemy = Enemy(
          type: EnemyType.basic,
          position: testPosition,
          target: targetPosition,
        );

        viewModel.addEnemy(enemy);
        expect(viewModel.enemies, contains(enemy));

        viewModel.removeEnemy(enemy);

        expect(viewModel.enemies, isNot(contains(enemy)));
        expect(viewModel.activeEnemyCount, equals(0));
      });

      test('removeEnemy notifies listeners', () {
        final enemy = Enemy(
          type: EnemyType.basic,
          position: testPosition,
          target: targetPosition,
        );

        viewModel.addEnemy(enemy);

        var notified = false;
        viewModel.addListener(() {
          notified = true;
        });

        viewModel.removeEnemy(enemy);

        expect(notified, isTrue);
      });

      test('clearAll removes all enemies', () {
        for (var i = 0; i < 5; i++) {
          viewModel.addEnemy(
            Enemy(
              type: EnemyType.basic,
              position: Offset(i * 10.0, i * 10.0),
              target: targetPosition,
            ),
          );
        }

        expect(viewModel.activeEnemyCount, equals(5));

        viewModel.clearAll();

        expect(viewModel.enemies, isEmpty);
        expect(viewModel.activeEnemyCount, equals(0));
      });
    });

    group('Active Enemy Tracking', () {
      test('activeEnemyCount only counts alive enemies', () {
        final enemy1 = Enemy(
          type: EnemyType.basic,
          position: testPosition,
          target: targetPosition,
        );
        final enemy2 = Enemy(
          type: EnemyType.basic,
          position: testPosition,
          target: targetPosition,
        );

        viewModel.addEnemy(enemy1);
        viewModel.addEnemy(enemy2);

        expect(viewModel.activeEnemyCount, equals(2));

        enemy1.kill();

        expect(viewModel.activeEnemyCount, equals(1));
      });

      test('aliveEnemies returns only living enemies', () {
        final enemy1 = Enemy(
          type: EnemyType.basic,
          position: testPosition,
          target: targetPosition,
        );
        final enemy2 = Enemy(
          type: EnemyType.basic,
          position: testPosition,
          target: targetPosition,
        );

        viewModel.addEnemy(enemy1);
        viewModel.addEnemy(enemy2);

        enemy1.kill();

        final alive = viewModel.aliveEnemies;
        expect(alive.length, equals(1));
        expect(alive, contains(enemy2));
        expect(alive, isNot(contains(enemy1)));
      });
    });

    group('Dead Enemy Cleanup', () {
      test('removeDeadEnemies removes only dead enemies', () {
        final aliveEnemy = Enemy(
          type: EnemyType.basic,
          position: testPosition,
          target: targetPosition,
        );
        final deadEnemy = Enemy(
          type: EnemyType.basic,
          position: testPosition,
          target: targetPosition,
        );

        viewModel.addEnemy(aliveEnemy);
        viewModel.addEnemy(deadEnemy);

        deadEnemy.kill();

        viewModel.removeDeadEnemies();

        expect(viewModel.enemies, contains(aliveEnemy));
        expect(viewModel.enemies, isNot(contains(deadEnemy)));
      });

      test('removeDeadEnemies notifies listeners', () {
        final deadEnemy = Enemy(
          type: EnemyType.basic,
          position: testPosition,
          target: targetPosition,
        );

        viewModel.addEnemy(deadEnemy);
        deadEnemy.kill();

        var notified = false;
        viewModel.addListener(() {
          notified = true;
        });

        viewModel.removeDeadEnemies();

        expect(notified, isTrue);
      });
    });

    group('Enemy Updates', () {
      test('updateEnemies moves enemies toward target', () {
        final enemy = Enemy(
          type: EnemyType.basic,
          position: const Offset(0, 0),
          target: const Offset(100, 0),
          speed: 50.0,
        );

        viewModel.addEnemy(enemy);

        final initialX = enemy.position.dx;
        viewModel.updateEnemies(1.0); // 1 second

        expect(enemy.position.dx, greaterThan(initialX));
      });

      test('updateEnemies updates cooldowns', () {
        final enemy = Enemy(
          type: EnemyType.basic,
          position: testPosition,
          target: targetPosition,
          attackCooldown: 60,
        );

        viewModel.addEnemy(enemy);

        viewModel.updateEnemies(1.0);

        expect(enemy.attackCooldown, lessThan(60));
      });

      test('updateEnemies does not move dead enemies', () {
        final enemy = Enemy(
          type: EnemyType.basic,
          position: testPosition,
          target: targetPosition,
        );

        viewModel.addEnemy(enemy);
        enemy.kill();

        final positionBeforeUpdate = enemy.position;
        viewModel.updateEnemies(1.0);

        expect(enemy.position, equals(positionBeforeUpdate));
      });

      test('updateEnemies notifies listeners', () {
        final enemy = Enemy(
          type: EnemyType.basic,
          position: testPosition,
          target: targetPosition,
        );

        viewModel.addEnemy(enemy);

        var notified = false;
        viewModel.addListener(() {
          notified = true;
        });

        viewModel.updateEnemies(1.0);

        expect(notified, isTrue);
      });
    });

    group('Enemy Combat', () {
      test('damageEnemy reduces enemy HP', () {
        final enemy = Enemy(
          type: EnemyType.basic,
          position: testPosition,
          target: targetPosition,
        );

        viewModel.addEnemy(enemy);

        final initialHP = enemy.hp;
        viewModel.damageEnemy(enemy, 20);

        expect(enemy.hp, equals(initialHP - 20));
      });

      test('damageEnemy notifies listeners', () {
        final enemy = Enemy(
          type: EnemyType.basic,
          position: testPosition,
          target: targetPosition,
        );

        viewModel.addEnemy(enemy);

        var notified = false;
        viewModel.addListener(() {
          notified = true;
        });

        viewModel.damageEnemy(enemy, 20);

        expect(notified, isTrue);
      });

      test('killEnemy immediately kills enemy', () {
        final enemy = Enemy(
          type: EnemyType.basic,
          position: testPosition,
          target: targetPosition,
        );

        viewModel.addEnemy(enemy);

        expect(enemy.isAlive, isTrue);

        viewModel.killEnemy(enemy);

        expect(enemy.isAlive, isFalse);
        expect(enemy.hp, equals(0));
      });

      test('killEnemy notifies listeners', () {
        final enemy = Enemy(
          type: EnemyType.basic,
          position: testPosition,
          target: targetPosition,
        );

        viewModel.addEnemy(enemy);

        var notified = false;
        viewModel.addListener(() {
          notified = true;
        });

        viewModel.killEnemy(enemy);

        expect(notified, isTrue);
      });
    });

    group('Target Detection', () {
      test('getEnemiesAtTarget returns enemies within attack range', () {
        final nearEnemy = Enemy(
          type: EnemyType.basic,
          position: const Offset(490, 490),
          target: const Offset(500, 500),
        );
        final farEnemy = Enemy(
          type: EnemyType.basic,
          position: const Offset(100, 100),
          target: const Offset(500, 500),
        );

        viewModel.addEnemy(nearEnemy);
        viewModel.addEnemy(farEnemy);

        final atTarget = viewModel.getEnemiesAtTarget();

        expect(atTarget, contains(nearEnemy));
        expect(atTarget, isNot(contains(farEnemy)));
      });

      test('getEnemiesAtTarget excludes dead enemies', () {
        final nearEnemy = Enemy(
          type: EnemyType.basic,
          position: const Offset(490, 490),
          target: const Offset(500, 500),
        );

        viewModel.addEnemy(nearEnemy);
        nearEnemy.kill();

        final atTarget = viewModel.getEnemiesAtTarget();

        expect(atTarget, isEmpty);
      });
    });

    group('Enemy Spawning', () {
      test('spawnEnemy adds enemy to list', () async {
        await viewModel.spawnEnemy(
          type: EnemyType.basic,
          position: testPosition,
          target: targetPosition,
        );

        expect(viewModel.activeEnemyCount, equals(1));
        expect(viewModel.enemies.first.type, equals(EnemyType.basic));
        expect(viewModel.enemies.first.position, equals(testPosition));
        expect(viewModel.enemies.first.target, equals(targetPosition));
      });

      test('spawnEnemy scales enemy for level', () async {
        await viewModel.spawnEnemy(
          type: EnemyType.basic,
          position: testPosition,
          target: targetPosition,
          level: 5,
        );

        final enemy = viewModel.enemies.first;
        expect(enemy.hp, greaterThan(EnemyType.basic.baseHp));
        expect(enemy.damage, greaterThan(EnemyType.basic.baseDamage));
      });

      test('spawnEnemy does not scale at level 1', () async {
        await viewModel.spawnEnemy(
          type: EnemyType.basic,
          position: testPosition,
          target: targetPosition,
          level: 1,
        );

        final enemy = viewModel.enemies.first;
        expect(enemy.hp, equals(EnemyType.basic.baseHp));
        expect(enemy.damage, equals(EnemyType.basic.baseDamage));
      });

      test('spawnEnemies spawns multiple enemies', () async {
        final positions = [
          const Offset(100, 100),
          const Offset(200, 100),
          const Offset(300, 100),
        ];

        await viewModel.spawnEnemies(
          type: EnemyType.basic,
          positions: positions,
          target: targetPosition,
        );

        expect(viewModel.activeEnemyCount, equals(3));
      });

      test('spawnEnemies scales all enemies for level', () async {
        final positions = [const Offset(100, 100), const Offset(200, 100)];

        await viewModel.spawnEnemies(
          type: EnemyType.basic,
          positions: positions,
          target: targetPosition,
          level: 3,
        );

        for (final enemy in viewModel.enemies) {
          expect(enemy.hp, greaterThan(EnemyType.basic.baseHp));
        }
      });
    });

    group('Multiple Enemies', () {
      test('manages multiple enemies independently', () {
        final enemy1 = Enemy(
          type: EnemyType.basic,
          position: testPosition,
          target: targetPosition,
        );
        final enemy2 = Enemy(
          type: EnemyType.fast,
          position: testPosition,
          target: targetPosition,
        );

        viewModel.addEnemy(enemy1);
        viewModel.addEnemy(enemy2);

        expect(viewModel.activeEnemyCount, equals(2));

        viewModel.damageEnemy(enemy1, 50);

        expect(enemy1.hp, lessThan(EnemyType.basic.baseHp));
        expect(enemy2.hp, equals(EnemyType.fast.baseHp)); // Unchanged
      });

      test('removes individual enemies correctly', () {
        final enemies = List.generate(
          5,
          (i) => Enemy(
            type: EnemyType.basic,
            position: Offset(i * 10.0, 0),
            target: targetPosition,
          ),
        );

        for (final enemy in enemies) {
          viewModel.addEnemy(enemy);
        }

        expect(viewModel.activeEnemyCount, equals(5));

        viewModel.removeEnemy(enemies[2]);

        expect(viewModel.activeEnemyCount, equals(4));
        expect(viewModel.enemies, isNot(contains(enemies[2])));
      });
    });
  });
}
