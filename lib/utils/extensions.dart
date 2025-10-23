import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Extension methods for common operations
///
/// Provides utility methods to reduce boilerplate and improve code readability
/// following Flutter and Dart best practices.

// ============================================================================
// CONTEXT EXTENSIONS
// ============================================================================

extension BuildContextExtensions on BuildContext {
  /// Get theme data shortcut
  ThemeData get theme => Theme.of(this);

  /// Get color scheme shortcut
  ColorScheme get colorScheme => theme.colorScheme;

  /// Get text theme shortcut
  TextTheme get textTheme => theme.textTheme;

  /// Get media query shortcut
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Get screen size shortcut
  Size get screenSize => mediaQuery.size;

  /// Get screen width shortcut
  double get screenWidth => screenSize.width;

  /// Get screen height shortcut
  double get screenHeight => screenSize.height;

  /// Check if device is mobile (width < 600)
  bool get isMobile => screenWidth < 600;

  /// Check if device is tablet (width between 600-1200)
  bool get isTablet => screenWidth >= 600 && screenWidth < 1200;

  /// Check if device is desktop (width >= 1200)
  bool get isDesktop => screenWidth >= 1200;

  /// Show snack bar with message
  void showSnackBar(String message, {Color? backgroundColor}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
    );
  }

  /// Show error snack bar
  void showErrorSnackBar(String message) {
    showSnackBar(message, backgroundColor: colorScheme.error);
  }

  /// Show success snack bar
  void showSuccessSnackBar(String message) {
    showSnackBar(message, backgroundColor: Colors.green);
  }
}

// ============================================================================
// NUMBER EXTENSIONS
// ============================================================================

extension IntExtensions on int {
  /// Convert to formatted string with thousand separators
  String get formatted {
    final str = toString();
    if (str.length <= 3) return str;

    String result = '';
    int count = 0;

    for (int i = str.length - 1; i >= 0; i--) {
      if (count == 3) {
        result = ',$result';
        count = 0;
      }
      result = str[i] + result;
      count++;
    }

    return result;
  }

  /// Convert to abbreviated string (1K, 1M, etc.)
  String get abbreviated {
    if (this < 1000) return toString();
    if (this < 1000000)
      return '${(this / 1000).toStringAsFixed(1).replaceAll('.0', '')}K';
    if (this < 1000000000)
      return '${(this / 1000000).toStringAsFixed(1).replaceAll('.0', '')}M';
    return '${(this / 1000000000).toStringAsFixed(1).replaceAll('.0', '')}B';
  }

  /// Clamp between min and max values
  int clampTo(int min, int max) => clamp(min, max).toInt();
}

extension DoubleExtensions on double {
  /// Convert to formatted string with specific decimal places
  String toFixedString(int decimals) =>
      toStringAsFixed(decimals).replaceAll(RegExp(r'\.?0+$'), '');

  /// Clamp between min and max values
  double clampTo(double min, double max) => clamp(min, max).toDouble();

  /// Check if value is approximately equal (within tolerance)
  bool isApproximately(double other, {double tolerance = 0.001}) {
    return (this - other).abs() < tolerance;
  }
}

// ============================================================================
// STRING EXTENSIONS
// ============================================================================

extension StringExtensions on String {
  /// Capitalize first letter
  String get capitalized {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  /// Convert to title case
  String get titleCase {
    return split(' ').map((word) => word.capitalized).join(' ');
  }

  /// Check if string is null or empty
  bool get isNullOrEmpty => isEmpty;

  /// Check if string is not null and not empty
  bool get isNotNullOrEmpty => isNotEmpty;

  /// Truncate string to max length with ellipsis
  String truncate(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;
    return substring(0, maxLength - ellipsis.length) + ellipsis;
  }
}

// ============================================================================
// LIST EXTENSIONS
// ============================================================================

extension ListExtensions<T> on List<T> {
  /// Get element at index or null if out of bounds
  T? getOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }

  /// Get random element from list
  T? get randomOrNull {
    if (isEmpty) return null;
    return this[(DateTime.now().millisecondsSinceEpoch % length)];
  }

  /// Add element if condition is true
  void addIf(bool condition, T element) {
    if (condition) add(element);
  }

  /// Add all elements if condition is true
  void addAllIf(bool condition, Iterable<T> elements) {
    if (condition) addAll(elements);
  }
}

// ============================================================================
// COLOR EXTENSIONS
// ============================================================================

extension ColorExtensions on Color {
  /// Convert to hex string
  String get hexString {
    return '#${value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

  /// Create color with opacity
  Color withOpacityValue(double opacity) =>
      withOpacity(opacity.clamp(0.0, 1.0));

  /// Lighten color by percentage
  Color lighten([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1, 'Amount should be between 0 and 1');
    final hsl = HSLColor.fromColor(this);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  /// Darken color by percentage
  Color darken([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1, 'Amount should be between 0 and 1');
    final hsl = HSLColor.fromColor(this);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
}

// ============================================================================
// DATETIME EXTENSIONS
// ============================================================================

extension DateTimeExtensions on DateTime {
  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Get time ago string
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${difference.inDays ~/ 7}w ago';
    }
  }
}

// ============================================================================
// GAME-SPECIFIC EXTENSIONS
// ============================================================================

extension Vector2Extensions on ui.Offset {
  /// Calculate distance to another point
  double distanceTo(ui.Offset other) {
    final dx = this.dx - other.dx;
    final dy = this.dy - other.dy;
    return math.sqrt(dx * dx + dy * dy);
  }

  /// Calculate squared distance (faster when you don't need exact distance)
  double distanceSquaredTo(ui.Offset other) {
    final dx = this.dx - other.dx;
    final dy = this.dy - other.dy;
    return dx * dx + dy * dy;
  }

  /// Normalize vector to unit length
  ui.Offset get normalized {
    final magnitude = distance;
    if (magnitude == 0) return ui.Offset.zero;
    return ui.Offset(dx / magnitude, dy / magnitude);
  }

  /// Get magnitude/length of vector
  double get magnitude => distance;
}

extension SizeExtensions on Size {
  /// Get center point of size
  ui.Offset get center => ui.Offset(width / 2, height / 2);

  /// Check if point is within bounds
  bool contains(ui.Offset point) {
    return point.dx >= 0 &&
        point.dx <= width &&
        point.dy >= 0 &&
        point.dy <= height;
  }

  /// Get aspect ratio
  double get aspectRatio => width / height;
}
