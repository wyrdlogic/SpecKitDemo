import 'package:flutter/material.dart';

/// Enumeration for resource types in the game
enum ResourceType {
  blue('Blue', Colors.blue),
  green('Green', Colors.green),
  yellow('Yellow', Colors.yellow);

  const ResourceType(this.displayName, this.color);

  final String displayName;
  final Color color;
}

/// Enumeration for game states
enum GameState {
  menu('Menu'),
  playing('Playing'),
  paused('Paused'),
  gameOver('Game Over');

  const GameState(this.displayName);

  final String displayName;
}

/// Enumeration for enemy types
enum EnemyType {
  basic('Basic', 100, 25, 50.0),
  strong('Strong', 200, 50, 30.0),
  fast('Fast', 75, 15, 100.0);

  const EnemyType(
    this.displayName,
    this.baseHp,
    this.baseDamage,
    this.baseSpeed,
  );

  final String displayName;
  final int baseHp;
  final int baseDamage;
  final double baseSpeed;
}
