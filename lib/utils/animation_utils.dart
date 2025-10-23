import 'package:flutter/material.dart';

/// Animation utilities for smooth game effects
class AnimationUtils {
  // Private constructor to prevent instantiation
  AnimationUtils._();

  /// Standard animation durations in milliseconds
  static const int fastDuration = 150;
  static const int mediumDuration = 300;
  static const int slowDuration = 500;

  /// Standard curves for different animation types
  static const Curve bounceInCurve = Curves.bounceIn;
  static const Curve bounceOutCurve = Curves.bounceOut;
  static const Curve elasticInCurve = Curves.elasticIn;
  static const Curve elasticOutCurve = Curves.elasticOut;

  /// Shake animation parameters
  static ({double amplitude, int frequency, int duration}) getShakeParams({
    double intensity = 1.0,
  }) {
    return (
      amplitude: 5.0 * intensity,
      frequency: (15 * intensity).round(),
      duration: (300 * intensity).round(),
    );
  }

  /// Pulse animation parameters
  static ({double minScale, double maxScale, int duration}) getPulseParams({
    double intensity = 1.0,
  }) {
    return (
      minScale: 1.0 - (0.1 * intensity),
      maxScale: 1.0 + (0.2 * intensity),
      duration: (600 / intensity).round(),
    );
  }

  /// Flash animation parameters
  static ({Color color, double opacity, int duration}) getFlashParams({
    Color? flashColor,
    double intensity = 1.0,
  }) {
    return (
      color: flashColor ?? Colors.white,
      opacity: 0.8 * intensity,
      duration: (200 / intensity).round(),
    );
  }

  /// Fade in animation curve
  static Curve getFadeInCurve() => Curves.easeIn;

  /// Fade out animation curve
  static Curve getFadeOutCurve() => Curves.easeOut;

  /// Scale up animation curve
  static Curve getScaleUpCurve() => Curves.elasticOut;

  /// Scale down animation curve
  static Curve getScaleDownCurve() => Curves.easeInBack;

  /// Slide in animation curve
  static Curve getSlideInCurve() => Curves.easeOutCubic;

  /// Slide out animation curve
  static Curve getSlideOutCurve() => Curves.easeInCubic;

  /// Create a custom bounce curve
  static Curve createBounceCurve({double bounciness = 1.0}) {
    return Curves.bounceOut;
  }

  /// Create a custom elastic curve
  static Curve createElasticCurve({double period = 0.4}) {
    return Curves.elasticOut;
  }

  /// Interpolate between colors
  static Color lerpColor(Color start, Color end, double t) {
    return Color.lerp(start, end, t.clamp(0.0, 1.0)) ?? start;
  }

  /// Create gradient colors for health bars
  static List<Color> getHealthGradient(double healthPercentage) {
    if (healthPercentage > 0.6) {
      return [Colors.green.shade400, Colors.green.shade600];
    } else if (healthPercentage > 0.3) {
      return [Colors.orange.shade400, Colors.orange.shade600];
    } else {
      return [Colors.red.shade400, Colors.red.shade600];
    }
  }

  /// Create damage number colors based on damage type
  static Color getDamageColor(String damageType) {
    switch (damageType.toLowerCase()) {
      case 'critical':
        return Colors.red;
      case 'normal':
        return Colors.white;
      case 'heal':
        return Colors.green;
      case 'resource':
        return Colors.yellow;
      default:
        return Colors.white;
    }
  }

  /// Calculate eased value using custom easing function
  static double easeInOut(double t) {
    return t < 0.5 ? 2 * t * t : -1 + (4 - 2 * t) * t;
  }

  /// Calculate elastic ease out
  static double easeOutElastic(double t) {
    if (t == 0 || t == 1) return t;

    const p = 0.3;
    const s = p / 4;

    return (1 + (2 * t - 2) * (2 * t - 2) * ((s + 1) * (2 * t - 2) + s)).clamp(
      0.0,
      1.0,
    );
  }

  /// Calculate bounce ease out
  static double easeOutBounce(double t) {
    if (t < 1 / 2.75) {
      return 7.5625 * t * t;
    } else if (t < 2 / 2.75) {
      t -= 1.5 / 2.75;
      return 7.5625 * t * t + 0.75;
    } else if (t < 2.5 / 2.75) {
      t -= 2.25 / 2.75;
      return 7.5625 * t * t + 0.9375;
    } else {
      t -= 2.625 / 2.75;
      return 7.5625 * t * t + 0.984375;
    }
  }

  /// Create stagger delay for multiple animations
  static Duration getStaggerDelay(int index, {int baseDelayMs = 50}) {
    return Duration(milliseconds: baseDelayMs * index);
  }

  /// Create spring animation parameters
  static ({double stiffness, double damping}) getSpringParams({
    double responsiveness = 1.0,
  }) {
    return (stiffness: 100.0 * responsiveness, damping: 10.0 * responsiveness);
  }

  /// Create rotation animation parameters for spinning effects
  static ({double startAngle, double endAngle, int duration}) getSpinParams({
    double rotations = 1.0,
    bool clockwise = true,
  }) {
    final angle = 2 * 3.14159 * rotations * (clockwise ? 1 : -1);
    return (
      startAngle: 0.0,
      endAngle: angle,
      duration: (1000 * rotations).round(),
    );
  }

  /// Create floating animation parameters for UI elements
  static ({double amplitude, int duration}) getFloatParams({
    double intensity = 1.0,
  }) {
    return (amplitude: 10.0 * intensity, duration: (2000 / intensity).round());
  }

  /// Timing function for game object updates
  static bool shouldUpdate(int frameCount, int updateInterval) {
    return frameCount % updateInterval == 0;
  }

  /// Calculate animation progress with easing
  static double getEasedProgress(double elapsed, double duration, Curve curve) {
    if (duration <= 0) return 1.0;
    final t = (elapsed / duration).clamp(0.0, 1.0);
    return curve.transform(t);
  }
}
