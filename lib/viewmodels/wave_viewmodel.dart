import '../models/wave.dart';
import 'base_viewmodel.dart';

/// ViewModel for managing wave state and progression
final class WaveViewModel extends BaseViewModel {
  WaveViewModel() : _currentWave = Wave();

  Wave _currentWave;

  /// Get the current wave
  Wave get currentWave => _currentWave;

  /// Get the current level
  int get currentLevel => _currentWave.level;

  /// Check if a wave is currently active
  bool get isWaveActive => _currentWave.isActive;

  /// Get time remaining in current wave (seconds)
  int get timeRemaining => _currentWave.remainingTime;

  /// Get wave progress (0.0 to 1.0)
  double get progress => _currentWave.progress;

  /// Check if wave is complete
  bool get isWaveComplete => _currentWave.isComplete;

  /// Get current wave spawn rate
  double get spawnRate => _currentWave.enemySpawnRate;

  /// Get enemies spawned in current wave
  int get enemiesSpawned => _currentWave.enemiesSpawned;

  /// Start a new wave
  void startWave({int? level}) {
    if (isWaveActive) return; // Can't start if already active

    final waveLevel = level ?? _currentWave.level;
    _currentWave = _currentWave.startWave(waveLevel);
    notifyListeners();
  }

  /// Update wave timer (called each frame with delta time)
  void updateWave(double deltaTime) {
    if (!isWaveActive) return;

    // Update timer each second
    _currentWave.updateTimer();
    notifyListeners();
  }

  /// Complete the current wave
  void completeWave() {
    if (!isWaveActive) return;

    _currentWave = _currentWave.endWave();
    notifyListeners();
  }

  /// Advance to the next level
  void advanceLevel() {
    _currentWave = _currentWave.nextWave();
    notifyListeners();
  }

  /// Increment enemy spawn count for current wave
  void incrementEnemySpawnCount() {
    if (!isWaveActive) return;

    _currentWave = _currentWave.spawnEnemy();
    notifyListeners();
  }

  /// Check if we should spawn a new enemy
  bool shouldSpawnEnemy() {
    return _currentWave.shouldSpawnEnemy();
  }

  /// Get expected enemy count at this point in the wave
  int getExpectedEnemyCount() {
    return _currentWave.getExpectedEnemyCount();
  }

  /// Reset wave state to level 1
  @override
  void reset() {
    super.reset();
    _currentWave = Wave();
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
