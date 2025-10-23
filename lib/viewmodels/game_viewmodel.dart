import 'base_viewmodel.dart';
import 'wall_viewmodel.dart';
import 'resource_viewmodel.dart';
import 'enemy_viewmodel.dart';
import 'wave_viewmodel.dart';
import '../models/game_enums.dart';

/// ViewModel coordinating all game systems
final class GameViewModel extends BaseViewModel {
  GameViewModel({
    required this.wallViewModel,
    required this.resourceViewModel,
    required this.enemyViewModel,
    required this.waveViewModel,
  }) {
    // Listen to child ViewModels
    wallViewModel.addListener(_onChildViewModelChanged);
    resourceViewModel.addListener(_onChildViewModelChanged);
    enemyViewModel.addListener(_onChildViewModelChanged);
    waveViewModel.addListener(_onChildViewModelChanged);
  }

  final WallViewModel wallViewModel;
  final ResourceViewModel resourceViewModel;
  final EnemyViewModel enemyViewModel;
  final WaveViewModel waveViewModel;

  bool _isGameActive = false;
  bool _isPaused = false;
  int _totalEnemiesDefeated = 0;
  double _totalPlayTime = 0.0;

  /// Whether the game is currently active
  bool get isGameActive => _isGameActive;

  /// Whether the game is paused
  bool get isPaused => _isPaused;

  /// Total enemies defeated across all waves
  int get totalEnemiesDefeated => _totalEnemiesDefeated;

  /// Total play time in seconds
  double get totalPlayTime => _totalPlayTime;

  /// Current game level
  int get currentLevel => waveViewModel.currentLevel;

  /// Whether the game is over (wall destroyed)
  bool get isGameOver => wallViewModel.isDestroyed;

  /// Start a new game
  void startGame() {
    if (_isGameActive) return;

    // Reset all systems
    wallViewModel.reset();
    _stopAllResourceGeneration();
    enemyViewModel.clearAll();
    waveViewModel.reset();

    // Reset game state
    _isGameActive = true;
    _isPaused = false;
    _totalEnemiesDefeated = 0;
    _totalPlayTime = 0.0;

    // Start resource generation for all types
    _startAllResourceGeneration();

    // Start first wave
    waveViewModel.startWave(level: 1);

    notifyListeners();
  }

  /// Pause the game
  void pauseGame() {
    if (!_isGameActive || _isPaused) return;

    _isPaused = true;
    _stopAllResourceGeneration();
    notifyListeners();
  }

  /// Resume the game
  void resumeGame() {
    if (!_isGameActive || !_isPaused) return;

    _isPaused = false;
    _startAllResourceGeneration();
    notifyListeners();
  }

  /// Update game state each frame
  void updateGame(double deltaTime) {
    if (!_isGameActive || _isPaused) return;

    // Update play time
    _totalPlayTime += deltaTime;

    // Update wave timer
    waveViewModel.updateWave(deltaTime);

    // Check if wave is complete
    if (waveViewModel.isWaveComplete && waveViewModel.isWaveActive) {
      _onWaveComplete();
    }

    // Check for game over
    if (wallViewModel.isDestroyed) {
      _onGameOver();
    }

    notifyListeners();
  }

  /// Handle wave completion
  void _onWaveComplete() {
    // End current wave
    waveViewModel.completeWave();

    // Advance to next level
    waveViewModel.advanceLevel();

    // Start next wave after a brief delay
    Future.delayed(const Duration(seconds: 3), () {
      if (_isGameActive && !_isPaused) {
        waveViewModel.startWave(level: currentLevel);
      }
    });
  }

  /// Handle game over
  void _onGameOver() {
    _isGameActive = false;
    _isPaused = false;
    _stopAllResourceGeneration();
    waveViewModel.completeWave();
    notifyListeners();
  }

  /// Increment defeated enemy count
  void incrementEnemiesDefeated() {
    _totalEnemiesDefeated++;
    notifyListeners();
  }

  /// Start generation for all resource types
  void _startAllResourceGeneration() {
    for (final type in ResourceType.values) {
      resourceViewModel.startGeneration(type);
    }
  }

  /// Stop generation for all resource types
  void _stopAllResourceGeneration() {
    for (final type in ResourceType.values) {
      resourceViewModel.stopGeneration(type);
    }
  }

  /// Called when any child ViewModel changes
  void _onChildViewModelChanged() {
    // Propagate changes from child ViewModels
    notifyListeners();
  }

  @override
  void reset() {
    super.reset();
    _isGameActive = false;
    _isPaused = false;
    _totalEnemiesDefeated = 0;
    _totalPlayTime = 0.0;

    wallViewModel.reset();
    _stopAllResourceGeneration();
    enemyViewModel.clearAll();
    waveViewModel.reset();

    notifyListeners();
  }

  @override
  void dispose() {
    // Remove listeners from child ViewModels
    wallViewModel.removeListener(_onChildViewModelChanged);
    resourceViewModel.removeListener(_onChildViewModelChanged);
    enemyViewModel.removeListener(_onChildViewModelChanged);
    waveViewModel.removeListener(_onChildViewModelChanged);

    super.dispose();
  }
}
