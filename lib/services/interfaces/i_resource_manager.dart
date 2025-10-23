import '../../models/game_enums.dart';
import '../../models/resource.dart';

/// Interface for managing game resources (generation, spending, upgrades)
abstract interface class IResourceManager {
  /// Get current amount of a specific resource type
  int getAmount(ResourceType type);

  /// Get generation rate for a specific resource type
  double getGenerationRate(ResourceType type);

  /// Check if player can afford the specified costs
  bool canAfford(Map<ResourceType, int> costs);

  /// Attempt to spend resources, returns true if successful
  bool spendResources(Map<ResourceType, int> costs);

  /// Add resources to the player's inventory
  void addResources(Map<ResourceType, int> amounts);

  /// Start resource generation for a specific type
  void startGeneration(ResourceType type);

  /// Stop resource generation for a specific type
  void stopGeneration(ResourceType type);

  /// Upgrade the generation rate for a specific resource type
  void upgradeGenerationRate(ResourceType type, double rateIncrease);

  /// Get all resources as a map
  Map<ResourceType, Resource> getAllResources();

  /// Reset all resources to initial state
  void resetResources();

  /// Update resource generation (call each frame)
  void updateGeneration();

  /// Stream of resource updates
  Stream<Map<ResourceType, Resource>> get resourceStream;

  /// Calculate upgrade cost for resource generation
  Map<ResourceType, int> calculateUpgradeCost(
    ResourceType type,
    int currentLevel,
  );
}
