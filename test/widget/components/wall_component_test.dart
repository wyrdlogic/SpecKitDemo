import 'package:flutter_test/flutter_test.dart';
import 'package:tower_defense_game/viewmodels/wall_viewmodel.dart';

/// Widget tests for WallComponent Flame component
/// 
/// Note: Flame components are best tested through integration tests
/// since they require a FlameGame context. These tests focus on
/// verifying the WallViewModel behavior that drives the component.
void main() {
  group('WallComponent Integration Tests', () {
    late WallViewModel wallViewModel;

    setUp(() {
      wallViewModel = WallViewModel(wallPosition: const Offset(400, 300));
    });

    tearDown(() {
      wallViewModel.dispose();
    });

    test('wall initializes with correct properties', () {
      expect(wallViewModel.position, const Offset(400, 300));
      expect(wallViewModel.level, 1);
      expect(wallViewModel.currentHP, 150); // Level 1: 100 * 1.5 = 150
      expect(wallViewModel.maxHP, 150);
      expect(wallViewModel.isDestroyed, false);
      expect(wallViewModel.healthPercentage, 1.0);
    });

    test('wall takes damage and updates health percentage', () {
      final initialHP = wallViewModel.currentHP;
      
      wallViewModel.takeDamage(20);
      
      expect(wallViewModel.currentHP, initialHP - 20);
      expect(wallViewModel.healthPercentage, closeTo(0.867, 0.01)); // 130/150
      expect(wallViewModel.isDestroyed, false);
    });

    test('wall can be healed', () {
      wallViewModel.takeDamage(30);
      final damagedHP = wallViewModel.currentHP;
      
      wallViewModel.heal(20);
      
      expect(wallViewModel.currentHP, damagedHP + 20);
      expect(wallViewModel.currentHP, lessThan(wallViewModel.maxHP));
    });

    test('wall cannot be healed above max HP', () {
      wallViewModel.takeDamage(10);
      wallViewModel.heal(50); // Try to overheal
      
      expect(wallViewModel.currentHP, wallViewModel.maxHP);
    });

    test('wall upgrades increase level and stats', () {
      final initialLevel = wallViewModel.level;
      final initialMaxHP = wallViewModel.maxHP;
      
      wallViewModel.upgrade();
      
      expect(wallViewModel.level, initialLevel + 1);
      expect(wallViewModel.maxHP, greaterThan(initialMaxHP));
    });

    test('wall color changes with level', () {
      final initialColor = wallViewModel.color;
      
      wallViewModel.upgrade();
      
      expect(wallViewModel.color, isNot(initialColor));
    });

    test('wall can be destroyed by sufficient damage', () {
      wallViewModel.takeDamage(wallViewModel.currentHP);
      
      expect(wallViewModel.isDestroyed, true);
      expect(wallViewModel.currentHP, 0);
      expect(wallViewModel.healthPercentage, 0.0);
    });

    test('wall health percentage reflects damage', () {
      // Full health
      expect(wallViewModel.healthPercentage, 1.0);
      
      // Half health
      wallViewModel.takeDamage((wallViewModel.maxHP * 0.5).round());
      expect(wallViewModel.healthPercentage, closeTo(0.5, 0.01));
      
      // Critical health
      wallViewModel.takeDamage((wallViewModel.maxHP * 0.3).round());
      expect(wallViewModel.healthPercentage, lessThan(0.25));
    });

    test('wall position can be updated', () {
      expect(wallViewModel.position, const Offset(400, 300));
      
      wallViewModel.resetAtPosition(const Offset(500, 400));
      
      expect(wallViewModel.position, const Offset(500, 400));
      expect(wallViewModel.level, 1); // Reset to level 1
      expect(wallViewModel.currentHP, wallViewModel.maxHP); // Full health
    });

    test('wall notifies listeners on damage', () {
      var notified = false;
      wallViewModel.addListener(() => notified = true);
      
      wallViewModel.takeDamage(10);
      
      expect(notified, true);
    });

    test('wall notifies listeners on heal', () {
      wallViewModel.takeDamage(20);
      var notified = false;
      wallViewModel.addListener(() => notified = true);
      
      wallViewModel.heal(10);
      
      expect(notified, true);
    });

    test('wall notifies listeners on upgrade', () {
      var notified = false;
      wallViewModel.addListener(() => notified = true);
      
      wallViewModel.upgrade();
      
      expect(notified, true);
    });

    test('wall can be reset to initial state', () {
      // Damage and upgrade the wall
      wallViewModel.upgrade();
      wallViewModel.takeDamage(30);
      
      wallViewModel.reset();
      
      expect(wallViewModel.level, 1);
      expect(wallViewModel.currentHP, 150); // Level 1: 100 * 1.5 = 150
      expect(wallViewModel.maxHP, 150);
      expect(wallViewModel.isDestroyed, false);
    });

    test('multiple upgrades compound wall stats', () {
      final initialMaxHP = wallViewModel.maxHP;
      
      wallViewModel.upgrade(); // Level 2
      final level2MaxHP = wallViewModel.maxHP;
      expect(level2MaxHP, greaterThan(initialMaxHP));
      
      wallViewModel.upgrade(); // Level 3
      final level3MaxHP = wallViewModel.maxHP;
      expect(level3MaxHP, greaterThan(level2MaxHP));
    });

    test('wall survives multiple damage and heal cycles', () {
      // Starting HP: 150
      // Cycle 1
      wallViewModel.takeDamage(40);
      expect(wallViewModel.currentHP, 110);
      wallViewModel.heal(30);
      expect(wallViewModel.currentHP, 140);
      
      // Cycle 2
      wallViewModel.takeDamage(50);
      expect(wallViewModel.currentHP, 90);
      wallViewModel.heal(40);
      expect(wallViewModel.currentHP, 130);
      
      expect(wallViewModel.isDestroyed, false);
    });
  });
}

