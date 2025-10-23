import 'dart:math';

import 'package:tower_defense_game/viewmodels/base_viewmodel.dart';
import 'package:tower_defense_game/models/resource.dart';
import 'package:tower_defense_game/models/game_enums.dart';

/// ViewModel for managing resource generation and spending
final class ResourceViewModel extends BaseViewModel {
  ResourceViewModel() {
    _initializeResources();
  }

  final Map<ResourceType, Resource> _resources = {};

  /// Get resource by type
  Resource? getResource(ResourceType type) => _resources[type];

  /// Get resource amount by type
  int getAmount(ResourceType type) => _resources[type]?.amount ?? 0;

  /// Get all resources
  Map<ResourceType, Resource> get resources => Map.unmodifiable(_resources);

  /// Start generating a specific resource type
  Future<void> startGeneration(ResourceType type) async {
    final resource = _resources[type];
    if (resource != null) {
      // Set initial generation rate if not already set
      if (resource.generationRate == 0.0) {
        resource.setGenerationRate(
          1.0,
        ); // Base generation rate: 1 resource per second
      }
      resource.startGeneration();
      notifyListeners();
    }
  }

  /// Stop generating a specific resource type
  Future<void> stopGeneration(ResourceType type) async {
    final resource = _resources[type];
    if (resource != null) {
      resource.stopGeneration();
      notifyListeners();
    }
  }

  /// Update resource generation (called each frame)
  void updateGeneration() {
    for (final resource in _resources.values) {
      resource.generateResources();
    }
    notifyListeners();
  }

  /// Check if can afford a cost
  bool canAfford(ResourceType type, int cost) {
    return _resources[type]?.canAfford(cost) ?? false;
  }

  /// Spend resources
  bool spend(ResourceType type, int cost) {
    final resource = _resources[type];
    if (resource != null && resource.spend(cost)) {
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Add resources
  void add(ResourceType type, int amount) {
    _resources[type]?.add(amount);
    notifyListeners();
  }

  /// Upgrade generation rate for a resource type
  Future<void> upgradeGenerationRate(
    ResourceType targetType,
    double rateIncrease,
    ResourceType costType,
    int cost,
  ) async {
    if (canAfford(costType, cost)) {
      if (spend(costType, cost)) {
        _resources[targetType]?.upgradeGenerationRate(rateIncrease);
        notifyListeners();
      }
    }
  }

  /// Get upgrade level for a resource type (based on current generation rate)
  /// Base rate is 1.0, each upgrade adds 0.5, so level = (rate - 1.0) / 0.5
  int getUpgradeLevel(ResourceType type) {
    final resource = _resources[type];
    if (resource == null || resource.generationRate <= 1.0) return 0;
    return ((resource.generationRate - 1.0) / 0.5).round();
  }

  /// Calculate upgrade cost with exponential scaling
  /// Base cost: 50 yellow, multiplier: 1.5x per level
  int getUpgradeCost(ResourceType type) {
    final level = getUpgradeLevel(type);
    return _calculateUpgradeCost(50, level, 1.5);
  }

  /// Upgrade resource generation (simplified method for UI)
  Future<void> upgradeResourceGeneration(ResourceType targetType) async {
    final cost = getUpgradeCost(targetType);
    await upgradeGenerationRate(
      targetType,
      0.5, // Each upgrade adds 0.5/s
      ResourceType.yellow, // Cost in yellow
      cost,
    );
  }

  /// Calculate exponential upgrade cost
  /// Formula: baseCost * (multiplier ^ level)
  int _calculateUpgradeCost(int baseCost, int level, double multiplier) {
    if (level == 0) return baseCost;
    return (baseCost * pow(multiplier, level)).round();
  }

  void _initializeResources() {
    for (final type in ResourceType.values) {
      _resources[type] = Resource(type: type);
    }
  }

  @override
  void dispose() {
    // Clean up resources if needed
    super.dispose();
  }
}
