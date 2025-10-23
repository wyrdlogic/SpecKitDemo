import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tower_defense_game/viewmodels/wall_viewmodel.dart';

void main() {
  group('WallViewModel Tests', () {
    late WallViewModel viewModel;
    const testPosition = Offset(100, 200);

    setUp(() {
      viewModel = WallViewModel(wallPosition: testPosition);
    });

    tearDown(() {
      viewModel.dispose();
    });

    group('Initialization', () {
      test('initializes with wall at specified position', () {
        expect(viewModel.position, equals(testPosition));
        expect(viewModel.wall, isNotNull);
      });

      test('initializes with level 1', () {
        expect(viewModel.level, equals(1));
      });

      test('initializes with full health', () {
        expect(viewModel.currentHP, equals(viewModel.maxHP));
        expect(viewModel.healthPercentage, equals(1.0));
        expect(viewModel.isDestroyed, isFalse);
      });

      test('initializes with correct color for level 1', () {
        expect(viewModel.color, equals(Colors.grey));
      });
    });

    group('Wall Properties', () {
      test('wall getter returns current wall instance', () {
        final wall = viewModel.wall;
        expect(wall.position, equals(testPosition));
        expect(wall.level, equals(1));
      });

      test('currentHP returns wall current HP', () {
        expect(viewModel.currentHP, greaterThan(0));
        expect(viewModel.currentHP, equals(viewModel.wall.currentHP));
      });

      test('maxHP returns wall max HP', () {
        expect(viewModel.maxHP, greaterThan(0));
        expect(viewModel.maxHP, equals(viewModel.wall.maxHP));
      });

      test('level returns wall level', () {
        expect(viewModel.level, equals(viewModel.wall.level));
      });

      test('color returns wall color', () {
        expect(viewModel.color, equals(viewModel.wall.color));
      });

      test('position returns wall position', () {
        expect(viewModel.position, equals(testPosition));
      });

      test('isDestroyed reflects wall state', () {
        expect(viewModel.isDestroyed, equals(viewModel.wall.isDestroyed));
      });

      test('healthPercentage reflects wall health percentage', () {
        expect(
          viewModel.healthPercentage,
          equals(viewModel.wall.healthPercentage),
        );
      });
    });

    group('Wall Upgrade', () {
      test('upgrade increases wall level', () async {
        final initialLevel = viewModel.level;

        await viewModel.upgrade();

        expect(viewModel.level, equals(initialLevel + 1));
      });

      test('upgrade increases max HP', () async {
        final initialMaxHP = viewModel.maxHP;

        await viewModel.upgrade();

        expect(viewModel.maxHP, greaterThan(initialMaxHP));
      });

      test('upgrade changes wall color', () async {
        final initialColor = viewModel.color;

        await viewModel.upgrade();

        // Color should change after level up
        expect(viewModel.color, isNot(equals(initialColor)));
      });

      test('upgrade notifies listeners', () async {
        var notified = false;
        viewModel.addListener(() {
          notified = true;
        });

        await viewModel.upgrade();

        expect(notified, isTrue);
      });

      test('multiple upgrades increase level progressively', () async {
        expect(viewModel.level, equals(1));

        await viewModel.upgrade();
        expect(viewModel.level, equals(2));

        await viewModel.upgrade();
        expect(viewModel.level, equals(3));

        await viewModel.upgrade();
        expect(viewModel.level, equals(4));
      });
    });

    group('Wall Damage', () {
      test('takeDamage reduces current HP', () {
        final initialHP = viewModel.currentHP;

        viewModel.takeDamage(20);

        expect(viewModel.currentHP, equals(initialHP - 20));
      });

      test('takeDamage updates health percentage', () {
        final initialPercentage = viewModel.healthPercentage;

        viewModel.takeDamage(20);

        expect(viewModel.healthPercentage, lessThan(initialPercentage));
      });

      test('takeDamage cannot reduce HP below zero', () {
        final maxDamage = viewModel.maxHP * 2;

        viewModel.takeDamage(maxDamage);

        expect(viewModel.currentHP, equals(0));
        expect(viewModel.isDestroyed, isTrue);
      });

      test('takeDamage notifies listeners', () {
        var notified = false;
        viewModel.addListener(() {
          notified = true;
        });

        viewModel.takeDamage(10);

        expect(notified, isTrue);
      });

      test('multiple damage calls accumulate', () {
        final initialHP = viewModel.currentHP;

        viewModel.takeDamage(10);
        viewModel.takeDamage(15);
        viewModel.takeDamage(5);

        expect(viewModel.currentHP, equals(initialHP - 30));
      });
    });

    group('Wall Healing', () {
      test('heal increases current HP', () async {
        // Damage wall first
        viewModel.takeDamage(50);
        final damagedHP = viewModel.currentHP;

        await viewModel.heal(20);

        expect(viewModel.currentHP, equals(damagedHP + 20));
      });

      test('heal cannot exceed max HP', () async {
        viewModel.takeDamage(10);

        await viewModel.heal(1000);

        expect(viewModel.currentHP, equals(viewModel.maxHP));
      });

      test('heal notifies listeners', () async {
        viewModel.takeDamage(50);

        var notified = false;
        viewModel.addListener(() {
          notified = true;
        });

        await viewModel.heal(20);

        expect(notified, isTrue);
      });

      test('fullHeal restores to max HP', () async {
        viewModel.takeDamage(100);
        expect(viewModel.currentHP, lessThan(viewModel.maxHP));

        await viewModel.fullHeal();

        expect(viewModel.currentHP, equals(viewModel.maxHP));
        expect(viewModel.healthPercentage, equals(1.0));
      });

      test('fullHeal notifies listeners', () async {
        viewModel.takeDamage(50);

        var notified = false;
        viewModel.addListener(() {
          notified = true;
        });

        await viewModel.fullHeal();

        expect(notified, isTrue);
      });
    });

    group('Wall Reset', () {
      test('reset restores wall to level 1', () async {
        await viewModel.upgrade();
        await viewModel.upgrade();
        expect(viewModel.level, greaterThan(1));

        viewModel.reset();

        expect(viewModel.level, equals(1));
      });

      test('reset restores full health', () {
        viewModel.takeDamage(100);
        expect(viewModel.currentHP, lessThan(viewModel.maxHP));

        viewModel.reset();

        expect(viewModel.currentHP, equals(viewModel.maxHP));
      });

      test('reset maintains position', () {
        const originalPosition = testPosition;

        viewModel.reset();

        expect(viewModel.position, equals(originalPosition));
      });

      test('resetAtPosition changes wall position', () {
        const newPosition = Offset(300, 400);

        viewModel.resetAtPosition(newPosition);

        expect(viewModel.position, equals(newPosition));
        expect(viewModel.level, equals(1));
        expect(viewModel.currentHP, equals(viewModel.maxHP));
      });

      test('reset notifies listeners', () {
        var notified = false;
        viewModel.addListener(() {
          notified = true;
        });

        viewModel.reset();

        expect(notified, isTrue);
      });
    });

    group('ViewModel State Changes', () {
      test('notifies listeners on each state change', () async {
        var notificationCount = 0;
        viewModel.addListener(() {
          notificationCount++;
        });

        await viewModel.upgrade(); // 1
        viewModel.takeDamage(10); // 2
        await viewModel.heal(5); // 3
        await viewModel.fullHeal(); // 4

        expect(notificationCount, equals(4));
      });
    });

    group('Game Over Scenario', () {
      test('wall can be destroyed by sufficient damage', () {
        final totalHP = viewModel.maxHP;

        viewModel.takeDamage(totalHP);

        expect(viewModel.isDestroyed, isTrue);
        expect(viewModel.currentHP, equals(0));
        expect(viewModel.healthPercentage, equals(0.0));
      });

      test('destroyed wall can be reset', () {
        viewModel.takeDamage(viewModel.maxHP);
        expect(viewModel.isDestroyed, isTrue);

        viewModel.reset();

        expect(viewModel.isDestroyed, isFalse);
        expect(viewModel.currentHP, greaterThan(0));
      });
    });
  });
}
