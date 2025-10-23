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
  DateTime? _lastSpawnTime;

  // Configuration constants
  static const Duration _baseSpawnDelay = Duration(seconds: 2);
  static const Duration _minSpawnDelay = Duration(milliseconds: 500);
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
    _lastSpawnTime = null; // First enemy spawns immediately
  }

  @override
  void stopWave() {
    _isSpawning = false;
    _currentWaveEnemies.clear();
    _lastSpawnTime = null;
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
    _lastSpawnTime = null;
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
    final delayMs = (_baseSpawnDelay.inMilliseconds / (1 + level * 0.1))
        .round();
    final delay = Duration(milliseconds: delayMs);

    return delay.compareTo(_minSpawnDelay) > 0 ? delay : _minSpawnDelay;
  }

  @override
  bool canSpawnNextEnemy() {
    if (!_isSpawning || _currentWaveEnemies.isEmpty) {
      return false;
    }

    // First enemy can spawn immediately
    if (_lastSpawnTime == null) {
      return true;
    }

    // Check if enough time has passed
    final now = DateTime.now();
    final timeSinceLastSpawn = now.difference(_lastSpawnTime!);
    final spawnDelay = getSpawnDelay(_currentLevel);

    return timeSinceLastSpawn >= spawnDelay;
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

    // Update spawn time
    _lastSpawnTime = DateTime.now();

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
