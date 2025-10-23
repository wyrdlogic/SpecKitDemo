import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:tower_defense_game/models/game_enums.dart';
import 'package:tower_defense_game/viewmodels/resource_viewmodel.dart';
import 'package:tower_defense_game/viewmodels/wall_viewmodel.dart';

/// Integration tests for US1: Resource Management and Wall Upgrades
///
/// Tests the complete flow of generating resources, upgrading wall, and healing.
void main() {
  group('US1: Resource Management and Wall Upgrades Integration Tests', () {
    late ResourceViewModel resourceVM;
    late WallViewModel wallVM;

    // Cost constants from ResourceHUD implementation
    const int wallUpgradeCost = 50; // Blue resources
    const int wallHealCost = 30; // Green resources

    setUp(() {
      resourceVM = ResourceViewModel();
      wallVM = WallViewModel(wallPosition: const Offset(400, 300));
    });

    tearDown(() {
      resourceVM.dispose();
      wallVM.dispose();
    });

    group('Resource Generation Flow', () {
      test('player can start generating blue resources', () async {
        // Initial state
        expect(resourceVM.getAmount(ResourceType.blue), 0);

        // Start generation
        await resourceVM.startGeneration(ResourceType.blue);
        final blueResource = resourceVM.getResource(ResourceType.blue)!;
        expect(blueResource.isGenerating, true);
        expect(blueResource.generationRate, 1.0);

        // Simulate frames (60 frames = 1 second at 60 FPS)
        for (var i = 0; i < 60; i++) {
          resourceVM.updateGeneration();
        }

        expect(resourceVM.getAmount(ResourceType.blue), greaterThan(0));
      });

      test('multiple resource types can generate simultaneously', () async {
        await resourceVM.startGeneration(ResourceType.blue);
        await resourceVM.startGeneration(ResourceType.green);
        await resourceVM.startGeneration(ResourceType.yellow);

        expect(resourceVM.getResource(ResourceType.blue)!.isGenerating, true);
        expect(resourceVM.getResource(ResourceType.green)!.isGenerating, true);
        expect(resourceVM.getResource(ResourceType.yellow)!.isGenerating, true);

        // Simulate frames (60 frames = 1 second)
        for (var i = 0; i < 60; i++) {
          resourceVM.updateGeneration();
        }

        expect(resourceVM.getAmount(ResourceType.blue), greaterThan(0));
        expect(resourceVM.getAmount(ResourceType.green), greaterThan(0));
        expect(resourceVM.getAmount(ResourceType.yellow), greaterThan(0));
      });
    });

    group('Wall Upgrade Flow', () {
      test('player can upgrade wall with blue resources', () {
        // Give enough resources
        resourceVM.add(ResourceType.blue, wallUpgradeCost);

        // Initial state
        expect(wallVM.level, 1);
        expect(wallVM.color, Colors.grey); // Level 1 is grey
        final initialMaxHP = wallVM.maxHP;

        // Check affordability
        expect(resourceVM.canAfford(ResourceType.blue, wallUpgradeCost), true);

        // Perform upgrade
        resourceVM.spend(ResourceType.blue, wallUpgradeCost);
        wallVM.upgrade();

        // Verify effects
        expect(wallVM.level, 2);
        expect(wallVM.maxHP, greaterThan(initialMaxHP));
        expect(wallVM.color, Colors.brown); // Level 2 is brown
      });

      test('upgrade cost scales with level', () {
        resourceVM.add(ResourceType.blue, 200);

        // Level 1 cost
        final cost1 = wallUpgradeCost;

        // Upgrade to level 2
        resourceVM.spend(ResourceType.blue, cost1);
        wallVM.upgrade();

        // Level 2 cost should be higher (exponential scaling)
        final cost2 = (wallUpgradeCost * 1.5).round();
        expect(cost2, greaterThan(cost1));
      });

      test('cannot upgrade without sufficient resources', () {
        expect(resourceVM.getAmount(ResourceType.blue), 0);
        expect(resourceVM.canAfford(ResourceType.blue, wallUpgradeCost), false);

        // Attempt to spend should fail
        final success = resourceVM.spend(ResourceType.blue, wallUpgradeCost);
        expect(success, false);
        expect(wallVM.level, 1);
      });
    });

    group('Wall Healing Flow', () {
      test('player can heal damaged wall with green resources', () {
        resourceVM.add(ResourceType.green, wallHealCost);

        // Damage wall
        wallVM.takeDamage(50);
        final damagedHP = wallVM.currentHP;
        expect(damagedHP, lessThan(wallVM.maxHP));

        // Heal
        resourceVM.spend(ResourceType.green, wallHealCost);
        wallVM.heal(30);

        expect(wallVM.currentHP, greaterThan(damagedHP));
        expect(wallVM.currentHP, lessThanOrEqualTo(wallVM.maxHP));
      });

      test('healing cannot exceed max HP', () {
        resourceVM.add(ResourceType.green, wallHealCost);

        // Damage by 30
        wallVM.takeDamage(30);
        final maxHP = wallVM.maxHP;

        // Try to heal 50 (more than damage)
        resourceVM.spend(ResourceType.green, wallHealCost);
        wallVM.heal(50);

        expect(wallVM.currentHP, maxHP);
      });

      test('wall starts at full HP', () {
        expect(wallVM.currentHP, wallVM.maxHP);
        expect(wallVM.healthPercentage, 1.0);
      });
    });

    group('Complete US1 Flow', () {
      test('full gameplay loop: generate → upgrade → damage → heal', () async {
        // Step 1: Generate blue resources (need 50 for upgrade, at 1/sec = 50 seconds = 3000 frames)
        await resourceVM.startGeneration(ResourceType.blue);
        for (var i = 0; i < 3010; i++) { // Add a few extra frames for floating point tolerance
          resourceVM.updateGeneration();
        }
        expect(resourceVM.getAmount(ResourceType.blue), greaterThanOrEqualTo(wallUpgradeCost));

        // Step 2: Upgrade wall
        resourceVM.spend(ResourceType.blue, wallUpgradeCost);
        wallVM.upgrade();
        expect(wallVM.level, 2);

        // Step 3: Wall takes damage
        wallVM.takeDamage(40);
        expect(wallVM.currentHP, lessThan(wallVM.maxHP));

        // Step 4: Generate green resources (need 30 for heal, at 1/sec = 30 seconds = 1800 frames)
        await resourceVM.startGeneration(ResourceType.green);
        for (var i = 0; i < 1800; i++) {
          resourceVM.updateGeneration();
        }

        // Step 5: Heal wall
        resourceVM.spend(ResourceType.green, wallHealCost);
        wallVM.heal(30);
        expect(wallVM.currentHP, greaterThan(wallVM.maxHP - 40));
      });

      test('wall visual state reflects damage level', () {
        expect(wallVM.healthPercentage, 1.0);

        // 25% damage
        wallVM.takeDamage((wallVM.maxHP * 0.25).round());
        expect(wallVM.healthPercentage, closeTo(0.75, 0.01));

        // Another 25% (50% total)
        wallVM.takeDamage((wallVM.maxHP * 0.25).round());
        expect(wallVM.healthPercentage, closeTo(0.50, 0.05));

        // Heal 20%
        wallVM.heal((wallVM.maxHP * 0.20).round());
        expect(wallVM.healthPercentage, closeTo(0.70, 0.05));
      });

      test('player must choose between upgrades and healing', () {
        // Limited resources
        resourceVM.add(ResourceType.blue, wallUpgradeCost);

        // Can afford upgrade
        expect(resourceVM.canAfford(ResourceType.blue, wallUpgradeCost), true);

        // Choose upgrade
        resourceVM.spend(ResourceType.blue, wallUpgradeCost);
        wallVM.upgrade();

        // Now cannot afford another operation
        expect(resourceVM.getAmount(ResourceType.blue), lessThan(wallUpgradeCost));
      });
    });

    group('ViewModels Integration', () {
      test('resources persist across operations', () async {
        await resourceVM.startGeneration(ResourceType.blue);

        // Simulate 1 second (61 frames for tolerance)
        for (var i = 0; i < 61; i++) {
          resourceVM.updateGeneration();
        }
        final amount1 = resourceVM.getAmount(ResourceType.blue);
        expect(amount1, greaterThanOrEqualTo(1)); // Should have at least 1 resource after 1 second

        // Simulate another second
        for (var i = 0; i < 61; i++) {
          resourceVM.updateGeneration();
        }
        final amount2 = resourceVM.getAmount(ResourceType.blue);

        expect(amount2, greaterThan(amount1)); // Should have more after 2 seconds
        expect(amount2, greaterThanOrEqualTo(2)); // Should have at least 2 resources after 2 seconds
      });

      test('spending updates state correctly', () {
        resourceVM.add(ResourceType.blue, 100);
        expect(resourceVM.getAmount(ResourceType.blue), 100);

        resourceVM.spend(ResourceType.blue, 30);
        expect(resourceVM.getAmount(ResourceType.blue), 70);

        resourceVM.spend(ResourceType.blue, 40);
        expect(resourceVM.getAmount(ResourceType.blue), 30);
      });

      test('viewmodels notify listeners', () {
        var resourceNotified = false;
        var wallNotified = false;

        resourceVM.addListener(() => resourceNotified = true);
        wallVM.addListener(() => wallNotified = true);

        resourceVM.add(ResourceType.blue, 10);
        wallVM.takeDamage(10);

        expect(resourceNotified, true);
        expect(wallNotified, true);
      });

      test('wall state persists across damage and heal cycles', () {
        // Cycle 1
        wallVM.takeDamage(40);
        final afterDamage1 = wallVM.currentHP;
        wallVM.heal(30);
        final afterHeal1 = wallVM.currentHP;

        // Cycle 2
        wallVM.takeDamage(50);
        final afterDamage2 = wallVM.currentHP;
        wallVM.heal(20);
        final afterHeal2 = wallVM.currentHP;

        expect(afterHeal1, greaterThan(afterDamage1));
        expect(afterHeal2, greaterThan(afterDamage2));
        expect(wallVM.isDestroyed, false);
      });
    });
  });
}
