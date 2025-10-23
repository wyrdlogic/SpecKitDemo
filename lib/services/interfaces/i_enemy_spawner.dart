import 'package:flutter/material.dart';
import '../../models/enemy.dart';
import '../../models/game_enums.dart';

/// Interface for managing enemy wave spawning and progression
abstract interface class IEnemySpawner {
  /// Current difficulty level
  int get currentLevel;

  /// Current wave number
  int get currentWave;

  /// Whether enemies are currently being spawned
  bool get isSpawning;

  /// Number of enemies remaining to spawn in current wave
  int get remainingEnemiesInWave;

  /// Whether the current wave has been completed
  bool get isWaveComplete;

  /// Start spawning enemies for a new wave
  void startWave();

  /// Stop spawning enemies (cancels current wave)
  void stopWave();

  /// Increase the difficulty level
  void increaseLevel();

  /// Reset level to 1
  void resetLevel();

  /// Reset service to initial state
  void reset();

  /// Get the number of enemies for a given level
  int getWaveEnemyCount(int level);

  /// Get the enemy types that should spawn at a given level
  List<EnemyType> getWaveEnemyTypes(int level);

  /// Get the spawn delay between enemies for a given level
  Duration getSpawnDelay(int level);

  /// Check if next enemy can spawn based on cooldown
  bool canSpawnNextEnemy();

  /// Get the next enemy to spawn, or null if wave is complete or cooldown is active
  Future<Enemy?> getNextEnemyToSpawn({
    required Offset spawnPosition,
    required Offset targetPosition,
  });
}
