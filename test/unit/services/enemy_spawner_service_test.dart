import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tower_defense_game/services/enemy_spawner_service.dart';
import 'package:tower_defense_game/services/interfaces/i_enemy_spawner.dart';
import 'package:tower_defense_game/models/game_enums.dart';

void main() {
  group('EnemySpawnerService Tests', () {
    late IEnemySpawner spawnerService;
    const spawnPosition = Offset(100, 100);
    const targetPosition = Offset(500, 500);

    setUp(() {
      spawnerService = EnemySpawnerService();
    });

    group('Initialization', () {
      test('initializes with level 1', () {
        expect(spawnerService.currentLevel, equals(1));
      });

      test('initializes with wave 0', () {
        expect(spawnerService.currentWave, equals(0));
      });

      test('initializes as not spawning', () {
        expect(spawnerService.isSpawning, isFalse);
      });

      test('initializes with empty enemy queue', () {
        expect(spawnerService.remainingEnemiesInWave, equals(0));
      });
    });

    group('Wave Configuration', () {
      test('getWaveEnemyCount returns count based on level', () {
        final count1 = spawnerService.getWaveEnemyCount(1);
        final count5 = spawnerService.getWaveEnemyCount(5);

        expect(count1, greaterThan(0));
        expect(count5, greaterThan(count1)); // Higher level = more enemies
      });

      test('getWaveEnemyTypes returns types based on level', () {
        final types1 = spawnerService.getWaveEnemyTypes(1);
        final types5 = spawnerService.getWaveEnemyTypes(5);

        expect(types1, isNotEmpty);
        expect(types5, isNotEmpty);

        // Early levels should only have basic enemies
        expect(types1, contains(EnemyType.basic));
        expect(
          types1.length,
          lessThanOrEqualTo(types5.length),
        ); // More variety at higher levels
      });

      test('early levels only spawn basic enemies', () {
        final types = spawnerService.getWaveEnemyTypes(1);

        expect(types.every((type) => type == EnemyType.basic), isTrue);
      });

      test('higher levels include stronger enemy types', () {
        final types = spawnerService.getWaveEnemyTypes(10);

        // Should have more than just basic enemies
        final uniqueTypes = types.toSet();
        expect(uniqueTypes.length, greaterThan(1));
      });

      test('getSpawnDelay decreases with higher levels', () {
        final delay1 = spawnerService.getSpawnDelay(1);
        final delay10 = spawnerService.getSpawnDelay(10);

        expect(delay10, lessThan(delay1)); // Higher level = faster spawning
        expect(delay10, greaterThan(Duration.zero)); // Never instant
      });
    });

    group('Wave Lifecycle', () {
      test('startWave begins spawning', () {
        spawnerService.startWave();

        expect(spawnerService.isSpawning, isTrue);
        expect(spawnerService.currentWave, equals(1));
      });

      test('startWave sets up enemy queue', () {
        spawnerService.startWave();

        expect(spawnerService.remainingEnemiesInWave, greaterThan(0));
      });

      test('consecutive startWave calls increment wave number', () {
        spawnerService.startWave();
        final wave1 = spawnerService.currentWave;

        spawnerService.stopWave();
        spawnerService.startWave();
        final wave2 = spawnerService.currentWave;

        expect(wave2, equals(wave1 + 1));
      });

      test('stopWave stops spawning', () {
        spawnerService.startWave();
        expect(spawnerService.isSpawning, isTrue);

        spawnerService.stopWave();

        expect(spawnerService.isSpawning, isFalse);
      });

      test('stopWave clears remaining enemies', () {
        spawnerService.startWave();
        expect(spawnerService.remainingEnemiesInWave, greaterThan(0));

        spawnerService.stopWave();

        expect(spawnerService.remainingEnemiesInWave, equals(0));
      });
    });

    group('Level Progression', () {
      test('increaseLevel increments level', () {
        final initialLevel = spawnerService.currentLevel;

        spawnerService.increaseLevel();

        expect(spawnerService.currentLevel, equals(initialLevel + 1));
      });

      test('higher levels have more enemies per wave', () {
        final count1 = spawnerService.getWaveEnemyCount(1);

        spawnerService.increaseLevel();
        spawnerService.increaseLevel();
        spawnerService.increaseLevel();

        final count4 = spawnerService.getWaveEnemyCount(
          spawnerService.currentLevel,
        );

        expect(count4, greaterThan(count1));
      });

      test('resetLevel returns to level 1', () {
        spawnerService.increaseLevel();
        spawnerService.increaseLevel();

        expect(spawnerService.currentLevel, greaterThan(1));

        spawnerService.resetLevel();

        expect(spawnerService.currentLevel, equals(1));
      });

      test('resetLevel resets wave counter', () {
        spawnerService.startWave();
        spawnerService.startWave();

        expect(spawnerService.currentWave, greaterThan(0));

        spawnerService.resetLevel();

        expect(spawnerService.currentWave, equals(0));
      });
    });

    group('Enemy Spawning', () {
      test('getNextEnemyToSpawn returns null when not spawning', () async {
        final enemy = await spawnerService.getNextEnemyToSpawn(
          spawnPosition: spawnPosition,
          targetPosition: targetPosition,
        );

        expect(enemy, isNull);
      });

      test('getNextEnemyToSpawn returns enemy when spawning', () async {
        spawnerService.startWave();

        final enemy = await spawnerService.getNextEnemyToSpawn(
          spawnPosition: spawnPosition,
          targetPosition: targetPosition,
        );

        expect(enemy, isNotNull);
      });

      test('getNextEnemyToSpawn spawns enemy at correct position', () async {
        spawnerService.startWave();

        final enemy = await spawnerService.getNextEnemyToSpawn(
          spawnPosition: spawnPosition,
          targetPosition: targetPosition,
        );

        expect(enemy!.position, equals(spawnPosition));
        expect(enemy.target, equals(targetPosition));
      });

      test('getNextEnemyToSpawn decrements remaining enemies', () async {
        spawnerService.startWave();

        final initialRemaining = spawnerService.remainingEnemiesInWave;

        await spawnerService.getNextEnemyToSpawn(
          spawnPosition: spawnPosition,
          targetPosition: targetPosition,
        );

        expect(
          spawnerService.remainingEnemiesInWave,
          equals(initialRemaining - 1),
        );
      });

      test('getNextEnemyToSpawn stops spawning when wave complete', () async {
        spawnerService.startWave();

        // Spawn all enemies in wave
        while (spawnerService.remainingEnemiesInWave > 0) {
          await spawnerService.getNextEnemyToSpawn(
            spawnPosition: spawnPosition,
            targetPosition: targetPosition,
          );

          // Simulate spawn delay frames for next enemy
          if (spawnerService.remainingEnemiesInWave > 0) {
            for (var i = 0; i < 120; i++) {
              spawnerService.updateSpawnTimer();
            }
          }
        }

        expect(spawnerService.isSpawning, isFalse);
      });

      test('spawned enemies are scaled for current level', () async {
        spawnerService.increaseLevel();
        spawnerService.increaseLevel();
        spawnerService.startWave();

        final enemy = await spawnerService.getNextEnemyToSpawn(
          spawnPosition: spawnPosition,
          targetPosition: targetPosition,
        );

        // Higher level should result in scaled HP and damage
        expect(enemy!.hp, greaterThan(enemy.type.baseHp));
        expect(enemy.damage, greaterThan(enemy.type.baseDamage));
      });
    });

    group('Wave Timing', () {
      test('canSpawnNextEnemy respects spawn delay', () async {
        spawnerService.startWave();

        final canSpawn1 = spawnerService.canSpawnNextEnemy();
        expect(canSpawn1, isTrue); // First spawn is immediate

        await spawnerService.getNextEnemyToSpawn(
          spawnPosition: spawnPosition,
          targetPosition: targetPosition,
        );

        final canSpawn2 = spawnerService.canSpawnNextEnemy();
        expect(canSpawn2, isFalse); // Must wait for cooldown

        // Simulate frames passing (spawn delay is 120 frames at level 1)
        for (var i = 0; i < 120; i++) {
          spawnerService.updateSpawnTimer();
        }

        final canSpawn3 = spawnerService.canSpawnNextEnemy();
        expect(canSpawn3, isTrue); // Cooldown complete
      });

      test('spawn delay decreases at higher levels', () {
        final delay1 = spawnerService.getSpawnDelay(1);
        final delay5 = spawnerService.getSpawnDelay(5);
        final delay10 = spawnerService.getSpawnDelay(10);

        expect(delay5, lessThan(delay1));
        expect(delay10, lessThan(delay5));
      });
    });

    group('Wave Completion', () {
      test('isWaveComplete returns true when no enemies remain', () async {
        spawnerService.startWave();

        while (spawnerService.remainingEnemiesInWave > 0) {
          await spawnerService.getNextEnemyToSpawn(
            spawnPosition: spawnPosition,
            targetPosition: targetPosition,
          );

          // Simulate spawn delay frames
          if (spawnerService.remainingEnemiesInWave > 0) {
            for (var i = 0; i < 120; i++) {
              spawnerService.updateSpawnTimer();
            }
          }
        }

        expect(spawnerService.isWaveComplete, isTrue);
      });

      test('isWaveComplete returns false during active wave', () {
        spawnerService.startWave();

        expect(spawnerService.isWaveComplete, isFalse);
      });

      test('isWaveComplete returns false before wave starts', () {
        expect(spawnerService.isWaveComplete, isFalse);
      });
    });

    group('Multiple Waves', () {
      test('handles multiple sequential waves', () async {
        // Wave 1
        spawnerService.startWave();
        while (spawnerService.remainingEnemiesInWave > 0) {
          await spawnerService.getNextEnemyToSpawn(
            spawnPosition: spawnPosition,
            targetPosition: targetPosition,
          );

          // Simulate spawn delay frames
          if (spawnerService.remainingEnemiesInWave > 0) {
            for (var i = 0; i < 120; i++) {
              spawnerService.updateSpawnTimer();
            }
          }
        }

        expect(spawnerService.currentWave, equals(1));

        // Wave 2
        spawnerService.startWave();
        expect(spawnerService.currentWave, equals(2));
        expect(spawnerService.isSpawning, isTrue);
      });

      test('wave difficulty increases each wave', () {
        spawnerService.startWave();
        final wave1Count = spawnerService.remainingEnemiesInWave;

        spawnerService.stopWave();
        spawnerService.increaseLevel();
        spawnerService.startWave();
        final wave2Count = spawnerService.remainingEnemiesInWave;

        expect(wave2Count, greaterThanOrEqualTo(wave1Count));
      });
    });

    group('Enemy Type Distribution', () {
      test('spawns variety of enemy types at high levels', () async {
        spawnerService.increaseLevel();
        spawnerService.increaseLevel();
        spawnerService.increaseLevel();
        spawnerService.increaseLevel();
        spawnerService.startWave();

        final spawnedTypes = <EnemyType>{};

        while (spawnerService.remainingEnemiesInWave > 0 &&
            spawnedTypes.length < 3) {
          final enemy = await spawnerService.getNextEnemyToSpawn(
            spawnPosition: spawnPosition,
            targetPosition: targetPosition,
          );
          if (enemy != null) {
            spawnedTypes.add(enemy.type);
          }

          // Simulate spawn delay frames
          if (spawnerService.remainingEnemiesInWave > 0) {
            for (var i = 0; i < 120; i++) {
              spawnerService.updateSpawnTimer();
            }
          }
        }

        expect(spawnedTypes.length, greaterThan(1)); // Multiple types
      });
    });

    group('Service Reset', () {
      test('reset returns service to initial state', () {
        spawnerService.increaseLevel();
        spawnerService.increaseLevel();
        spawnerService.startWave();

        spawnerService.reset();

        expect(spawnerService.currentLevel, equals(1));
        expect(spawnerService.currentWave, equals(0));
        expect(spawnerService.isSpawning, isFalse);
        expect(spawnerService.remainingEnemiesInWave, equals(0));
      });
    });
  });
}
