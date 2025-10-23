import 'package:flutter_test/flutter_test.dart';
import 'package:tower_defense_game/services/difficulty_scaler_service.dart';
import 'package:tower_defense_game/services/interfaces/i_difficulty_scaler.dart';

void main() {
  group('DifficultyScalerService Tests', () {
    late IDifficultyScaler scaler;

    setUp(() {
      scaler = DifficultyScalerService();
    });

    group('Enemy HP Scaling', () {
      test('scales enemy HP linearly with level', () {
        const baseHP = 100;

        final level1HP = scaler.scaleEnemyHP(baseHP, 1);
        final level5HP = scaler.scaleEnemyHP(baseHP, 5);
        final level10HP = scaler.scaleEnemyHP(baseHP, 10);

        expect(level1HP, equals(baseHP));
        expect(level5HP, greaterThan(level1HP));
        expect(level10HP, greaterThan(level5HP));
      });

      test('level 1 returns base HP', () {
        const baseHP = 100;

        final scaledHP = scaler.scaleEnemyHP(baseHP, 1);

        expect(scaledHP, equals(baseHP));
      });

      test('higher levels increase HP proportionally', () {
        const baseHP = 100;

        final level2HP = scaler.scaleEnemyHP(baseHP, 2);
        final level3HP = scaler.scaleEnemyHP(baseHP, 3);

        // Each level should add approximately 20% more HP
        expect(level2HP, closeTo(120, 5));
        expect(level3HP, closeTo(140, 5));
      });
    });

    group('Enemy Damage Scaling', () {
      test('scales enemy damage with level', () {
        const baseDamage = 10;

        final level1Damage = scaler.scaleEnemyDamage(baseDamage, 1);
        final level5Damage = scaler.scaleEnemyDamage(baseDamage, 5);

        expect(level1Damage, equals(baseDamage));
        expect(level5Damage, greaterThan(level1Damage));
      });

      test('damage increases linearly', () {
        const baseDamage = 10;

        final level2Damage = scaler.scaleEnemyDamage(baseDamage, 2);
        final level3Damage = scaler.scaleEnemyDamage(baseDamage, 3);

        // Each level should add approximately 15% more damage
        expect(level2Damage, closeTo(11.5, 1));
        expect(level3Damage, closeTo(13, 1));
      });
    });

    group('Enemy Speed Scaling', () {
      test('scales enemy speed with level', () {
        const baseSpeed = 50.0;

        final level1Speed = scaler.scaleEnemySpeed(baseSpeed, 1);
        final level5Speed = scaler.scaleEnemySpeed(baseSpeed, 5);

        expect(level1Speed, equals(baseSpeed));
        expect(level5Speed, greaterThan(level1Speed));
      });

      test('speed increases at slower rate than HP/damage', () {
        const baseSpeed = 50.0;

        final level2Speed = scaler.scaleEnemySpeed(baseSpeed, 2);

        // Speed should increase by ~10% per level
        expect(level2Speed, closeTo(55.0, 3));
      });
    });

    group('Upgrade Cost Scaling', () {
      test('scales upgrade costs exponentially', () {
        final baseCosts = {'red': 100, 'blue': 150};

        final level1Costs = scaler.scaleUpgradeCosts(baseCosts, 1);
        final level2Costs = scaler.scaleUpgradeCosts(baseCosts, 2);

        expect(level1Costs['red'], equals(100));
        expect(level2Costs['red']!, greaterThan(level1Costs['red']!));
      });

      test('higher levels have significantly higher costs', () {
        final baseCosts = {'red': 100};

        final level1Costs = scaler.scaleUpgradeCosts(baseCosts, 1);
        final level5Costs = scaler.scaleUpgradeCosts(baseCosts, 5);

        // Exponential growth should make level 5 much more expensive
        expect(level5Costs['red']! / level1Costs['red']!, greaterThan(3));
      });
    });

    group('Difficulty Multiplier', () {
      test('returns multiplier for difficulty scaling', () {
        final mult1 = scaler.getDifficultyMultiplier(1);
        final mult5 = scaler.getDifficultyMultiplier(5);
        final mult10 = scaler.getDifficultyMultiplier(10);

        expect(mult1, equals(1.0));
        expect(mult5, greaterThan(mult1));
        expect(mult10, greaterThan(mult5));
      });
    });

    group('Score Multiplier', () {
      test('returns score multiplier for level', () {
        final mult1 = scaler.getScoreMultiplier(1);
        final mult5 = scaler.getScoreMultiplier(5);

        expect(mult1, greaterThanOrEqualTo(1.0));
        expect(mult5, greaterThan(mult1));
      });
    });

    group('Wall HP Recommendation', () {
      test('recommends wall HP for level', () {
        final hp1 = scaler.getRecommendedWallHP(1);
        final hp10 = scaler.getRecommendedWallHP(10);

        expect(hp1, greaterThan(0));
        expect(hp10, greaterThan(hp1));
      });
    });

    group('Resource Generation Rates', () {
      test('returns resource generation rates for level', () {
        final rates = scaler.getResourceGenerationRates(1);

        expect(rates, isNotEmpty);
        expect(rates.keys, contains('blue'));
        expect(rates.keys, contains('green'));
        expect(rates.keys, contains('yellow'));
      });

      test('higher levels have better generation rates', () {
        final rates1 = scaler.getResourceGenerationRates(1);
        final rates5 = scaler.getResourceGenerationRates(5);

        expect(rates5['blue']!, greaterThanOrEqualTo(rates1['blue']!));
      });
    });

    group('Wave Generation', () {
      test('generates wave for given level', () {
        final wave = scaler.generateNextWave(1);

        expect(wave.level, equals(1));
        expect(wave.duration, greaterThan(0));
      });

      test('higher level waves are more difficult', () {
        final wave1 = scaler.generateNextWave(1);
        final wave10 = scaler.generateNextWave(10);

        expect(wave10.level, greaterThan(wave1.level));
        expect(wave10.enemySpawnRate, greaterThan(wave1.enemySpawnRate));
      });
    });

    group('Feature Unlocking', () {
      test('returns unlocked features for level', () {
        final features = scaler.getUnlockedFeatures(1);

        expect(features, isA<List<String>>());
      });

      test('higher levels unlock more features', () {
        final features1 = scaler.getUnlockedFeatures(1);
        final features10 = scaler.getUnlockedFeatures(10);

        expect(features10.length, greaterThanOrEqualTo(features1.length));
      });
    });

    group('Scaling Calculations', () {
      test('calculateExponentialScale works correctly', () {
        final scale1 = scaler.calculateExponentialScale(100, 1, 1.5);
        final scale2 = scaler.calculateExponentialScale(100, 2, 1.5);

        expect(scale1, equals(100));
        expect(scale2, greaterThan(scale1));
      });

      test('calculateLinearScale works correctly', () {
        final scale1 = scaler.calculateLinearScale(100, 1, 0.2);
        final scale2 = scaler.calculateLinearScale(100, 2, 0.2);

        expect(scale1, equals(100));
        expect(scale2, equals(120));
      });
    });

    group('Consistency', () {
      test('all scaling methods return positive values', () {
        final hp = scaler.scaleEnemyHP(100, 5);
        final damage = scaler.scaleEnemyDamage(10, 5);
        final speed = scaler.scaleEnemySpeed(50, 5);

        expect(hp, greaterThan(0));
        expect(damage, greaterThan(0));
        expect(speed, greaterThan(0));
      });

      test('scaling is monotonically increasing', () {
        final hp1 = scaler.scaleEnemyHP(100, 1);
        final hp5 = scaler.scaleEnemyHP(100, 5);
        final hp10 = scaler.scaleEnemyHP(100, 10);

        expect(hp5, greaterThanOrEqualTo(hp1));
        expect(hp10, greaterThanOrEqualTo(hp5));
      });
    });

    group('Edge Cases', () {
      test('handles level 1 correctly', () {
        final hp = scaler.scaleEnemyHP(100, 1);
        final damage = scaler.scaleEnemyDamage(10, 1);
        final speed = scaler.scaleEnemySpeed(50, 1);

        expect(hp, equals(100));
        expect(damage, equals(10));
        expect(speed, equals(50));
      });

      test('handles high levels correctly', () {
        final hp = scaler.scaleEnemyHP(100, 100);
        final damage = scaler.scaleEnemyDamage(10, 100);

        expect(hp, greaterThan(100));
        expect(damage, greaterThan(10));
      });
    });
  });
}
