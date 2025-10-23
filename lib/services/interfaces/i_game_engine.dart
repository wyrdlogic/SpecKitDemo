import '../../models/game_state.dart';

/// Interface for the core game engine managing the game loop
abstract interface class IGameEngine {
  /// Start the game engine
  void start();

  /// Stop the game engine
  void stop();

  /// Pause the game engine
  void pause();

  /// Resume the game engine
  void resume();

  /// Update the game state (called each frame)
  void update(double deltaTime);

  /// Get the current game state
  GameStateModel get gameState;

  /// Stream of game state updates
  Stream<GameStateModel> get gameStateStream;

  /// Whether the engine is currently running
  bool get isRunning;

  /// Whether the engine is paused
  bool get isPaused;

  /// Current frame rate (FPS)
  double get frameRate;

  /// Target frame rate
  double get targetFrameRate;

  /// Set target frame rate
  void setTargetFrameRate(double fps);
}
