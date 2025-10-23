import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tower_defense_game/models/enemy.dart';
import 'package:tower_defense_game/models/game_enums.dart';
import 'package:tower_defense_game/viewmodels/enemy_viewmodel.dart';

/// Widget tests for EnemyComponent Flame component
///
/// Note: Flame components are best tested through integration tests
/// since they require a FlameGame context. These tests focus on
/// verifying the EnemyViewModel behavior that drives the component.
void main() {
  group('EnemyComponent Integration Tests', () {
    late EnemyViewModel enemyViewModel;

    setUp(() {
      enemyViewModel = EnemyViewModel();
    });

    tearDown(() {
      enemyViewModel.dispose();
    });

    test('enemy spawns with correct properties', () async {
      await enemyViewModel.spawnEnemy(
        type: EnemyType.basic,
        position: const Offset(100, 100),
        target: const Offset(400, 300),
      );

      expect(enemyViewModel.enemies.length, 1);
      final enemy = enemyViewModel.enemies.first;
      expect(enemy.type, EnemyType.basic);
      expect(enemy.position, const Offset(100, 100));
      expect(enemy.isAlive, true);
    });

    test('enemy spawns at correct level', () async {
      await enemyViewModel.spawnEnemy(
        type: EnemyType.basic,
        position: const Offset(100, 100),
        target: const Offset(400, 300),
        level: 3,
      );

      final enemy = enemyViewModel.enemies.first;
      // Level 3 enemy should have scaled stats
      expect(enemy.hp, greaterThan(Enemy(
        type: EnemyType.basic,
        position: const Offset(0, 0),
        target: const Offset(0, 0),
      ).hp));
    });

    test('multiple enemy types can be spawned', () async {
      await enemyViewModel.spawnEnemy(
        type: EnemyType.basic,
        position: const Offset(100, 100),
        target: const Offset(400, 300),
      );

      await enemyViewModel.spawnEnemy(
        type: EnemyType.fast,
        position: const Offset(150, 100),
        target: const Offset(400, 300),
      );

      await enemyViewModel.spawnEnemy(
        type: EnemyType.strong,
        position: const Offset(200, 100),
        target: const Offset(400, 300),
      );

      expect(enemyViewModel.enemies.length, 3);
      expect(enemyViewModel.enemies[0].type, EnemyType.basic);
      expect(enemyViewModel.enemies[1].type, EnemyType.fast);
      expect(enemyViewModel.enemies[2].type, EnemyType.strong);
    });

    test('enemy can take damage', () {
      final enemy = Enemy(
        type: EnemyType.basic,
        position: const Offset(100, 100),
        target: const Offset(400, 300),
      );

      enemyViewModel.addEnemy(enemy);
      final initialHP = enemy.hp;

      enemyViewModel.damageEnemy(enemy, 20);

      expect(enemy.hp, initialHP - 20);
      expect(enemy.isAlive, true);
    });

    test('enemy dies when HP reaches zero', () {
      final enemy = Enemy(
        type: EnemyType.basic,
        position: const Offset(100, 100),
        target: const Offset(400, 300),
      );

      enemyViewModel.addEnemy(enemy);

      enemyViewModel.killEnemy(enemy);

      expect(enemy.isAlive, false);
    });

    test('dead enemies can be removed', () {
      final enemy = Enemy(
        type: EnemyType.basic,
        position: const Offset(100, 100),
        target: const Offset(400, 300),
      );

      enemyViewModel.addEnemy(enemy);
      enemyViewModel.killEnemy(enemy);

      expect(enemyViewModel.enemies.length, 1);

      enemyViewModel.removeDeadEnemies();

      expect(enemyViewModel.enemies.length, 0);
    });

    test('enemy moves toward target', () {
      final enemy = Enemy(
        type: EnemyType.basic,
        position: const Offset(100, 100),
        target: const Offset(400, 300),
      );

      enemyViewModel.addEnemy(enemy);
      final initialPosition = enemy.position;

      enemyViewModel.updateEnemies(0.016); // One frame

      expect(enemy.position, isNot(initialPosition));
    });

    test('enemy reaches target when close enough', () {
      final enemy = Enemy(
        type: EnemyType.basic,
        position: const Offset(400, 300),
        target: const Offset(400, 300),
      );

      enemyViewModel.addEnemy(enemy);

      final enemiesAtTarget = enemyViewModel.getEnemiesAtTarget();

      expect(enemiesAtTarget.contains(enemy), true);
    });

    test('fast enemy has higher speed than basic', () {
      final basicEnemy = Enemy(
        type: EnemyType.basic,
        position: const Offset(0, 0),
        target: const Offset(0, 0),
      );

      final fastEnemy = Enemy(
        type: EnemyType.fast,
        position: const Offset(0, 0),
        target: const Offset(0, 0),
      );

      expect(fastEnemy.speed, greaterThan(basicEnemy.speed));
    });

    test('strong enemy has higher HP than basic', () {
      final basicEnemy = Enemy(
        type: EnemyType.basic,
        position: const Offset(0, 0),
        target: const Offset(0, 0),
      );

      final strongEnemy = Enemy(
        type: EnemyType.strong,
        position: const Offset(0, 0),
        target: const Offset(0, 0),
      );

      expect(strongEnemy.hp, greaterThan(basicEnemy.hp));
    });

    test('enemy cooldown works correctly', () {
      final enemy = Enemy(
        type: EnemyType.basic,
        position: const Offset(400, 300),
        target: const Offset(400, 300),
      );

      enemyViewModel.addEnemy(enemy);

      // Enemy should be able to attack initially
      expect(enemy.canAttack, true);

      // Trigger attack (cooldown starts - 60 frames at 60 FPS)
      enemy.attack();
      expect(enemy.canAttack, false);

      // Update cooldown for 60+ frames to reset
      for (var i = 0; i < 65; i++) {
        enemyViewModel.updateEnemies(0.016); // One frame at 60 FPS
      }

      expect(enemy.canAttack, true);
    });

    test('activeEnemyCount only counts alive enemies', () {
      final enemy1 = Enemy(
        type: EnemyType.basic,
        position: const Offset(100, 100),
        target: const Offset(400, 300),
      );
      final enemy2 = Enemy(
        type: EnemyType.basic,
        position: const Offset(150, 100),
        target: const Offset(400, 300),
      );

      enemyViewModel.addEnemy(enemy1);
      enemyViewModel.addEnemy(enemy2);

      expect(enemyViewModel.activeEnemyCount, 2);

      enemyViewModel.killEnemy(enemy1);

      expect(enemyViewModel.activeEnemyCount, 1);
    });

    test('clearAll removes all enemies', () {
      final enemy1 = Enemy(
        type: EnemyType.basic,
        position: const Offset(100, 100),
        target: const Offset(400, 300),
      );
      final enemy2 = Enemy(
        type: EnemyType.fast,
        position: const Offset(150, 100),
        target: const Offset(400, 300),
      );

      enemyViewModel.addEnemy(enemy1);
      enemyViewModel.addEnemy(enemy2);

      expect(enemyViewModel.enemies.length, 2);

      enemyViewModel.clearAll();

      expect(enemyViewModel.enemies.length, 0);
    });

    test('enemy notifies listeners when added', () {
      var notified = false;
      enemyViewModel.addListener(() => notified = true);

      final enemy = Enemy(
        type: EnemyType.basic,
        position: const Offset(100, 100),
        target: const Offset(400, 300),
      );

      enemyViewModel.addEnemy(enemy);

      expect(notified, true);
    });

    test('enemy notifies listeners when damaged', () {
      final enemy = Enemy(
        type: EnemyType.basic,
        position: const Offset(100, 100),
        target: const Offset(400, 300),
      );
      enemyViewModel.addEnemy(enemy);

      var notified = false;
      enemyViewModel.addListener(() => notified = true);

      enemyViewModel.damageEnemy(enemy, 10);

      expect(notified, true);
    });

    test('enemy notifies listeners when updated', () {
      final enemy = Enemy(
        type: EnemyType.basic,
        position: const Offset(100, 100),
        target: const Offset(400, 300),
      );
      enemyViewModel.addEnemy(enemy);

      var notified = false;
      enemyViewModel.addListener(() => notified = true);

      enemyViewModel.updateEnemies(0.016);

      expect(notified, true);
    });

    test('dead enemies are not updated', () {
      final enemy = Enemy(
        type: EnemyType.basic,
        position: const Offset(100, 100),
        target: const Offset(400, 300),
      );

      enemyViewModel.addEnemy(enemy);
      enemyViewModel.killEnemy(enemy);

      final deadPosition = enemy.position;

      enemyViewModel.updateEnemies(0.016);

      expect(enemy.position, deadPosition); // Should not move
    });

    test('multiple enemies spawn at different positions', () async {
      await enemyViewModel.spawnEnemies(
        type: EnemyType.basic,
        positions: const [
          Offset(100, 100),
          Offset(200, 100),
          Offset(300, 100),
        ],
        target: const Offset(400, 300),
      );

      expect(enemyViewModel.enemies.length, 3);
      expect(enemyViewModel.enemies[0].position, const Offset(100, 100));
      expect(enemyViewModel.enemies[1].position, const Offset(200, 100));
      expect(enemyViewModel.enemies[2].position, const Offset(300, 100));
    });
  });
}
