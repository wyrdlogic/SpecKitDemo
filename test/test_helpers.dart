import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// TODO: Add mockito dependency to pubspec.yaml dev_dependencies when needed
// import 'package:mockito/mockito.dart';
// import 'package:mockito/annotations.dart';

// Mock classes will be generated here when needed
// Use @GenerateNiceMocks annotation for service interfaces

/// Test helper utilities for the tower defense game
class TestHelpers {
  /// Create a test-friendly setup for dependency injection
  static void setupTestDI() {
    // TODO: Setup mock services for testing
    // ServiceLocator.instance.clear();
    // ServiceLocator.instance.register<IGameEngine>(() => MockGameEngine());
  }

  /// Clean up after tests
  static void teardownTestDI() {
    // TODO: Clear service locator after tests
    // ServiceLocator.instance.clear();
  }

  /// Pump and settle with custom duration for animations
  static Future<void> pumpAndSettleWithDuration(
    WidgetTester tester, {
    Duration duration = const Duration(seconds: 1),
  }) async {
    await tester.pump(duration);
    await tester.pumpAndSettle();
  }

  /// Find a widget by its key and verify it exists
  static Widget requireWidgetByKey(WidgetTester tester, Key key) {
    final finder = find.byKey(key);
    expect(finder, findsOneWidget);
    return tester.widget(finder);
  }

  /// Verify a widget is not present
  static void verifyWidgetNotPresent(Key key) {
    final finder = find.byKey(key);
    expect(finder, findsNothing);
  }
}

/// Test data for different scenarios
class TestData {
  // Private constructor to prevent instantiation
  TestData._();

  /// Sample wall configuration for testing
  static const wallTestData = {
    'initialHP': 100,
    'maxHP': 100,
    'level': 1,
    'position': {'x': 400.0, 'y': 300.0},
  };

  /// Sample enemy configuration for testing
  static const enemyTestData = {
    'hp': 100,
    'damage': 25,
    'speed': 50.0,
    'position': {'x': 0.0, 'y': 300.0},
    'target': {'x': 400.0, 'y': 300.0},
  };

  /// Sample resource configuration for testing
  static const resourceTestData = {
    'blue': {'amount': 50, 'rate': 1.0},
    'green': {'amount': 25, 'rate': 0.5},
    'yellow': {'amount': 10, 'rate': 0.2},
  };

  /// Sample wave configuration for testing
  static const waveTestData = {
    'duration': 60,
    'level': 1,
    'spawnRate': 1.0,
    'enemiesSpawned': 0,
  };
}

/// Base test class for model unit tests
abstract class ModelTestBase {
  /// Setup method called before each test
  void setUp() {
    // Override in subclasses
  }

  /// Teardown method called after each test
  void tearDown() {
    // Override in subclasses
  }

  /// Helper to run common model validation tests
  void runValidationTests() {
    group('Validation Tests', () {
      test('should validate required fields', () {
        // Override in subclasses
      });

      test('should handle invalid input gracefully', () {
        // Override in subclasses
      });

      test('should maintain data integrity', () {
        // Override in subclasses
      });
    });
  }
}

/// Base test class for ViewModel unit tests
abstract class ViewModelTestBase {
  /// Setup method called before each test
  void setUp() {
    TestHelpers.setupTestDI();
  }

  /// Teardown method called after each test
  void tearDown() {
    TestHelpers.teardownTestDI();
  }

  /// Helper to run common ViewModel tests
  void runBaseViewModelTests() {
    group('Base ViewModel Tests', () {
      test('should initialize without errors', () {
        // Override in subclasses
      });

      test('should handle loading states correctly', () {
        // Override in subclasses
      });

      test('should handle errors gracefully', () {
        // Override in subclasses
      });

      test('should dispose resources properly', () {
        // Override in subclasses
      });
    });
  }
}

/// Base test class for service unit tests
abstract class ServiceTestBase {
  /// Setup method called before each test
  void setUp() {
    TestHelpers.setupTestDI();
  }

  /// Teardown method called after each test
  void tearDown() {
    TestHelpers.teardownTestDI();
  }

  /// Helper to run common service interface tests
  void runServiceInterfaceTests() {
    group('Service Interface Tests', () {
      test('should implement all required methods', () {
        // Override in subclasses
      });

      test('should handle edge cases properly', () {
        // Override in subclasses
      });

      test('should maintain consistent state', () {
        // Override in subclasses
      });
    });
  }
}

/// Custom matchers for game-specific testing
class GameMatchers {
  /// Matcher for checking if a position is within bounds
  static Matcher isWithinBounds(
    double minX,
    double minY,
    double maxX,
    double maxY,
  ) {
    return predicate<Map<String, double>>((position) {
      final x = position['x'] ?? 0.0;
      final y = position['y'] ?? 0.0;
      return x >= minX && x <= maxX && y >= minY && y <= maxY;
    }, 'position is within bounds');
  }

  /// Matcher for checking if a value is approximately equal
  static Matcher isApproximately(double expected, {double tolerance = 0.001}) {
    return predicate<double>((actual) {
      return (actual - expected).abs() < tolerance;
    }, 'is approximately $expected');
  }

  /// Matcher for checking if a percentage is valid (0.0 to 1.0)
  static Matcher isValidPercentage() {
    return predicate<double>((value) {
      return value >= 0.0 && value <= 1.0;
    }, 'is valid percentage (0.0 to 1.0)');
  }
}
