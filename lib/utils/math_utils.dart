import 'dart:math' as math;

/// Mathematical utility functions for game calculations
class MathUtils {
  // Private constructor to prevent instantiation
  MathUtils._();

  /// Calculate distance between two points
  static double distance(double x1, double y1, double x2, double y2) {
    final dx = x2 - x1;
    final dy = y2 - y1;
    return math.sqrt(dx * dx + dy * dy);
  }

  /// Calculate squared distance (faster when exact distance not needed)
  static double distanceSquared(double x1, double y1, double x2, double y2) {
    final dx = x2 - x1;
    final dy = y2 - y1;
    return dx * dx + dy * dy;
  }

  /// Calculate angle between two points in radians
  static double angleToTarget(
    double fromX,
    double fromY,
    double toX,
    double toY,
  ) {
    return math.atan2(toY - fromY, toX - fromX);
  }

  /// Convert radians to degrees
  static double radiansToDegrees(double radians) {
    return radians * (180.0 / math.pi);
  }

  /// Convert degrees to radians
  static double degreesToRadians(double degrees) {
    return degrees * (math.pi / 180.0);
  }

  /// Normalize angle to range [0, 2π]
  static double normalizeAngle(double angle) {
    while (angle < 0) {
      angle += 2 * math.pi;
    }
    while (angle >= 2 * math.pi) {
      angle -= 2 * math.pi;
    }
    return angle;
  }

  /// Linear interpolation between two values
  static double lerp(double a, double b, double t) {
    return a + (b - a) * t.clamp(0.0, 1.0);
  }

  /// Inverse linear interpolation (find t given a, b, and result)
  static double inverseLerp(double a, double b, double value) {
    if ((b - a).abs() < 0.0001) return 0.0;
    return ((value - a) / (b - a)).clamp(0.0, 1.0);
  }

  /// Smooth step interpolation (eased curve)
  static double smoothStep(double a, double b, double t) {
    final clampedT = t.clamp(0.0, 1.0);
    final smoothT = clampedT * clampedT * (3.0 - 2.0 * clampedT);
    return lerp(a, b, smoothT);
  }

  /// Move value towards target at specified speed
  static double moveTowards(double current, double target, double maxDelta) {
    if ((target - current).abs() <= maxDelta) {
      return target;
    }
    final sign = (target - current) > 0 ? 1.0 : -1.0;
    return current + sign * maxDelta;
  }

  /// Calculate exponential growth: base * (1 + rate)^level
  static double exponentialGrowth(double base, double rate, int level) {
    return base * math.pow(1 + rate, level);
  }

  /// Calculate linear growth: base + (rate * level)
  static double linearGrowth(double base, double rate, int level) {
    return base + (rate * level);
  }

  /// Clamp value between min and max
  static double clamp(double value, double min, double max) {
    return math.max(min, math.min(max, value));
  }

  /// Wrap value around range [min, max)
  static double wrap(double value, double min, double max) {
    final range = max - min;
    if (range <= 0) return min;

    while (value >= max) {
      value -= range;
    }
    while (value < min) {
      value += range;
    }

    return value;
  }

  /// Check if value is approximately equal within tolerance
  static bool approximately(double a, double b, {double tolerance = 0.0001}) {
    return (a - b).abs() < tolerance;
  }

  /// Calculate percentage of value in range [min, max]
  static double getPercentage(double value, double min, double max) {
    if ((max - min).abs() < 0.0001) return 0.0;
    return ((value - min) / (max - min)).clamp(0.0, 1.0);
  }

  /// Get random double between min and max
  static double randomRange(double min, double max) {
    return min + math.Random().nextDouble() * (max - min);
  }

  /// Get random integer between min and max (inclusive)
  static int randomInt(int min, int max) {
    return min + math.Random().nextInt(max - min + 1);
  }

  /// Get random boolean with specified probability (0.0 to 1.0)
  static bool randomBool({double probability = 0.5}) {
    return math.Random().nextDouble() < probability;
  }

  /// Calculate 2D vector magnitude
  static double vectorMagnitude(double x, double y) {
    return math.sqrt(x * x + y * y);
  }

  /// Normalize 2D vector to unit length
  static ({double x, double y}) normalizeVector(double x, double y) {
    final magnitude = vectorMagnitude(x, y);
    if (magnitude == 0) return (x: 0.0, y: 0.0);
    return (x: x / magnitude, y: y / magnitude);
  }

  /// Calculate dot product of two 2D vectors
  static double dotProduct(double x1, double y1, double x2, double y2) {
    return x1 * x2 + y1 * y2;
  }

  /// Calculate cross product of two 2D vectors (returns scalar)
  static double crossProduct(double x1, double y1, double x2, double y2) {
    return x1 * y2 - y1 * x2;
  }

  /// Rotate point around origin by angle (radians)
  static ({double x, double y}) rotatePoint(double x, double y, double angle) {
    final cos = math.cos(angle);
    final sin = math.sin(angle);
    return (x: x * cos - y * sin, y: x * sin + y * cos);
  }

  /// Calculate circle area
  static double circleArea(double radius) {
    return math.pi * radius * radius;
  }

  /// Calculate circle circumference
  static double circleCircumference(double radius) {
    return 2 * math.pi * radius;
  }

  /// Check if point is inside circle
  static bool pointInCircle(
    double px,
    double py,
    double cx,
    double cy,
    double radius,
  ) {
    return distanceSquared(px, py, cx, cy) <= radius * radius;
  }

  /// Check if two circles intersect
  static bool circlesIntersect(
    double x1,
    double y1,
    double r1,
    double x2,
    double y2,
    double r2,
  ) {
    final centerDistance = distance(x1, y1, x2, y2);
    return centerDistance <= (r1 + r2);
  }
}
