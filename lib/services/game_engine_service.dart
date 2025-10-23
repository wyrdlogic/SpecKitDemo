import 'dart:async';
import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/wall.dart';
import 'interfaces/i_game_engine.dart';

/// Core game engine service managing the game loop and state
final class GameEngineService implements IGameEngine {
  GameEngineService({GameStateModel? initialState, double targetFps = 60.0})
    : _gameState =
          initialState ??
          GameStateModel(
            wall: Wall(
              position: const Offset(400, 300),
            ), // Default wall at center
          ),
      _targetFrameRate = targetFps;

  GameStateModel _gameState;
  final _gameStateController = StreamController<GameStateModel>.broadcast();

  bool _isRunning = false;
  bool _isPaused = false;
  double _targetFrameRate;
  double _currentFrameRate = 0.0;

  Timer? _gameLoopTimer;
  DateTime? _lastUpdateTime;
  int _frameCount = 0;
  DateTime? _fpsCounterStart;

  @override
  void start() {
    if (_isRunning) return;

    _isRunning = true;
    _isPaused = false;
    _lastUpdateTime = DateTime.now();
    _fpsCounterStart = DateTime.now();
    _frameCount = 0;

    // Start game loop at target frame rate
    final frameDuration = Duration(
      microseconds: (1000000 / _targetFrameRate).round(),
    );

    _gameLoopTimer = Timer.periodic(frameDuration, (_) {
      if (!_isPaused) {
        final now = DateTime.now();
        final deltaTime = _lastUpdateTime != null
            ? now.difference(_lastUpdateTime!).inMicroseconds / 1000000.0
            : 0.0;

        update(deltaTime);
        _lastUpdateTime = now;

        // Update FPS counter
        _frameCount++;
        if (_fpsCounterStart != null) {
          final elapsed = now.difference(_fpsCounterStart!).inSeconds;
          if (elapsed >= 1) {
            _currentFrameRate = _frameCount / elapsed;
            _frameCount = 0;
            _fpsCounterStart = now;
          }
        }
      }
    });
  }

  @override
  void stop() {
    _isRunning = false;
    _isPaused = false;
    _gameLoopTimer?.cancel();
    _gameLoopTimer = null;
    _lastUpdateTime = null;
  }

  @override
  void pause() {
    if (!_isRunning) return;
    _isPaused = true;
  }

  @override
  void resume() {
    if (!_isRunning) return;
    _isPaused = false;
    _lastUpdateTime = DateTime.now(); // Reset to avoid large delta
  }

  @override
  void update(double deltaTime) {
    if (!_isRunning || _isPaused) return;

    // Update game state with delta time
    // Note: Actual game logic is handled by ViewModels,
    // this just broadcasts state changes
    _gameStateController.add(_gameState);
  }

  /// Update the game state (used by external systems)
  void updateGameState(GameStateModel newState) {
    _gameState = newState;
    _gameStateController.add(_gameState);
  }

  @override
  GameStateModel get gameState => _gameState;

  @override
  Stream<GameStateModel> get gameStateStream => _gameStateController.stream;

  @override
  bool get isRunning => _isRunning;

  @override
  bool get isPaused => _isPaused;

  @override
  double get frameRate => _currentFrameRate;

  @override
  double get targetFrameRate => _targetFrameRate;

  @override
  void setTargetFrameRate(double fps) {
    _targetFrameRate = fps;
    if (_isRunning) {
      // Restart with new frame rate
      stop();
      start();
    }
  }

  /// Dispose resources
  void dispose() {
    stop();
    _gameStateController.close();
  }
}
