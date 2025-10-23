import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/resource_viewmodel.dart';
import '../viewmodels/wall_viewmodel.dart';
import '../viewmodels/enemy_viewmodel.dart';
import '../viewmodels/wave_viewmodel.dart';
import '../models/game_enums.dart';
import 'components/wall_component.dart';
import 'components/enemy_component.dart';
import 'components/resource_hud.dart';
import 'components/wave_timer.dart';
import 'screens/game_over_screen.dart';

/// Main game view that integrates Flame game engine with Flutter UI
class GameView extends StatefulWidget {
  const GameView({super.key});

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  late final TowerDefenseGame _game;
  late final WallViewModel _wallViewModel;
  late final EnemyViewModel _enemyViewModel;
  late final ResourceViewModel _resourceViewModel;
  late final WaveViewModel _waveViewModel;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Initialize only once
    if (!_initialized) {
      _initialized = true;

      // Get ViewModels from context - safe to use context.read here
      _wallViewModel = context.read<WallViewModel>();
      _enemyViewModel = context.read<EnemyViewModel>();
      _resourceViewModel = context.read<ResourceViewModel>();
      _waveViewModel = context.read<WaveViewModel>();

      // Listen for wall destruction
      _wallViewModel.addListener(_checkGameOver);

      // Listen for wave state changes
      _waveViewModel.addListener(_onWaveStateChanged);

      // Initialize the Flame game with ViewModels
      _game = TowerDefenseGame(
        wallViewModel: _wallViewModel,
        enemyViewModel: _enemyViewModel,
        resourceViewModel: _resourceViewModel,
        waveViewModel: _waveViewModel,
      );

      // Schedule initialization for after the first frame is rendered
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          // Start the first wave
          _waveViewModel.startWave(level: 1);
        }
      });
    }
  }

  void _onWaveStateChanged() {
    // Check if wave just completed
    if (_waveViewModel.isWaveComplete && !_waveViewModel.isWaveActive) {
      // Wave is complete, advance level after delay
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && !_wallViewModel.isDestroyed) {
          _waveViewModel.advanceLevel();
          _waveViewModel.startWave(level: _waveViewModel.currentLevel);
        }
      });
    }
  }

  void _checkGameOver() {
    if (_wallViewModel.isDestroyed) {
      // Wall is destroyed - show game over screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => GameOverScreen(
            finalLevel: _waveViewModel.currentLevel,
            enemiesDefeated: _enemyViewModel.enemies.length,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Column(
        children: [
          // Flame game canvas (wall, enemies, effects) - takes most of the space
          Expanded(
            child: Stack(
              children: [
                GameWidget(game: _game),
                // Wave timer in top right of game area
                Positioned(top: 16, right: 16, child: const WaveTimer()),
              ],
            ),
          ),
          // ResourceHUD at the bottom - fixed height, scrollable if needed
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.black.withAlpha((0.9 * 255).round()),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withAlpha((0.3 * 255).round()),
                  width: 2,
                ),
              ),
            ),
            child: SingleChildScrollView(child: const ResourceHUD()),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _wallViewModel.removeListener(_checkGameOver);
    _waveViewModel.removeListener(_onWaveStateChanged);
    _game.onRemove();
    super.dispose();
  }
}

/// The main Flame game that handles rendering and game loop
class TowerDefenseGame extends FlameGame {
  TowerDefenseGame({
    required this.wallViewModel,
    required this.enemyViewModel,
    required this.resourceViewModel,
    required this.waveViewModel,
  });

  late WallComponent wallComponent;
  final WallViewModel wallViewModel;
  final EnemyViewModel enemyViewModel;
  final ResourceViewModel resourceViewModel;
  final WaveViewModel waveViewModel;

  final List<EnemyComponent> _enemyComponents = [];
  double _spawnTimer = 0.0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Initialize wall at center of screen
    final wallPosition = Vector2(size.x / 2, size.y / 2);
    wallComponent = WallComponent(
      viewModel: wallViewModel,
      position: wallPosition,
    );
    await add(wallComponent);

    // Start resource generation after widget tree is fully built
    // This is called from TowerDefenseGame which is created after first frame
    Future.microtask(() {
      resourceViewModel.startGeneration(ResourceType.blue);
      resourceViewModel.startGeneration(ResourceType.green);
      resourceViewModel.startGeneration(ResourceType.yellow);
    });
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update wave timer
    if (waveViewModel.isWaveActive) {
      waveViewModel.updateWave(dt);

      // Handle enemy spawning based on wave
      _updateEnemySpawning(dt);
    }

    // Update enemy ViewModels with delta time for movement
    if (enemyViewModel.activeEnemyCount > 0) {
      enemyViewModel.updateEnemies(dt);

      // Clean up dead enemies
      enemyViewModel.removeDeadEnemies();

      // Sync enemy components with enemy models
      _syncEnemyComponents();
    }

    // Check for enemies at wall for combat
    final enemiesAtWall = enemyViewModel.getEnemiesAtTarget();
    for (final enemy in enemiesAtWall) {
      if (enemy.canAttack) {
        wallViewModel.takeDamage(enemy.damage);
        enemy.attack();
      }
    }
  }

  /// Update enemy spawning based on wave progress
  void _updateEnemySpawning(double dt) {
    if (!waveViewModel.isWaveActive) return;

    _spawnTimer += dt;

    // Check if we should spawn an enemy
    if (waveViewModel.shouldSpawnEnemy()) {
      _spawnEnemy();
      waveViewModel.incrementEnemySpawnCount();
      _spawnTimer = 0.0;
    }
  }

  /// Spawn a single enemy
  void _spawnEnemy() {
    // Random spawn position along the left edge
    final y = (size.y * (0.2 + (Vector2.random().y * 0.6)));
    final spawnPosition = Offset(0, y);

    // Target is the wall position
    final target = Offset(size.x / 2, size.y / 2);

    // Spawn enemy using the ViewModel
    enemyViewModel.spawnEnemies(
      type: _getEnemyTypeForLevel(waveViewModel.currentLevel),
      positions: [spawnPosition],
      target: target,
      level: waveViewModel.currentLevel,
    );
  }

  /// Get enemy type based on current level
  EnemyType _getEnemyTypeForLevel(int level) {
    if (level < 3) return EnemyType.basic;
    if (level < 5) {
      // Mix of basic and fast
      return Vector2.random().x > 0.5 ? EnemyType.fast : EnemyType.basic;
    }
    // Mix of all types
    final rand = Vector2.random().x;
    if (rand < 0.33) return EnemyType.basic;
    if (rand < 0.66) return EnemyType.fast;
    return EnemyType.strong;
  }

  /// Synchronize Flame components with enemy models
  void _syncEnemyComponents() {
    // Remove components for dead enemies
    _enemyComponents.removeWhere((component) {
      if (!component.enemy.isAlive) {
        component.removeFromParent();
        return true;
      }
      return false;
    });

    // Add new components for newly spawned enemies
    for (final enemy in enemyViewModel.enemies) {
      final hasComponent = _enemyComponents.any((c) => c.enemy == enemy);
      if (!hasComponent) {
        final component = EnemyComponent(enemy: enemy);
        add(component);
        _enemyComponents.add(component);
      }
    }
  }

  /// Spawn a wave of enemies
  Future<void> spawnWave({required int level, required int waveNumber}) async {
    // Spawn positions along the left edge
    final spawnCount = 5 + (level * 2);
    final spawnPositions = <Offset>[];

    for (var i = 0; i < spawnCount; i++) {
      final y = (i + 1) * (size.y / (spawnCount + 1));
      spawnPositions.add(Offset(0, y));
    }

    // Target is the wall position
    final target = Offset(size.x / 2, size.y / 2);

    // Spawn enemies using the spawner service
    await enemyViewModel.spawnEnemies(
      type: EnemyType.basic, // Use basic enemy type for now
      positions: spawnPositions,
      target: target,
      level: level,
    );
  }

  @override
  void onRemove() {
    // Clean up resources
    resourceViewModel.stopGeneration(ResourceType.blue);
    resourceViewModel.stopGeneration(ResourceType.green);
    resourceViewModel.stopGeneration(ResourceType.yellow);
    super.onRemove();
  }
}
