import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

/// Base class for all game components with common functionality
///
/// Provides standardized behavior for:
/// - Lifecycle management
/// - Debug rendering
/// - Performance monitoring
/// - Position and size management
abstract base class BaseGameComponent extends RectangleComponent
    with TapCallbacks, HasGameRef {
  BaseGameComponent({
    super.position,
    super.size,
    super.scale,
    super.angle,
    super.anchor,
    super.children,
    super.priority,
    this.debugColor,
    this.debugLabel,
  });

  /// Color for debug rendering (null = no debug rendering)
  @override
  final Color? debugColor;

  /// Label for debug information
  final String? debugLabel;

  bool _isInitialized = false;
  bool _isDestroyed = false;

  /// Whether the component has been initialized
  bool get isInitialized => _isInitialized;

  /// Whether the component has been destroyed
  bool get isDestroyed => _isDestroyed;

  @override
  @mustCallSuper
  Future<void> onLoad() async {
    await super.onLoad();
    await initialize();
    _isInitialized = true;
  }

  /// Initialize component-specific resources (override in subclasses)
  @protected
  Future<void> initialize() async {
    // Override in subclasses
  }

  @override
  @mustCallSuper
  void onRemove() {
    destroy();
    super.onRemove();
  }

  /// Clean up resources when component is destroyed
  @protected
  @mustCallSuper
  void destroy() {
    if (_isDestroyed) return;
    _isDestroyed = true;
  }

  @override
  @mustCallSuper
  void update(double dt) {
    if (_isDestroyed) return;

    super.update(dt);
    updateLogic(dt);
  }

  /// Component-specific update logic (override in subclasses)
  @protected
  void updateLogic(double dt) {
    // Override in subclasses
  }

  @override
  @mustCallSuper
  void render(Canvas canvas) {
    super.render(canvas);

    // Debug rendering
    if (debugColor != null) {
      renderDebugInfo(canvas);
    }
  }

  /// Render debug information
  @protected
  void renderDebugInfo(Canvas canvas) {
    if (debugColor == null) return;

    // Draw debug border
    final paint = Paint()
      ..color = debugColor!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawRect(size.toRect(), paint);

    // Draw debug label
    if (debugLabel != null) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: debugLabel,
          style: TextStyle(
            color: debugColor!,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(canvas, const Offset(2, 2));
    }
  }

  /// Safe position setter with bounds checking
  void setPositionSafe(Vector2 newPosition) {
    if (!_isDestroyed) {
      position = newPosition;
    }
  }

  /// Safe size setter with validation
  void setSizeSafe(Vector2 newSize) {
    if (!_isDestroyed && newSize.x > 0 && newSize.y > 0) {
      size = newSize;
    }
  }

  /// Check if point is within component bounds
  bool containsPoint(Vector2 point) {
    return toRect().contains(point.toOffset());
  }

  /// Get component bounds as rectangle
  Rect toRect() {
    return Rect.fromLTWH(position.x, position.y, size.x, size.y);
  }

  /// Animate to a new position
  Future<void> animateToPosition(
    Vector2 targetPosition,
    double duration, {
    Curve curve = Curves.easeInOut,
  }) async {
    if (_isDestroyed) return;

    await game.add(
      TimerComponent(
        period: duration,
        onTick: () {
          if (!_isDestroyed) {
            position = targetPosition;
          }
        },
      ),
    );
  }

  /// Flash effect for visual feedback
  void flash(Color color, double duration) {
    if (_isDestroyed) return;

    // Simple flash implementation - could be enhanced with actual color overlay
    final originalScale = scale;

    scale = originalScale * 1.1;

    game.add(
      TimerComponent(
        period: duration,
        onTick: () {
          if (!_isDestroyed) {
            scale = originalScale;
          }
        },
      ),
    );
  }

  /// Get distance to another component
  double distanceTo(BaseGameComponent other) {
    if (_isDestroyed || other._isDestroyed) return double.infinity;
    return position.distanceTo(other.position);
  }

  /// Check collision with another component
  bool collidesWith(BaseGameComponent other) {
    if (_isDestroyed || other._isDestroyed) return false;
    return toRect().overlaps(other.toRect());
  }

  @override
  String toString() {
    return '$runtimeType(pos: $position, size: $size, destroyed: $_isDestroyed)';
  }
}
