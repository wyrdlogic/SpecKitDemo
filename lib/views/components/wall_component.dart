import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:tower_defense_game/views/components/base_game_component.dart';
import 'package:tower_defense_game/viewmodels/wall_viewmodel.dart';

/// Flame component for rendering the defensive wall
final class WallComponent extends BaseGameComponent {
  WallComponent({
    required this.viewModel,
    super.position,
    super.size,
    super.priority = 10,
  }) : super(
         debugColor: Colors.yellow.withAlpha((0.3 * 255).round()),
         debugLabel: 'Wall',
       );

  final WallViewModel viewModel;

  // Visual properties
  static const double wallWidth = 80.0;
  static const double wallHeight = 120.0;
  static const double borderWidth = 3.0;

  // Damage flash animation
  double _damageFlashTimer = 0.0;
  static const double _damageFlashDuration = 0.2; // 200ms flash
  int _lastKnownHP = 0;

  @override
  Future<void> initialize() async {
    // Set size based on wall dimensions
    size = Vector2(wallWidth, wallHeight);

    // Center anchor
    anchor = Anchor.center;

    // Initialize last known HP
    _lastKnownHP = viewModel.currentHP;

    // Listen to wall ViewModel changes
    viewModel.addListener(_onWallChanged);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update position from ViewModel if needed
    final wallPos = viewModel.position;
    position = Vector2(wallPos.dx, wallPos.dy);

    // Update damage flash timer
    if (_damageFlashTimer > 0) {
      _damageFlashTimer -= dt;
    }

    // Check if wall took damage and trigger flash
    if (viewModel.currentHP < _lastKnownHP) {
      _damageFlashTimer = _damageFlashDuration;
    }
    _lastKnownHP = viewModel.currentHP;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (viewModel.isDestroyed) {
      _renderDestroyedWall(canvas);
    } else {
      _renderActiveWall(canvas);
    }

    _renderHealthBar(canvas);
    _renderLevel(canvas);
  }

  void _renderActiveWall(Canvas canvas) {
    // Draw wall body with level-based color
    final baseColor = viewModel.color;

    // Flash red when damaged
    final wallColor = _damageFlashTimer > 0
        ? Color.lerp(baseColor, Colors.red, 0.7)!
        : baseColor;

    final wallPaint = Paint()
      ..color = wallColor
      ..style = PaintingStyle.fill;

    final wallRect = size.toRect();
    canvas.drawRect(wallRect, wallPaint);

    // Draw border (thicker and red during flash)
    final borderColor = _damageFlashTimer > 0 ? Colors.red : Colors.black;
    final borderThickness = _damageFlashTimer > 0
        ? borderWidth + 2
        : borderWidth;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderThickness;

    canvas.drawRect(wallRect, borderPaint);

    // Draw damage cracks if health is low
    if (viewModel.healthPercentage < 0.5) {
      _renderDamageCracks(canvas);
    }

    // Draw additional damage effects if health is critical
    if (viewModel.healthPercentage < 0.25) {
      _renderCriticalDamageEffects(canvas);
    }
  }

  void _renderDestroyedWall(Canvas canvas) {
    // Draw destroyed wall as rubble
    final rubblePaint = Paint()
      ..color = Colors.grey.shade800
      ..style = PaintingStyle.fill;

    final wallRect = size.toRect();
    canvas.drawRect(wallRect, rubblePaint);

    // Draw X pattern to indicate destruction
    final xPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    canvas.drawLine(wallRect.topLeft, wallRect.bottomRight, xPaint);
    canvas.drawLine(wallRect.topRight, wallRect.bottomLeft, xPaint);
  }

  void _renderHealthBar(Canvas canvas) {
    const barWidth = wallWidth - 10;
    const barHeight = 8.0;
    const barOffsetY = wallHeight + 10;

    // Background (empty health)
    final bgPaint = Paint()
      ..color = Colors.red.shade900
      ..style = PaintingStyle.fill;

    final bgRect = Rect.fromLTWH(
      (wallWidth - barWidth) / 2,
      barOffsetY,
      barWidth,
      barHeight,
    );
    canvas.drawRect(bgRect, bgPaint);

    // Foreground (current health)
    final healthPercentage = viewModel.healthPercentage.clamp(0.0, 1.0);
    final fgPaint = Paint()
      ..color = _getHealthBarColor(healthPercentage)
      ..style = PaintingStyle.fill;

    final fgRect = Rect.fromLTWH(
      (wallWidth - barWidth) / 2,
      barOffsetY,
      barWidth * healthPercentage,
      barHeight,
    );
    canvas.drawRect(fgRect, fgPaint);

    // Border
    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawRect(bgRect, borderPaint);
  }

  Color _getHealthBarColor(double healthPercentage) {
    if (healthPercentage > 0.6) {
      return Colors.green;
    } else if (healthPercentage > 0.3) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  void _renderLevel(Canvas canvas) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Lv${viewModel.level}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.black),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    // Draw level text at top of wall
    textPainter.paint(
      canvas,
      Offset((wallWidth - textPainter.width) / 2, -textPainter.height - 5),
    );
  }

  void _renderDamageCracks(Canvas canvas) {
    final crackPaint = Paint()
      ..color = Colors.black.withAlpha((0.4 * 255).round())
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw some random-looking cracks
    canvas.drawLine(const Offset(20, 10), const Offset(35, 40), crackPaint);
    canvas.drawLine(const Offset(60, 20), const Offset(70, 50), crackPaint);
    canvas.drawLine(const Offset(15, 60), const Offset(30, 90), crackPaint);
  }

  void _renderCriticalDamageEffects(Canvas canvas) {
    // Add more severe cracks and damage indicators
    final severeCrackPaint = Paint()
      ..color = Colors.red.shade900.withAlpha((0.6 * 255).round())
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    // Additional severe damage cracks
    canvas.drawLine(
      const Offset(40, 15),
      const Offset(50, 80),
      severeCrackPaint,
    );
    canvas.drawLine(
      const Offset(25, 50),
      const Offset(60, 45),
      severeCrackPaint,
    );
    canvas.drawLine(
      const Offset(50, 70),
      const Offset(40, 110),
      severeCrackPaint,
    );

    // Add damage vignette effect
    final vignettePaint = Paint()
      ..color = Colors.red.withAlpha((0.15 * 255).round())
      ..style = PaintingStyle.fill;

    canvas.drawRect(size.toRect(), vignettePaint);
  }

  void _onWallChanged() {
    // Force re-render when wall state changes
    // Component will automatically re-render on next frame
  }

  @override
  void destroy() {
    viewModel.removeListener(_onWallChanged);
    super.destroy();
  }
}
