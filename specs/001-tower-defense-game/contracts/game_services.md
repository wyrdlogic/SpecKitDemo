# Game Architecture Contracts (MVVM + SOLID)

**Purpose**: Define interfaces and contracts for MVVM architecture with SOLID principles  
**Target**: Flutter/Dart with Flame game engine  
**Generated**: October 23, 2025  
**Architecture**: MVVM pattern with Dependency Injection

## Service Interfaces (Dependency Inversion Principle)

### IGameEngine Service Interface

Main game loop and state management abstraction.

```dart
abstract class IGameEngine {
  // Game lifecycle management
  Future<void> initializeGame();
  void startGame();
  void pauseGame(); 
  void resumeGame();
  void endGame();
  
  // Frame-by-frame updates (called by Flame game loop)
  void updateGameState(Duration deltaTime);
  void processEnemyMovement(Duration deltaTime);
  void updateResourceGeneration(Duration deltaTime);
  void checkWinConditions();
  
  // State queries
  GameState getCurrentState();
  bool isGameActive();
  int getCurrentLevel();
  Duration getRemainingWaveTime();
}
```

### IResourceManager Service Interface

Resource generation, spending, and upgrade logic abstraction.

```dart
abstract class IResourceManager {
  // Resource generation
  void startResourceGeneration(ResourceType type);
  void stopResourceGeneration(ResourceType type);
  void updateGeneration(Duration deltaTime);
  double getGenerationRate(ResourceType type);
  
  // Resource spending and validation
  bool canAffordUpgrade(UpgradeType upgrade);
  bool spendResources(Map<ResourceType, int> costs);
  void refundResources(Map<ResourceType, int> amounts);
  
  // Upgrade processing  
  void upgradeWall(int blueResourceCost);
  void healWall(int greenResourceCost);
  void upgradeResourceGeneration(ResourceType target, int yellowResourceCost);
  
  // State queries
  int getResourceAmount(ResourceType type);
  Map<ResourceType, int> getAllResources();
}
```

## ViewModel Contracts (MVVM Presentation Layer)

### GameViewModel

Main game state management and coordination ViewModel.

```dart
abstract class GameViewModel extends ChangeNotifier {
  // Game lifecycle
  Future<void> initializeGame();
  void startNewGame();
  void pauseGame();
  void resumeGame();
  void endGame();
  
  // State properties (observable)
  GameStatus get gameStatus;
  int get currentLevel;
  Duration get remainingTime;
  bool get isPaused;
  
  // User actions
  void onResourceButtonPressed(ResourceType type);
  void onWallUpgradePressed();
  void onWallHealPressed();
  void onResourceUpgradePressed(ResourceType type);
  
  // Game loop integration
  void onGameTick(Duration deltaTime);
}
```

## EnemySpawner Service

Enemy creation, movement, and combat mechanics.

```dart
abstract class EnemySpawner {
  // Enemy lifecycle
  void spawnEnemy(int waveLevel);
  void updateEnemies(Duration deltaTime);
  void removeDeadEnemies();
  void clearAllEnemies();
  
  // Combat mechanics
  void processEnemyAttacks();
  void calculateDamageToWall(Enemy enemy);
  
  // Wave configuration
  void configureWaveSpawning(int level);
  double getSpawnRateForLevel(int level);
  EnemyStats getEnemyStatsForLevel(int level);
  
  // State queries
  List<Enemy> getActiveEnemies();
  int getEnemyCount();
  bool hasEnemiesRemaining();
}
```

## DifficultyScaler Service

Level progression and difficulty scaling calculations.

```dart
abstract class DifficultyScaler {
  // Level progression
  void advanceToNextLevel();
  int calculateNextWallUpgradeCost(int currentLevel);
  int calculateHealCost(int wallLevel);
  int calculateResourceUpgradeCost(ResourceType type, int currentLevel);
  
  // Enemy scaling
  EnemyStats scaleEnemyForLevel(int level);
  double calculateEnemySpeedMultiplier(int level);
  int calculateEnemyDamageForLevel(int level);
  int calculateEnemyHPForLevel(int level);
  
  // Resource scaling  
  double calculateResourceGenerationRate(ResourceType type, int upgradeLevel);
  
  // Game balance queries
  int getRecommendedWallLevelForWave(int waveLevel);
  bool isLevelProgressionBalanced(int currentLevel, GameState state);
}
```

## Wall Service

Wall state management, upgrades, and damage processing.

```dart
abstract class Wall {
  // Wall state management
  void initializeWall(int startingHP, int startingLevel);
  void upgradeWall();
  void takeDamage(int damage);
  void heal(int healAmount);
  
  // Visual state
  Color getWallColorForLevel(int level);
  double getWallHealthPercentage();
  
  // State queries
  int getCurrentHP();
  int getMaxHP();
  int getWallLevel();
  bool isWallDestroyed();
  bool canBeHealed();
}
```

## UI Event Contracts

User interface interaction handling.

```dart
abstract class GameUIController {
  // User input handling
  void onResourceButtonTapped(ResourceType type);
  void onWallUpgradeRequested();
  void onWallHealRequested();
  void onResourceUpgradeRequested(ResourceType type);
  void onPauseRequested();
  void onResumeRequested();
  void onNewGameRequested();
  
  // UI state updates
  void updateResourceDisplay();
  void updateWallVisuals();
  void updateTimerDisplay();
  void updateEnemyPositions();
  void showGameOverScreen();
  void showVictoryScreen();
  
  // Validation and feedback
  bool validateUserAction(UserAction action);
  void showInsufficientResourcesMessage(ResourceType type);
  void showUpgradeSuccessMessage();
}
```

## Data Transfer Objects

Shared data structures for service communication.

```dart
class EnemyStats {
  final int hp;
  final int damage; 
  final double speed;
  final double spawnRate;
  
  EnemyStats({required this.hp, required this.damage, required this.speed, required this.spawnRate});
}

class GameState {
  final Wall wall;
  final List<Enemy> enemies;
  final Map<ResourceType, Resource> resources;
  final Wave currentWave;
  final GameStatus status;
  
  GameState({required this.wall, required this.enemies, required this.resources, required this.currentWave, required this.status});
}

enum ResourceType { blue, green, yellow }
enum UpgradeType { wall, heal, resourceGeneration }
enum GameStatus { menu, playing, paused, gameOver, victory }
```