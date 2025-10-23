import '../models/wave.dart';
import 'interfaces/i_difficulty_scaler.dart';
import 'dart:math' as math;

/// Service implementation for managing game difficulty progression
final class DifficultyScalerService implements IDifficultyScaler {
  /// Base HP scaling per level (20% increase per level)
  static const double _hpScaleFactor = 0.2;

  /// Base damage scaling per level (15% increase per level)
  static const double _damageScaleFactor = 0.15;

  /// Base speed scaling per level (10% increase per level)
  static const double _speedScaleFactor = 0.1;

  /// Base spawn rate scaling per level (15% increase per level)
  static const double _spawnRateScaleFactor = 0.15;

  /// Base cost scaling per level (exponential, 1.5x per level)
  static const double _costScaleFactor = 1.5;

  @override
  int scaleEnemyHP(int baseHP, int level) {
    if (level <= 1) return baseHP;
    final multiplier = calculateLinearScale(1.0, level, _hpScaleFactor);
    return (baseHP * multiplier).round();
  }

  @override
  int scaleEnemyDamage(int baseDamage, int level) {
    if (level <= 1) return baseDamage;
    final multiplier = calculateLinearScale(1.0, level, _damageScaleFactor);
    return (baseDamage * multiplier).round();
  }

  @override
  double scaleEnemySpeed(double baseSpeed, int level) {
    if (level <= 1) return baseSpeed;
    return calculateLinearScale(baseSpeed, level, _speedScaleFactor);
  }

  @override
  double scaleSpawnRate(double baseRate, int level) {
    if (level <= 1) return baseRate;
    return calculateLinearScale(baseRate, level, _spawnRateScaleFactor);
  }

  @override
  Map<String, int> scaleUpgradeCosts(
    Map<String, int> baseCosts,
    int currentLevel,
  ) {
    if (currentLevel <= 1) return Map.from(baseCosts);

    final multiplier = calculateExponentialScale(
      1.0,
      currentLevel,
      _costScaleFactor,
    );
    return baseCosts.map(
      (key, value) => MapEntry(key, (value * multiplier).round()),
    );
  }

  @override
  double getDifficultyMultiplier(int level) {
    if (level <= 1) return 1.0;
    // Overall difficulty increases by 25% per level
    return 1.0 + (level - 1) * 0.25;
  }

  @override
  double getScoreMultiplier(int level) {
    // Score multiplier increases with level
    return 1.0 + (level - 1) * 0.1;
  }

  @override
  int getRecommendedWallHP(int level) {
    // Recommended wall HP scales with level
    const baseHP = 100;
    return scaleEnemyHP(baseHP, level);
  }

  @override
  Map<String, double> getResourceGenerationRates(int level) {
    // Resource generation rates scale with level
    final baseRate = 1.0;
    final scaledRate = scaleSpawnRate(baseRate, level);

    return {
      'blue': scaledRate,
      'green': scaledRate * 0.8,
      'yellow': scaledRate * 0.6,
    };
  }

  @override
  Wave generateNextWave(int currentLevel) {
    // Calculate wave parameters based on level
    final duration = 60; // Always 60 seconds per wave
    final enemySpawnRate = _calculateWaveSpawnRate(currentLevel);

    return Wave(
      level: currentLevel,
      duration: duration,
      enemySpawnRate: enemySpawnRate,
    );
  }

  /// Calculate spawn rate for a wave based on level
  double _calculateWaveSpawnRate(int level) {
    // Start at 0.5 enemies/second, increase by 0.25 per level
    return 0.5 + (level - 1) * 0.25;
  }

  @override
  List<String> getUnlockedFeatures(int level) {
    final features = <String>[];

    if (level >= 1) features.add('basic_enemy');
    if (level >= 3) features.add('fast_enemy');
    if (level >= 5) features.add('tank_enemy');
    if (level >= 7) features.add('boss_enemy');
    if (level >= 2) features.add('wall_upgrade');
    if (level >= 3) features.add('resource_efficiency');

    return features;
  }

  @override
  double calculateExponentialScale(
    double base,
    int level,
    double growthFactor,
  ) {
    if (level <= 1) return base;
    // Exponential: base * growthFactor^(level-1)
    return base * math.pow(growthFactor, level - 1);
  }

  @override
  double calculateLinearScale(double base, int level, double growthFactor) {
    if (level <= 1) return base;
    // Linear: base * (1 + growthFactor * (level-1))
    return base * (1.0 + growthFactor * (level - 1));
  }
}
