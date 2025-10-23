import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/resource_viewmodel.dart';
import '../viewmodels/wall_viewmodel.dart';
import '../viewmodels/enemy_viewmodel.dart';
import '../models/game_enums.dart';
import 'components/wall_component.dart';
import 'components/enemy_component.dart';
import 'components/resource_hud.dart';

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

  @override
  void initState() {
    super.initState();
    // Get ViewModels from context
    _wallViewModel = context.read<WallViewModel>();
    _enemyViewModel = context.read<EnemyViewModel>();
    _resourceViewModel = context.read<ResourceViewModel>();

    // Initialize the Flame game with ViewModels
    _game = TowerDefenseGame(
      wallViewModel: _wallViewModel,
      enemyViewModel: _enemyViewModel,
      resourceViewModel: _resourceViewModel,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Stack(
        children: [
          // Flame game canvas (wall, enemies, effects)
          GameWidget(
            game: _game,
            overlayBuilderMap: {'hud': (context, game) => const ResourceHUD()},
            initialActiveOverlays: const ['hud'],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
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
  });

  late WallComponent wallComponent;
  final WallViewModel wallViewModel;
  final EnemyViewModel enemyViewModel;
  final ResourceViewModel resourceViewModel;

  final List<EnemyComponent> _enemyComponents = [];

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

    // Start resource generation for all types
    resourceViewModel.startGeneration(ResourceType.blue);
    resourceViewModel.startGeneration(ResourceType.green);
    resourceViewModel.startGeneration(ResourceType.yellow);
  }

  @override
  void update(double dt) {
    super.update(dt);

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
        enemy.attack(); // Use attack() method instead of performAttack()
      }
    }
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
