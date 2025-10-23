import 'dart:async';
import 'package:tower_defense_game/models/game_enums.dart';
import 'package:tower_defense_game/models/resource.dart';
import 'package:tower_defense_game/services/interfaces/i_resource_manager.dart';

/// Service implementation for managing game resources
class ResourceManagerService implements IResourceManager {
  ResourceManagerService() {
    _initializeResources();
  }

  final Map<ResourceType, Resource> _resources = {};
  final StreamController<Map<ResourceType, Resource>> _resourceController =
      StreamController<Map<ResourceType, Resource>>.broadcast();

  @override
  int getAmount(ResourceType type) {
    return _resources[type]?.amount ?? 0;
  }

  @override
  double getGenerationRate(ResourceType type) {
    return _resources[type]?.generationRate ?? 0.0;
  }

  @override
  bool canAfford(Map<ResourceType, int> costs) {
    for (final entry in costs.entries) {
      final resource = _resources[entry.key];
      if (resource == null || !resource.canAfford(entry.value)) {
        return false;
      }
    }
    return true;
  }

  @override
  bool spendResources(Map<ResourceType, int> costs) {
    // Check if can afford all costs
    if (!canAfford(costs)) {
      return false;
    }

    // Spend all resources
    for (final entry in costs.entries) {
      final resource = _resources[entry.key];
      if (resource != null) {
        resource.spend(entry.value);
      }
    }

    _notifyResourceChange();
    return true;
  }

  @override
  void addResources(Map<ResourceType, int> amounts) {
    for (final entry in amounts.entries) {
      final resource = _resources[entry.key];
      if (resource != null && entry.value > 0) {
        resource.add(entry.value);
      }
    }
    _notifyResourceChange();
  }

  @override
  void startGeneration(ResourceType type) {
    _resources[type]?.startGeneration();
    _notifyResourceChange();
  }

  @override
  void stopGeneration(ResourceType type) {
    _resources[type]?.stopGeneration();
    _notifyResourceChange();
  }

  @override
  void upgradeGenerationRate(ResourceType type, double rateIncrease) {
    _resources[type]?.upgradeGenerationRate(rateIncrease);
    _notifyResourceChange();
  }

  @override
  Map<ResourceType, Resource> getAllResources() {
    return Map.unmodifiable(_resources);
  }

  @override
  void resetResources() {
    for (final resource in _resources.values) {
      resource.reset();
    }
    _notifyResourceChange();
  }

  @override
  void updateGeneration() {
    for (final resource in _resources.values) {
      resource.generateResources();
    }
    _notifyResourceChange();
  }

  @override
  Stream<Map<ResourceType, Resource>> get resourceStream =>
      _resourceController.stream;

  @override
  Map<ResourceType, int> calculateUpgradeCost(
    ResourceType type,
    int currentLevel,
  ) {
    // Cost scales exponentially with level
    // Use yellow resources for blue/green upgrades
    final baseCost = 50;
    final cost = (baseCost * (1.5 * currentLevel)).round();

    return {ResourceType.yellow: cost};
  }

  void _initializeResources() {
    for (final type in ResourceType.values) {
      _resources[type] = Resource(type: type);
    }
  }

  void _notifyResourceChange() {
    _resourceController.add(Map.unmodifiable(_resources));
  }

  /// Dispose resources
  void dispose() {
    _resourceController.close();
  }
}
