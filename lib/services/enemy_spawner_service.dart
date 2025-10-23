import 'package:flutter/material.dart';
import '../models/enemy.dart';
import '../models/game_enums.dart';
import 'interfaces/i_enemy_spawner.dart';

/// Service that manages enemy wave spawning and level progression
class EnemySpawnerService implements IEnemySpawner {
  int _currentLevel = 1;
  int _currentWave = 0;
  bool _isSpawning = false;
  List<EnemyType> _currentWaveEnemies = [];
  int _framesSinceLastSpawn = 0;

  // Configuration constants (frame-based at 60 FPS)
  static const int _baseSpawnDelayFrames = 120; // 2 seconds at 60 FPS
  static const int _minSpawnDelayFrames = 30; // 0.5 seconds at 60 FPS
  static const int _baseEnemiesPerWave = 5;
  static const double _enemiesScalingFactor = 1.5;

  @override
  int get currentLevel => _currentLevel;

  @override
  int get currentWave => _currentWave;

  @override
  bool get isSpawning => _isSpawning;

  @override
  int get remainingEnemiesInWave => _currentWaveEnemies.length;

  @override
  bool get isWaveComplete =>
      _currentWave > 0 && !_isSpawning && _currentWaveEnemies.isEmpty;

  @override
  void startWave() {
    _currentWave++;
    _isSpawning = true;
    _currentWaveEnemies = getWaveEnemyTypes(_currentLevel);
    _framesSinceLastSpawn = 0; // First enemy spawns immediately
  }

  @override
  void stopWave() {
    _isSpawning = false;
    _currentWaveEnemies.clear();
    _framesSinceLastSpawn = 0;
  }

  @override
  void increaseLevel() {
    _currentLevel++;
  }

  @override
  void resetLevel() {
    _currentLevel = 1;
    _currentWave = 0;
  }

  @override
  void reset() {
    _currentLevel = 1;
    _currentWave = 0;
    _isSpawning = false;
    _currentWaveEnemies.clear();
    _framesSinceLastSpawn = 0;
  }

  @override
  int getWaveEnemyCount(int level) {
    // Base enemies + scaling based on level
    return (_baseEnemiesPerWave + (level - 1) * _enemiesScalingFactor).round();
  }

  @override
  List<EnemyType> getWaveEnemyTypes(int level) {
    final count = getWaveEnemyCount(level);
    final enemies = <EnemyType>[];

    // Level 1-2: Only basic enemies
    if (level <= 2) {
      for (var i = 0; i < count; i++) {
        enemies.add(EnemyType.basic);
      }
      return enemies;
    }

    // Level 3-5: Mix of basic and fast
    if (level <= 5) {
      final basicCount = (count * 0.6).round();
      final fastCount = count - basicCount;

      for (var i = 0; i < basicCount; i++) {
        enemies.add(EnemyType.basic);
      }
      for (var i = 0; i < fastCount; i++) {
        enemies.add(EnemyType.fast);
      }
      return enemies;
    }

    // Level 6+: Mix of all types
    final basicCount = (count * 0.4).round();
    final fastCount = (count * 0.3).round();
    final strongCount = count - basicCount - fastCount;

    for (var i = 0; i < basicCount; i++) {
      enemies.add(EnemyType.basic);
    }
    for (var i = 0; i < fastCount; i++) {
      enemies.add(EnemyType.fast);
    }
    for (var i = 0; i < strongCount; i++) {
      enemies.add(EnemyType.strong);
    }

    // Shuffle for variety
    enemies.shuffle();

    return enemies;
  }

  @override
  Duration getSpawnDelay(int level) {
    // Spawn delay decreases with level but has a minimum
    // Convert frame-based delays to Duration for backward compatibility
    final delayFrames = (_baseSpawnDelayFrames / (1 + level * 0.1)).round();
    final clampedFrames = delayFrames > _minSpawnDelayFrames
        ? delayFrames
        : _minSpawnDelayFrames;

    // Convert frames to milliseconds (60 FPS = 16.67ms per frame)
    return Duration(milliseconds: (clampedFrames * 16.67).round());
  }

  /// Get spawn delay in frames (60 FPS)
  int getSpawnDelayFrames(int level) {
    final delayFrames = (_baseSpawnDelayFrames / (1 + level * 0.1)).round();
    return delayFrames > _minSpawnDelayFrames
        ? delayFrames
        : _minSpawnDelayFrames;
  }

  @override
  bool canSpawnNextEnemy() {
    if (!_isSpawning || _currentWaveEnemies.isEmpty) {
      return false;
    }

    // First enemy can spawn immediately (frame counter starts at 0)
    if (_framesSinceLastSpawn == 0) {
      return true;
    }

    // Check if enough frames have passed
    final requiredFrames = getSpawnDelayFrames(_currentLevel);
    return _framesSinceLastSpawn >= requiredFrames;
  }

  /// Update frame counter (call each game frame at 60 FPS)
  void updateSpawnTimer() {
    if (_isSpawning && _framesSinceLastSpawn > 0) {
      _framesSinceLastSpawn++;
    }
  }

  @override
  Future<Enemy?> getNextEnemyToSpawn({
    required Offset spawnPosition,
    required Offset targetPosition,
  }) async {
    if (!canSpawnNextEnemy()) {
      return null;
    }

    // Get next enemy type from queue
    final enemyType = _currentWaveEnemies.removeAt(0);

    // Reset frame counter for next spawn
    _framesSinceLastSpawn = 1; // Start counting from 1 for next cooldown

    // Stop spawning if wave is complete
    if (_currentWaveEnemies.isEmpty) {
      _isSpawning = false;
    }

    // Create enemy scaled for current level
    final enemy = Enemy(
      type: enemyType,
      position: spawnPosition,
      target: targetPosition,
    );

    // Scale for level (modifies enemy in place)
    if (_currentLevel > 1) {
      enemy.scaleForLevel(_currentLevel);
    }

    return enemy;
  }
}
