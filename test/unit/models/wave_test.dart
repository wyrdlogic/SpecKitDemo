import 'package:flutter_test/flutter_test.dart';
import 'package:tower_defense_game/models/wave.dart';

void main() {
  group('Wave Model Tests', () {
    group('Initialization', () {
      test('initializes wave with default properties', () {
        final wave = Wave();

        expect(wave.level, equals(1));
        expect(wave.duration, equals(60));
        expect(wave.isActive, isFalse);
        expect(wave.remainingTime, equals(60));
        expect(wave.enemiesSpawned, equals(0));
      });

      test('initializes wave with custom properties', () {
        final wave = Wave(level: 3, duration: 90, isActive: false);

        expect(wave.level, equals(3));
        expect(wave.duration, equals(90));
        expect(wave.isActive, isFalse);
        expect(wave.remainingTime, equals(90));
      });
    });

    group('Wave State Management', () {
      test('startWave activates wave', () {
        final wave = Wave(level: 1);
        final activeWave = wave.startWave(1);

        expect(activeWave.isActive, isTrue);
        expect(activeWave.remainingTime, equals(60));
        expect(activeWave.enemiesSpawned, equals(0));
        expect(activeWave.startTime, isNotNull);
      });

      test('endWave deactivates wave', () {
        final wave = Wave().startWave(1);
        final completedWave = wave.endWave();

        expect(completedWave.isActive, isFalse);
        expect(completedWave.remainingTime, equals(0));
      });

      test('updateTimer decreases time remaining', () {
        var wave = Wave().startWave(1);
        final initialTime = wave.remainingTime;

        wave.updateTimer();

        expect(wave.remainingTime, equals(initialTime - 1));
        expect(wave.isActive, isTrue);
      });

      test('updateTimer stops at zero', () {
        var wave = Wave(duration: 60, remainingTime: 1).startWave(1);
        wave = wave.copyWith(remainingTime: 1);

        wave.updateTimer();

        expect(wave.remainingTime, equals(0));
      });

      test('isComplete returns true when time is zero', () {
        final wave = Wave(remainingTime: 0);

        expect(wave.isComplete, isTrue);
      });

      test('isComplete returns false when time remaining', () {
        final wave = Wave(remainingTime: 30);

        expect(wave.isComplete, isFalse);
      });
    });

    group('Enemy Spawn Tracking', () {
      test('spawnEnemy increases enemies spawned', () {
        final wave = Wave();
        final updatedWave = wave.spawnEnemy();

        expect(updatedWave.enemiesSpawned, equals(1));
      });

      test('multiple spawns accumulate', () {
        var wave = Wave();

        wave = wave.spawnEnemy();
        wave = wave.spawnEnemy();
        wave = wave.spawnEnemy();

        expect(wave.enemiesSpawned, equals(3));
      });

      test('shouldSpawnEnemy returns false for inactive wave', () {
        final wave = Wave();

        expect(wave.shouldSpawnEnemy(), isFalse);
      });

      test('getExpectedEnemyCount returns zero for inactive wave', () {
        final wave = Wave();

        expect(wave.getExpectedEnemyCount(), equals(0));
      });
    });

    group('Wave Progress', () {
      test('progress calculates correctly', () {
        final wave = Wave(duration: 60, remainingTime: 30);

        expect(wave.progress, closeTo(0.5, 0.01));
      });

      test('progress is 0 at start', () {
        final wave = Wave(duration: 60, remainingTime: 60);

        expect(wave.progress, equals(0.0));
      });

      test('progress is 1 when complete', () {
        final wave = Wave(duration: 60, remainingTime: 0);

        expect(wave.progress, equals(1.0));
      });

      test('timeElapsed calculates correctly', () {
        final wave = Wave(duration: 60, remainingTime: 40);

        expect(wave.timeElapsed, equals(20));
      });
    });

    group('Immutability and CopyWith', () {
      test('copyWith creates new instance with updated fields', () {
        final original = Wave(level: 1, duration: 60);

        final copy = original.copyWith(level: 2, duration: 90);

        expect(copy.level, equals(2));
        expect(copy.duration, equals(90));
      });

      test('copyWith maintains other properties', () {
        final original = Wave(level: 1, duration: 60, isActive: true);

        final copy = original.copyWith(level: 2);

        expect(copy.level, equals(2));
        expect(copy.duration, equals(original.duration));
        expect(copy.isActive, equals(original.isActive));
      });
    });

    group('Spawn Rate Calculation', () {
      test('level 1 has base spawn rate', () {
        final wave = Wave(level: 1);

        expect(wave.enemySpawnRate, equals(0.5));
      });

      test('spawn rate increases with level', () {
        final wave1 = Wave(level: 1);
        final wave2 = Wave(level: 2);
        final wave5 = Wave(level: 5);

        expect(wave2.enemySpawnRate, greaterThan(wave1.enemySpawnRate));
        expect(wave5.enemySpawnRate, greaterThan(wave2.enemySpawnRate));
      });

      test('spawn rate formula is correct', () {
        final wave3 = Wave(level: 3);

        // 0.5 + (3 - 1) * 0.25 = 1.0
        expect(wave3.enemySpawnRate, equals(1.0));
      });
    });

    group('Level Progression', () {
      test('nextWave increases level', () {
        final wave = Wave(level: 1);
        final nextWave = wave.nextWave();

        expect(nextWave.level, equals(2));
        expect(nextWave.isActive, isFalse);
        expect(nextWave.enemiesSpawned, equals(0));
      });

      test('higher levels have higher spawn rates', () {
        final wave1 = Wave(level: 1);
        final wave10 = Wave(level: 10);

        expect(wave10.enemySpawnRate, greaterThan(wave1.enemySpawnRate));
      });
    });

    group('Validation', () {
      test('throws on invalid duration', () {
        expect(() => Wave(duration: 0), throwsA(isA<StateError>()));
      });

      test('throws on negative level in startWave', () {
        final wave = Wave();

        expect(() => wave.startWave(0), throwsA(isA<ArgumentError>()));
      });

      test('throws on invalid remainingTime', () {
        expect(
          () => Wave(duration: 60, remainingTime: -1),
          throwsA(isA<StateError>()),
        );
      });
    });
  });
}
