import 'game_enums.dart';
import 'wall.dart';
import 'enemy.dart';
import 'resource.dart';
import 'wave.dart';

/// Root game state model coordinating all game entities
class GameStateModel {
  GameStateModel({
    GameState currentState = GameState.menu,
    required this.wall,
    Map<ResourceType, Resource>? resources,
    List<Enemy>? enemies,
    Wave? currentWave,
    int score = 0,
    DateTime? gameStartTime,
  }) : _currentState = currentState,
       _resources = resources ?? _createDefaultResources(),
       _enemies = enemies ?? <Enemy>[],
       _currentWave = currentWave ?? Wave(),
       _score = score,
       _gameStartTime = gameStartTime {
    _validateState();
  }

  final Wall wall;

  GameState _currentState;
  Map<ResourceType, Resource> _resources;
  List<Enemy> _enemies;
  Wave _currentWave;
  int _score;
  DateTime? _gameStartTime;

  /// Current game state
  GameState get currentState => _currentState;

  /// All resource types and their current amounts
  Map<ResourceType, Resource> get resources => Map.unmodifiable(_resources);

  /// Active enemies on the game field
  List<Enemy> get enemies => List.unmodifiable(_enemies);

  /// Current wave information
  Wave get currentWave => _currentWave;

  /// Current game score
  int get score => _score;

  /// When the current game session started
  DateTime? get gameStartTime => _gameStartTime;

  /// Whether the game is currently being played
  bool get isPlaying => _currentState == GameState.playing;

  /// Whether the game is over (wall destroyed)
  bool get isGameOver =>
      _currentState == GameState.gameOver || wall.isDestroyed;

  /// Whether the game is paused
  bool get isPaused => _currentState == GameState.paused;

  /// Total game time elapsed
  Duration? get totalGameTime {
    if (_gameStartTime == null) return null;
    return DateTime.now().difference(_gameStartTime!);
  }

  /// Get resource amount for a specific type
  int getResourceAmount(ResourceType type) {
    return _resources[type]?.amount ?? 0;
  }

  /// Get resource generation rate for a specific type
  double getResourceGenerationRate(ResourceType type) {
    return _resources[type]?.generationRate ?? 0.0;
  }

  /// Check if player can afford a cost
  bool canAfford(Map<ResourceType, int> costs) {
    for (final entry in costs.entries) {
      if (getResourceAmount(entry.key) < entry.value) {
        return false;
      }
    }
    return true;
  }

  /// Start a new game
  GameStateModel startGame() {
    return GameStateModel(
      currentState: GameState.playing,
      wall: wall,
      resources: _createDefaultResources(),
      enemies: <Enemy>[],
      currentWave: Wave().startWave(1),
      score: 0,
      gameStartTime: DateTime.now(),
    );
  }

  /// Pause the current game
  GameStateModel pauseGame() {
    if (!isPlaying) return this;

    return copyWith(currentState: GameState.paused);
  }

  /// Resume the paused game
  GameStateModel resumeGame() {
    if (!isPaused) return this;

    return copyWith(currentState: GameState.playing);
  }

  /// End the current game
  GameStateModel endGame() {
    return copyWith(
      currentState: GameState.gameOver,
      currentWave: _currentWave.endWave(),
    );
  }

  /// Return to menu
  GameStateModel returnToMenu() {
    return GameStateModel(currentState: GameState.menu, wall: wall);
  }

  /// Update game state (called each frame)
  GameStateModel update() {
    if (!isPlaying) return this;

    // Generate resources
    final updatedResources = <ResourceType, Resource>{};
    for (final entry in _resources.entries) {
      final resource = entry.value;
      resource.generateResources();
      updatedResources[entry.key] = resource;
    }

    // Update wave timer
    final updatedWave = _currentWave.copyWith();
    if (updatedWave.isActive) {
      updatedWave.updateTimer();
    }

    // Update enemies
    final updatedEnemies = <Enemy>[];
    for (final enemy in _enemies) {
      if (enemy.isAlive) {
        enemy.moveTowardTarget(1.0 / 60.0); // Assuming 60 FPS
        enemy.updateCooldown();
        updatedEnemies.add(enemy);
      }
    }

    // Check for game over
    if (wall.isDestroyed) {
      return endGame();
    }

    return copyWith(
      resources: updatedResources,
      enemies: updatedEnemies,
      currentWave: updatedWave,
    );
  }

  /// Add score points
  GameStateModel addScore(int points) {
    if (points < 0) {
      throw ArgumentError('Score points cannot be negative: $points');
    }

    return copyWith(score: _score + points);
  }

  /// Add an enemy to the game
  GameStateModel addEnemy(Enemy enemy) {
    final updatedEnemies = List<Enemy>.from(_enemies)..add(enemy);
    return copyWith(enemies: updatedEnemies);
  }

  /// Remove an enemy from the game
  GameStateModel removeEnemy(Enemy enemy) {
    final updatedEnemies = List<Enemy>.from(_enemies)..remove(enemy);
    return copyWith(enemies: updatedEnemies);
  }

  /// Spend resources on an upgrade
  GameStateModel spendResources(Map<ResourceType, int> costs) {
    if (!canAfford(costs)) {
      return this; // Cannot afford, no change
    }

    final updatedResources = <ResourceType, Resource>{};
    for (final entry in _resources.entries) {
      final resource = entry.value;
      final cost = costs[entry.key] ?? 0;

      if (cost > 0) {
        resource.spend(cost);
      }

      updatedResources[entry.key] = resource;
    }

    return copyWith(resources: updatedResources);
  }

  /// Create default resource configuration
  static Map<ResourceType, Resource> _createDefaultResources() {
    return {
      ResourceType.blue: Resource(
        type: ResourceType.blue,
        amount: 0,
        generationRate: 1.0, // 1 per second
        isGenerating: true,
      ),
      ResourceType.green: Resource(
        type: ResourceType.green,
        amount: 0,
        generationRate: 0.5, // 0.5 per second
        isGenerating: true,
      ),
      ResourceType.yellow: Resource(
        type: ResourceType.yellow,
        amount: 0,
        generationRate: 0.2, // 0.2 per second
        isGenerating: true,
      ),
    };
  }

  /// Validate game state
  void _validateState() {
    if (_score < 0) {
      throw StateError('Score cannot be negative: $_score');
    }
    if (_resources.isEmpty) {
      throw StateError('Resources cannot be empty');
    }
    for (final resourceType in ResourceType.values) {
      if (!_resources.containsKey(resourceType)) {
        throw StateError('Missing resource type: $resourceType');
      }
    }
  }

  /// Create a copy with updated values
  GameStateModel copyWith({
    GameState? currentState,
    Wall? wall,
    Map<ResourceType, Resource>? resources,
    List<Enemy>? enemies,
    Wave? currentWave,
    int? score,
    DateTime? gameStartTime,
  }) {
    return GameStateModel(
      currentState: currentState ?? _currentState,
      wall: wall ?? this.wall,
      resources: resources ?? _resources,
      enemies: enemies ?? _enemies,
      currentWave: currentWave ?? _currentWave,
      score: score ?? _score,
      gameStartTime: gameStartTime ?? _gameStartTime,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GameStateModel &&
        other._currentState == _currentState &&
        other.wall == wall &&
        other._resources == _resources &&
        other._enemies == _enemies &&
        other._currentWave == _currentWave &&
        other._score == _score &&
        other._gameStartTime == _gameStartTime;
  }

  @override
  int get hashCode {
    return Object.hash(
      _currentState,
      wall,
      _resources,
      _enemies,
      _currentWave,
      _score,
      _gameStartTime,
    );
  }

  @override
  String toString() {
    return 'GameStateModel(state: $_currentState, score: $_score, wave: $_currentWave, enemies: ${_enemies.length})';
  }
}
