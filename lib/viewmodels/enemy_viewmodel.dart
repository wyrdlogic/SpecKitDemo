import 'package:flutter/material.dart';
import 'package:tower_defense_game/viewmodels/base_viewmodel.dart';
import 'package:tower_defense_game/models/enemy.dart';
import 'package:tower_defense_game/models/game_enums.dart';

/// ViewModel for managing enemies in the game
final class EnemyViewModel extends BaseViewModel {
  EnemyViewModel();

  final List<Enemy> _enemies = [];

  /// Get all active enemies
  List<Enemy> get enemies => List.unmodifiable(_enemies);

  /// Get count of active enemies
  int get activeEnemyCount => _enemies.where((e) => e.isAlive).length;

  /// Get all alive enemies
  List<Enemy> get aliveEnemies => _enemies.where((e) => e.isAlive).toList();

  /// Add a new enemy to the game
  void addEnemy(Enemy enemy) {
    _enemies.add(enemy);
    notifyListeners();
  }

  /// Remove an enemy from the game
  void removeEnemy(Enemy enemy) {
    _enemies.remove(enemy);
    notifyListeners();
  }

  /// Remove all dead enemies
  void removeDeadEnemies() {
    _enemies.removeWhere((enemy) => !enemy.isAlive);
    notifyListeners();
  }

  /// Clear all enemies
  void clearAll() {
    _enemies.clear();
    notifyListeners();
  }

  /// Update all enemies (movement, cooldowns)
  void updateEnemies(double deltaTime) {
    for (final enemy in _enemies) {
      if (enemy.isAlive) {
        enemy.moveTowardTarget(deltaTime);
        enemy.updateCooldown();
      }
    }
    notifyListeners();
  }

  /// Get enemies that have reached their target (wall)
  List<Enemy> getEnemiesAtTarget() {
    return _enemies.where((e) => e.isAlive && e.hasReachedTarget).toList();
  }

  /// Damage an enemy
  void damageEnemy(Enemy enemy, int damage) {
    enemy.takeDamage(damage);
    notifyListeners();
  }

  /// Kill an enemy immediately
  void killEnemy(Enemy enemy) {
    enemy.kill();
    notifyListeners();
  }

  /// Spawn enemy at position with target
  Future<void> spawnEnemy({
    required EnemyType type,
    required Offset position,
    required Offset target,
    int? level,
  }) async {
    final enemy = Enemy(type: type, position: position, target: target);

    if (level != null && level > 1) {
      enemy.scaleForLevel(level);
    }

    addEnemy(enemy);
  }

  /// Spawn multiple enemies
  Future<void> spawnEnemies({
    required EnemyType type,
    required List<Offset> positions,
    required Offset target,
    int? level,
  }) async {
    for (final position in positions) {
      await spawnEnemy(
        type: type,
        position: position,
        target: target,
        level: level,
      );
    }
  }

  @override
  void dispose() {
    _enemies.clear();
    super.dispose();
  }
}
