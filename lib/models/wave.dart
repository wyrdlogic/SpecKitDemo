/// Wave model representing timed game sessions
class Wave {
  Wave({
    this.duration = 60,
    double? remainingTime,
    this.level = 1,
    this.isActive = false,
    double? enemySpawnRate,
    this.enemiesSpawned = 0,
    DateTime? startTime,
  }) : _remainingTime = remainingTime ?? duration.toDouble(),
       _enemySpawnRate = enemySpawnRate ?? _calculateSpawnRate(level),
       _startTime = startTime {
    _validateState();
  }

  final int duration; // Wave length in seconds
  final int level; // Current difficulty level
  final bool isActive; // Wave running state
  final int enemiesSpawned; // Count for current wave
  final DateTime? _startTime;

  double _remainingTime; // Countdown timer (internal: fractional seconds)
  double _enemySpawnRate; // Enemies per second

  /// Countdown timer in seconds (floored for display)
  int get remainingTime => _remainingTime.floor();

  /// Enemies per second spawn rate
  double get enemySpawnRate => _enemySpawnRate;

  /// When the wave started (if active)
  DateTime? get startTime => _startTime;

  /// Progress through the wave (0.0 to 1.0)
  double get progress {
    if (duration <= 0) return 1.0;
    return (duration - _remainingTime) / duration;
  }

  /// Whether the wave is completed
  bool get isComplete => _remainingTime <= 0;

  /// Time elapsed since wave started (in seconds, floored)
  int get timeElapsed => (duration - _remainingTime).floor();

  /// Calculate base spawn rate for a given level
  static double _calculateSpawnRate(int level) {
    // Spawn rate increases with level: 0.5, 0.75, 1.0, 1.25...
    return 0.5 + (level - 1) * 0.25;
  }

  /// Update the wave timer with frame-based timing (60 FPS)
  Wave updateTimer(double deltaTime) {
    if (!isActive || _remainingTime <= 0) {
      return this;
    }

    final newRemainingTime = (_remainingTime - deltaTime).clamp(
      0.0,
      duration.toDouble(),
    );

    return Wave(
      duration: duration,
      remainingTime: newRemainingTime,
      level: level,
      isActive: isActive,
      enemySpawnRate: _enemySpawnRate,
      enemiesSpawned: enemiesSpawned,
      startTime: _startTime,
    );
  }

  /// Start a new wave with the given level
  Wave startWave(int newLevel) {
    if (newLevel < 1) {
      throw ArgumentError('Wave level must be at least 1: $newLevel');
    }

    return Wave(
      duration: duration,
      remainingTime: duration.toDouble(),
      level: newLevel,
      isActive: true,
      enemySpawnRate: _calculateSpawnRate(newLevel),
      enemiesSpawned: 0,
      startTime: DateTime.now(),
    );
  }

  /// End the current wave
  Wave endWave() {
    return Wave(
      duration: duration,
      remainingTime: 0,
      level: level,
      isActive: false,
      enemySpawnRate: _enemySpawnRate,
      enemiesSpawned: enemiesSpawned,
      startTime: _startTime,
    );
  }

  /// Record that an enemy was spawned
  Wave spawnEnemy() {
    return Wave(
      duration: duration,
      remainingTime: _remainingTime,
      level: level,
      isActive: isActive,
      enemySpawnRate: _enemySpawnRate,
      enemiesSpawned: enemiesSpawned + 1,
      startTime: _startTime,
    );
  }

  /// Calculate total enemies that should be spawned by now
  int getExpectedEnemyCount() {
    if (!isActive || timeElapsed <= 0) return 0;
    return (timeElapsed * _enemySpawnRate).floor();
  }

  /// Whether a new enemy should be spawned
  bool shouldSpawnEnemy() {
    return isActive && enemiesSpawned < getExpectedEnemyCount();
  }

  /// Get the next wave configuration
  Wave nextWave() {
    return Wave(
      duration: duration,
      level: level + 1,
      isActive: false,
      enemiesSpawned: 0,
    );
  }

  /// Validate wave state
  void _validateState() {
    if (duration <= 0) {
      throw StateError('Duration must be positive: $duration');
    }
    if (_remainingTime < 0) {
      throw StateError('Remaining time cannot be negative: $_remainingTime');
    }
    if (_remainingTime > duration) {
      throw StateError(
        'Remaining time cannot exceed duration: $_remainingTime > $duration',
      );
    }
    if (level < 1) {
      throw StateError('Level must be at least 1: $level');
    }
    if (_enemySpawnRate < 0) {
      throw StateError('Enemy spawn rate cannot be negative: $_enemySpawnRate');
    }
    if (enemiesSpawned < 0) {
      throw StateError('Enemies spawned cannot be negative: $enemiesSpawned');
    }
  }

  /// Create a copy with updated values
  Wave copyWith({
    int? duration,
    double? remainingTime,
    int? level,
    bool? isActive,
    double? enemySpawnRate,
    int? enemiesSpawned,
    DateTime? startTime,
  }) {
    return Wave(
      duration: duration ?? this.duration,
      remainingTime: remainingTime ?? _remainingTime,
      level: level ?? this.level,
      isActive: isActive ?? this.isActive,
      enemySpawnRate: enemySpawnRate ?? _enemySpawnRate,
      enemiesSpawned: enemiesSpawned ?? this.enemiesSpawned,
      startTime: startTime ?? _startTime,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Wave &&
        other.duration == duration &&
        other._remainingTime == _remainingTime &&
        other.level == level &&
        other.isActive == isActive &&
        other._enemySpawnRate == _enemySpawnRate &&
        other.enemiesSpawned == enemiesSpawned &&
        other._startTime == _startTime;
  }

  @override
  int get hashCode {
    return Object.hash(
      duration,
      _remainingTime,
      level,
      isActive,
      _enemySpawnRate,
      enemiesSpawned,
      _startTime,
    );
  }

  @override
  String toString() {
    return 'Wave(level: $level, remaining: ${_remainingTime}s, active: $isActive, spawned: $enemiesSpawned)';
  }
}
