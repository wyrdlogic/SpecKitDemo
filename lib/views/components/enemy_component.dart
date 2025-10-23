import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import '../../models/enemy.dart';
import '../../models/game_enums.dart';

/// Flame component that renders an enemy with health bar and visual feedback
class EnemyComponent extends PositionComponent {
  final Enemy enemy;

  late final Paint _enemyPaint;
  late final Paint _healthBarBackgroundPaint;
  late final Paint _healthBarFillPaint;

  static const double _enemySize = 30.0;
  static const double _healthBarWidth = 40.0;
  static const double _healthBarHeight = 4.0;
  static const double _healthBarOffset = 8.0;

  EnemyComponent({required this.enemy})
    : super(size: Vector2.all(_enemySize), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Set initial position from enemy model
    position = Vector2(enemy.position.dx, enemy.position.dy);

    // Initialize paints based on enemy type
    _enemyPaint = Paint()..color = _getEnemyColor();

    _healthBarBackgroundPaint = Paint()..color = const Color(0xFF333333);
    _healthBarFillPaint = Paint()..color = const Color(0xFFFF0000);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update position to match enemy model
    if (enemy.isAlive) {
      position = Vector2(enemy.position.dx, enemy.position.dy);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (!enemy.isAlive) {
      return;
    }

    // Draw enemy body
    _renderEnemyBody(canvas);

    // Draw health bar above enemy
    _renderHealthBar(canvas);
  }

  void _renderEnemyBody(Canvas canvas) {
    final rect = Rect.fromCenter(
      center: Offset(size.x / 2, size.y / 2),
      width: _enemySize,
      height: _enemySize,
    );

    // Draw different shapes based on enemy type
    switch (enemy.type) {
      case EnemyType.basic:
        canvas.drawCircle(
          Offset(size.x / 2, size.y / 2),
          _enemySize / 2,
          _enemyPaint,
        );
        break;
      case EnemyType.fast:
        // Draw triangle for fast enemies
        final path = Path()
          ..moveTo(size.x / 2, size.y / 2 - _enemySize / 2)
          ..lineTo(size.x / 2 + _enemySize / 2, size.y / 2 + _enemySize / 2)
          ..lineTo(size.x / 2 - _enemySize / 2, size.y / 2 + _enemySize / 2)
          ..close();
        canvas.drawPath(path, _enemyPaint);
        break;
      case EnemyType.strong:
        // Draw square for strong enemies
        canvas.drawRect(rect, _enemyPaint);
        break;
    }

    // Add border for better visibility
    final borderPaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    switch (enemy.type) {
      case EnemyType.basic:
        canvas.drawCircle(
          Offset(size.x / 2, size.y / 2),
          _enemySize / 2,
          borderPaint,
        );
        break;
      case EnemyType.fast:
        final path = Path()
          ..moveTo(size.x / 2, size.y / 2 - _enemySize / 2)
          ..lineTo(size.x / 2 + _enemySize / 2, size.y / 2 + _enemySize / 2)
          ..lineTo(size.x / 2 - _enemySize / 2, size.y / 2 + _enemySize / 2)
          ..close();
        canvas.drawPath(path, borderPaint);
        break;
      case EnemyType.strong:
        canvas.drawRect(rect, borderPaint);
        break;
    }
  }

  void _renderHealthBar(Canvas canvas) {
    final healthPercentage = enemy.hp / enemy.type.baseHp;

    // Health bar position (above enemy)
    final barX = size.x / 2 - _healthBarWidth / 2;
    final barY = -_healthBarOffset;

    // Background
    final backgroundRect = Rect.fromLTWH(
      barX,
      barY,
      _healthBarWidth,
      _healthBarHeight,
    );
    canvas.drawRect(backgroundRect, _healthBarBackgroundPaint);

    // Health fill
    final fillWidth = _healthBarWidth * healthPercentage;
    final fillRect = Rect.fromLTWH(barX, barY, fillWidth, _healthBarHeight);

    // Color code health bar
    final healthColor = _getHealthBarColor(healthPercentage);
    _healthBarFillPaint.color = healthColor;

    canvas.drawRect(fillRect, _healthBarFillPaint);

    // Health bar border
    final borderPaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRect(backgroundRect, borderPaint);
  }

  Color _getEnemyColor() {
    switch (enemy.type) {
      case EnemyType.basic:
        return const Color(0xFFFF6B6B); // Red
      case EnemyType.fast:
        return const Color(0xFFFFD93D); // Yellow
      case EnemyType.strong:
        return const Color(0xFF6BCF7F); // Green
    }
  }

  Color _getHealthBarColor(double healthPercentage) {
    if (healthPercentage > 0.6) {
      return const Color(0xFF4CAF50); // Green
    } else if (healthPercentage > 0.3) {
      return const Color(0xFFFF9800); // Orange
    } else {
      return const Color(0xFFF44336); // Red
    }
  }
}
