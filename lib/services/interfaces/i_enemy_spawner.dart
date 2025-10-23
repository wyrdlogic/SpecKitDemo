import 'package:flutter/material.dart';
import '../../models/enemy.dart';
import '../../models/game_enums.dart';

/// Interface for spawning and managing enemies
abstract interface class IEnemySpawner {
  /// Spawn a new enemy of the specified type
  Enemy spawnEnemy(EnemyType type, Offset spawnPosition, Offset targetPosition);

  /// Spawn an enemy scaled for the current level
  Enemy spawnEnemyForLevel(
    EnemyType type,
    int level,
    Offset spawnPosition,
    Offset targetPosition,
  );

  /// Get the spawn rate for the current wave level
  double getSpawnRateForLevel(int level);

  /// Get a random enemy type appropriate for the level
  EnemyType getRandomEnemyType(int level);

  /// Calculate enemy stats scaled for level
  ({int hp, int damage, double speed}) calculateEnemyStats(
    EnemyType type,
    int level,
  );

  /// Get all active enemies
  List<Enemy> getActiveEnemies();

  /// Update all enemies (movement, combat, cleanup)
  void updateEnemies(double deltaTime, Offset wallPosition);

  /// Remove dead enemies and return score gained
  int cleanupDeadEnemies();

  /// Clear all enemies (for game reset)
  void clearAllEnemies();

  /// Add an enemy to the active list
  void addEnemy(Enemy enemy);

  /// Remove an enemy from the active list
  void removeEnemy(Enemy enemy);

  /// Stream of enemy updates
  Stream<List<Enemy>> get enemyStream;

  /// Check if any enemy has reached the wall
  List<Enemy> getEnemiesAtWall(Offset wallPosition, double attackRange);
}
