import 'package:flutter/material.dart';

/// Wall model representing the defensive structure players must protect
class Wall {
  Wall({required this.position, int? currentHP, int? maxHP, int level = 1})
    : _currentHP = currentHP ?? _calculateMaxHP(level),
      _maxHP = maxHP ?? _calculateMaxHP(level),
      _level = level {
    _validateState();
  }

  final Offset position;
  int _currentHP;
  int _maxHP;
  int _level;

  /// Current hit points (0 to maxHP)
  int get currentHP => _currentHP;

  /// Maximum hit points for current level
  int get maxHP => _maxHP;

  /// Wall upgrade level (starts at 1)
  int get level => _level;

  /// Visual appearance that changes with level
  Color get color {
    const colors = [
      Colors.grey, // Level 1
      Colors.brown, // Level 2
      Colors.orange, // Level 3
      Colors.red, // Level 4
      Colors.purple, // Level 5+
    ];

    final index = (_level - 1).clamp(0, colors.length - 1);
    return colors[index];
  }

  /// Whether the wall is still standing
  bool get isDestroyed => _currentHP <= 0;

  /// Health percentage (0.0 to 1.0)
  double get healthPercentage => _maxHP > 0 ? _currentHP / _maxHP : 0.0;

  /// Calculate max HP based on level
  static int _calculateMaxHP(int level) {
    // HP increases exponentially: 100, 150, 225, 337, 506...
    return (100 * (1.5 * level)).round();
  }

  /// Upgrade the wall to the next level
  void upgrade() {
    _level++;
    final oldMaxHP = _maxHP;
    _maxHP = _calculateMaxHP(_level);

    // Increase current HP proportionally
    final healthRatio = _currentHP / oldMaxHP;
    _currentHP = (_maxHP * healthRatio).round();

    _validateState();
  }

  /// Take damage from enemy attacks
  void takeDamage(int damage) {
    if (damage < 0) {
      throw ArgumentError('Damage cannot be negative: $damage');
    }

    _currentHP = (_currentHP - damage).clamp(0, _maxHP);
    _validateState();
  }

  /// Heal the wall up to maximum HP
  void heal(int amount) {
    if (amount < 0) {
      throw ArgumentError('Heal amount cannot be negative: $amount');
    }

    _currentHP = (_currentHP + amount).clamp(0, _maxHP);
    _validateState();
  }

  /// Restore to full health
  void fullHeal() {
    _currentHP = _maxHP;
    _validateState();
  }

  /// Validate the wall state
  void _validateState() {
    if (_currentHP < 0) {
      throw StateError('Current HP cannot be negative: $_currentHP');
    }
    if (_currentHP > _maxHP) {
      throw StateError(
        'Current HP cannot exceed max HP: $_currentHP > $_maxHP',
      );
    }
    if (_maxHP <= 0) {
      throw StateError('Max HP must be positive: $_maxHP');
    }
    if (_level < 1) {
      throw StateError('Level must be at least 1: $_level');
    }
  }

  /// Create a copy with updated values
  Wall copyWith({Offset? position, int? currentHP, int? maxHP, int? level}) {
    return Wall(
      position: position ?? this.position,
      currentHP: currentHP ?? _currentHP,
      maxHP: maxHP ?? _maxHP,
      level: level ?? _level,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Wall &&
        other.position == position &&
        other._currentHP == _currentHP &&
        other._maxHP == _maxHP &&
        other._level == _level;
  }

  @override
  int get hashCode {
    return Object.hash(position, _currentHP, _maxHP, _level);
  }

  @override
  String toString() {
    return 'Wall(position: $position, HP: $_currentHP/$_maxHP, level: $_level)';
  }
}
