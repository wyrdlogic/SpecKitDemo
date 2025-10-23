import 'package:flutter_test/flutter_test.dart';
import 'package:tower_defense_game/models/wave.dart';
import 'package:tower_defense_game/viewmodels/wave_viewmodel.dart';

void main() {
  group('WaveViewModel Tests', () {
    late WaveViewModel viewModel;

    setUp(() {
      viewModel = WaveViewModel();
    });

    tearDown(() {
      viewModel.dispose();
      print('ViewModel disposed: WaveViewModel');
    });

    group('Initialization', () {
      test('initializes with inactive wave', () {
        expect(viewModel.currentWave, isNotNull);
        expect(viewModel.isWaveActive, isFalse);
        expect(viewModel.currentLevel, equals(1));
      });

      test('initializes with level 1', () {
        expect(viewModel.currentLevel, equals(1));
      });
    });

    group('Wave Start', () {
      test('startWave creates and activates a wave', () {
        viewModel.startWave();

        expect(viewModel.currentWave, isNotNull);
        expect(viewModel.isWaveActive, isTrue);
        expect(viewModel.currentWave.level, equals(1));
        expect(viewModel.currentWave.duration, equals(60));
      });

      test('startWave notifies listeners', () {
        var notified = false;
        viewModel.addListener(() => notified = true);

        viewModel.startWave();

        expect(notified, isTrue);
      });

      test('startWave uses current level', () {
        viewModel.advanceLevel();
        viewModel.startWave();

        expect(viewModel.currentWave.level, equals(2));
      });

      test('cannot start wave when already active', () {
        viewModel.startWave();
        final firstWave = viewModel.currentWave;

        viewModel.startWave(); // Try to start again

        expect(viewModel.currentWave, same(firstWave));
      });
    });

    group('Wave Update', () {
      test('updateWave decreases time remaining', () {
        viewModel.startWave();
        final initialTime = viewModel.currentWave.remainingTime;

        viewModel.updateWave(1.0);

        expect(viewModel.currentWave.remainingTime, lessThan(initialTime));
        expect(viewModel.currentWave.remainingTime, equals(initialTime - 1));
      });

      test('updateWave notifies listeners', () {
        viewModel.startWave();
        var notified = false;
        viewModel.addListener(() => notified = true);

        viewModel.updateWave(1.0);

        expect(notified, isTrue);
      });

      test('updateWave does nothing when no active wave', () {
        viewModel.updateWave(1.0); // Should not throw

        expect(viewModel.isWaveActive, isFalse);
      });

      test('wave timer reaches zero', () {
        viewModel.startWave();

        // Update timer 60 times (one second each)
        for (var i = 0; i < 60; i++) {
          viewModel.updateWave(1.0);
        }

        expect(viewModel.currentWave.isComplete, isTrue);
        expect(viewModel.currentWave.remainingTime, equals(0));
      });
    });

    group('Wave Completion', () {
      test('completeWave deactivates wave', () {
        viewModel.startWave();

        viewModel.completeWave();

        expect(viewModel.isWaveActive, isFalse);
        expect(viewModel.currentWave, isNotNull); // Still exists but not active
      });

      test('completeWave notifies listeners', () {
        viewModel.startWave();
        var notified = false;
        viewModel.addListener(() => notified = true);

        viewModel.completeWave();

        expect(notified, isTrue);
      });

      test('completeWave does nothing when no active wave', () {
        viewModel.completeWave(); // Should not throw

        expect(viewModel.isWaveActive, isFalse);
      });
    });

    group('Level Progression', () {
      test('advanceLevel increments level', () {
        expect(viewModel.currentLevel, equals(1));

        viewModel.advanceLevel();

        expect(viewModel.currentLevel, equals(2));
      });

      test('advanceLevel notifies listeners', () {
        var notified = false;
        viewModel.addListener(() => notified = true);

        viewModel.advanceLevel();

        expect(notified, isTrue);
      });

      test('multiple advanceLevel calls accumulate', () {
        viewModel.advanceLevel();
        viewModel.advanceLevel();
        viewModel.advanceLevel();

        expect(viewModel.currentLevel, equals(4));
      });

      test('new wave uses advanced level', () {
        viewModel.advanceLevel();
        viewModel.advanceLevel();
        viewModel.startWave();

        expect(viewModel.currentWave.level, equals(3));
      });
    });

    group('Wave Reset', () {
      test('reset clears wave state', () {
        viewModel.startWave();
        viewModel.updateWave(30.0);

        viewModel.reset();

        expect(viewModel.isWaveActive, isFalse);
        expect(viewModel.currentWave, isNotNull);
      });

      test('reset returns to level 1', () {
        viewModel.advanceLevel();
        viewModel.advanceLevel();

        viewModel.reset();

        expect(viewModel.currentLevel, equals(1));
      });

      test('reset notifies listeners', () {
        viewModel.startWave();
        var notified = false;
        viewModel.addListener(() => notified = true);

        viewModel.reset();

        expect(notified, isTrue);
      });
    });

    group('Wave Properties', () {
      test('timeRemaining returns current wave time', () {
        viewModel.startWave();

        expect(viewModel.timeRemaining, equals(60));

        viewModel.updateWave(1.0);
        viewModel.updateWave(1.0);

        expect(viewModel.timeRemaining, equals(58));
      });

      test('timeRemaining returns 60 when wave not started', () {
        expect(viewModel.timeRemaining, equals(60));
      });

      test('progress calculates correctly', () {
        viewModel.startWave();

        // Update 30 times to get to 30 seconds elapsed
        for (var i = 0; i < 30; i++) {
          viewModel.updateWave(1.0);
        }

        expect(viewModel.progress, closeTo(0.5, 0.01));
      });

      test('progress returns 0.0 when wave not started', () {
        expect(viewModel.progress, equals(0.0));
      });
    });

    group('Enemy Spawn Tracking', () {
      test('incrementEnemySpawnCount updates wave', () {
        viewModel.startWave();
        final initialCount = viewModel.currentWave.enemiesSpawned;

        viewModel.incrementEnemySpawnCount();

        expect(viewModel.currentWave.enemiesSpawned, equals(initialCount + 1));
      });

      test('incrementEnemySpawnCount notifies listeners', () {
        viewModel.startWave();
        var notified = false;
        viewModel.addListener(() => notified = true);

        viewModel.incrementEnemySpawnCount();

        expect(notified, isTrue);
      });

      test('incrementEnemySpawnCount does nothing when no active wave', () {
        viewModel.incrementEnemySpawnCount(); // Should not throw

        expect(viewModel.isWaveActive, isFalse);
      });

      test('shouldSpawnEnemy returns based on wave state', () {
        viewModel.startWave();

        // Initially should not spawn (no time elapsed)
        expect(viewModel.shouldSpawnEnemy(), isFalse);

        // After some time should spawn
        viewModel.updateWave(1.0);
        viewModel.updateWave(1.0);

        // Expected enemies = 2s * 0.5/s = 1, spawned = 0, so should spawn
        expect(viewModel.shouldSpawnEnemy(), isTrue);
      });
    });

    group('Multiple Wave Cycles', () {
      test('can start new wave after completing previous', () {
        viewModel.startWave();
        viewModel.completeWave();

        viewModel.startWave();

        expect(viewModel.isWaveActive, isTrue);
        expect(viewModel.currentWave.remainingTime, equals(60));
      });

      test('level persists across wave cycles', () {
        viewModel.startWave();
        viewModel.completeWave();
        viewModel.advanceLevel();

        viewModel.startWave();

        expect(viewModel.currentLevel, equals(2));
        expect(viewModel.currentWave.level, equals(2));
      });
    });

    group('ViewModel State Changes', () {
      test('notifies listeners on each state change', () {
        var notificationCount = 0;
        viewModel.addListener(() => notificationCount++);

        viewModel.startWave(); // 1
        viewModel.updateWave(1.0); // 2
        viewModel.incrementEnemySpawnCount(); // 3
        viewModel.completeWave(); // 4
        viewModel.advanceLevel(); // 5

        expect(notificationCount, greaterThanOrEqualTo(5));
      });
    });
  });
}
