import '../../models/wave.dart';

/// Interface for managing game difficulty and level progression
abstract interface class IDifficultyScaler {
  /// Calculate enemy HP scaling for a given level
  int scaleEnemyHP(int baseHP, int level);

  /// Calculate enemy damage scaling for a given level
  int scaleEnemyDamage(int baseDamage, int level);

  /// Calculate enemy speed scaling for a given level
  double scaleEnemySpeed(double baseSpeed, int level);

  /// Calculate spawn rate scaling for a given level
  double scaleSpawnRate(double baseRate, int level);

  /// Calculate upgrade costs scaling for a given level
  Map<String, int> scaleUpgradeCosts(
    Map<String, int> baseCosts,
    int currentLevel,
  );

  /// Get the difficulty multiplier for a given level
  double getDifficultyMultiplier(int level);

  /// Calculate score multiplier for level
  double getScoreMultiplier(int level);

  /// Get recommended wall HP for a level
  int getRecommendedWallHP(int level);

  /// Calculate resource generation balance for level
  Map<String, double> getResourceGenerationRates(int level);

  /// Determine next wave configuration
  Wave generateNextWave(int currentLevel);

  /// Check if level should unlock new features
  List<String> getUnlockedFeatures(int level);

  /// Calculate exponential scaling factor
  double calculateExponentialScale(double base, int level, double growthFactor);

  /// Calculate linear scaling factor
  double calculateLinearScale(double base, int level, double growthFactor);
}
