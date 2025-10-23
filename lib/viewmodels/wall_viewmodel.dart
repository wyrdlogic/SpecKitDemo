import 'package:flutter/material.dart';
import 'package:tower_defense_game/viewmodels/base_viewmodel.dart';
import 'package:tower_defense_game/models/wall.dart';

/// ViewModel for managing the defensive wall
final class WallViewModel extends BaseViewModel {
  WallViewModel({required Offset wallPosition}) {
    _wall = Wall(position: wallPosition);
  }

  late Wall _wall;

  /// Get the current wall
  Wall get wall => _wall;

  /// Get wall current HP
  int get currentHP => _wall.currentHP;

  /// Get wall max HP
  int get maxHP => _wall.maxHP;

  /// Get wall level
  int get level => _wall.level;

  /// Get wall color
  Color get color => _wall.color;

  /// Get wall position
  Offset get position => _wall.position;

  /// Check if wall is destroyed
  bool get isDestroyed => _wall.isDestroyed;

  /// Get wall health percentage
  double get healthPercentage => _wall.healthPercentage;

  /// Upgrade the wall to next level
  Future<void> upgrade() async {
    _wall.upgrade();
    notifyListeners();
  }

  /// Take damage from enemy attack
  void takeDamage(int damage) {
    _wall.takeDamage(damage);
    notifyListeners();
  }

  /// Heal the wall
  Future<void> heal(int amount) async {
    _wall.heal(amount);
    notifyListeners();
  }

  /// Fully heal the wall
  Future<void> fullHeal() async {
    _wall.fullHeal();
    notifyListeners();
  }

  /// Reset wall to initial state
  @override
  void reset() {
    super.reset();
    _wall = Wall(position: _wall.position);
    notifyListeners();
  }

  /// Reset wall to a new position
  void resetAtPosition(Offset position) {
    _wall = Wall(position: position);
    notifyListeners();
  }

  @override
  void dispose() {
    // Clean up if needed
    super.dispose();
  }
}
