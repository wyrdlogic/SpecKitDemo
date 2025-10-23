import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'game_enums.dart';

/// Enemy model representing attacking units
class Enemy {
  Enemy({
    required this.type,
    required this.position,
    required this.target,
    int? hp,
    int? damage,
    double? speed,
    int attackCooldown = 0,
  }) : _hp = hp ?? type.baseHp,
       _damage = damage ?? type.baseDamage,
       _speed = speed ?? type.baseSpeed,
       _attackCooldown = attackCooldown,
       _isAlive = true {
    _validateState();
  }

  final EnemyType type;
  Offset position;
  final Offset target;

  int _hp;
  int _damage;
  double _speed;
  int _attackCooldown;
  bool _isAlive;

  /// Enemy hit points
  int get hp => _hp;

  /// Damage dealt per attack
  int get damage => _damage;

  /// Movement speed (pixels per frame)
  double get speed => _speed;

  /// Active state flag
  bool get isAlive => _isAlive;

  /// Frames between attacks
  int get attackCooldown => _attackCooldown;

  /// Whether enemy can attack (cooldown is 0)
  bool get canAttack => _attackCooldown <= 0 && _isAlive;

  /// Distance to target
  double get distanceToTarget {
    final dx = target.dx - position.dx;
    final dy = target.dy - position.dy;
    return (dx * dx + dy * dy);
  }

  /// Whether enemy has reached the target (within attack range)
  bool get hasReachedTarget {
    const attackRange = 50.0; // pixels
    return distanceToTarget <= (attackRange * attackRange);
  }

  /// Move toward the target
  void moveTowardTarget(double deltaTime) {
    if (!_isAlive) return;

    final dx = target.dx - position.dx;
    final dy = target.dy - position.dy;
    final distance = (dx * dx + dy * dy);

    if (distance > 1.0) {
      // Avoid division by zero
      final magnitude = distance.sqrt();
      final normalizedDx = dx / magnitude;
      final normalizedDy = dy / magnitude;

      final moveDistance = _speed * deltaTime;
      position = Offset(
        position.dx + normalizedDx * moveDistance,
        position.dy + normalizedDy * moveDistance,
      );
    }
  }

  /// Take damage and potentially die
  void takeDamage(int damageAmount) {
    if (damageAmount < 0) {
      throw ArgumentError('Damage cannot be negative: $damageAmount');
    }

    _hp = (_hp - damageAmount).clamp(0, type.baseHp);

    if (_hp <= 0) {
      _isAlive = false;
    }

    _validateState();
  }

  /// Perform attack and return damage dealt
  int attack() {
    if (!canAttack) {
      return 0;
    }

    _attackCooldown = 60; // 1 second at 60 FPS
    return _damage;
  }

  /// Update attack cooldown (call each frame)
  void updateCooldown() {
    if (_attackCooldown > 0) {
      _attackCooldown--;
    }
  }

  /// Kill the enemy immediately
  void kill() {
    _hp = 0;
    _isAlive = false;
    _validateState();
  }

  /// Scale enemy stats for difficulty
  void scaleForLevel(int level) {
    if (level < 1) {
      throw ArgumentError('Level must be at least 1: $level');
    }

    // Scale HP and damage exponentially with level
    final scaleFactor = 1.0 + (level - 1) * 0.2; // 20% increase per level
    _hp = (type.baseHp * scaleFactor).round();
    _damage = (type.baseDamage * scaleFactor).round();

    _validateState();
  }

  /// Validate the enemy state
  void _validateState() {
    if (_hp < 0) {
      throw StateError('HP cannot be negative: $_hp');
    }
    if (_damage < 0) {
      throw StateError('Damage cannot be negative: $_damage');
    }
    if (_speed < 0) {
      throw StateError('Speed cannot be negative: $_speed');
    }
    if (_attackCooldown < 0) {
      throw StateError('Attack cooldown cannot be negative: $_attackCooldown');
    }
  }

  /// Create a copy with updated values
  Enemy copyWith({
    EnemyType? type,
    Offset? position,
    Offset? target,
    int? hp,
    int? damage,
    double? speed,
    int? attackCooldown,
    bool? isAlive,
  }) {
    final copy = Enemy(
      type: type ?? this.type,
      position: position ?? this.position,
      target: target ?? this.target,
      hp: hp ?? _hp,
      damage: damage ?? _damage,
      speed: speed ?? _speed,
      attackCooldown: attackCooldown ?? _attackCooldown,
    );

    if (isAlive != null) {
      copy._isAlive = isAlive;
    }

    return copy;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Enemy &&
        other.type == type &&
        other.position == position &&
        other.target == target &&
        other._hp == _hp &&
        other._damage == _damage &&
        other._speed == _speed &&
        other._attackCooldown == _attackCooldown &&
        other._isAlive == _isAlive;
  }

  @override
  int get hashCode {
    return Object.hash(
      type,
      position,
      target,
      _hp,
      _damage,
      _speed,
      _attackCooldown,
      _isAlive,
    );
  }

  @override
  String toString() {
    return 'Enemy(type: ${type.displayName}, HP: $_hp, pos: $position, alive: $_isAlive)';
  }
}

extension DoubleExtension on double {
  double sqrt() => math.sqrt(this);
}
