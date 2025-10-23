import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tower_defense_game/viewmodels/resource_viewmodel.dart';
import 'package:tower_defense_game/viewmodels/wall_viewmodel.dart';
import 'package:tower_defense_game/models/game_enums.dart';

/// HUD widget displaying resources and action buttons
class ResourceHUD extends StatelessWidget {
  const ResourceHUD({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ResourceViewModel, WallViewModel>(
      builder: (context, resourceVM, wallVM, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha((0.7 * 255).round()),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Resource display
              _buildResourceDisplay(resourceVM),
              const SizedBox(height: 16),
              const Divider(color: Colors.white24),
              const SizedBox(height: 16),
              // Wall info
              _buildWallInfo(wallVM),
              const SizedBox(height: 16),
              const Divider(color: Colors.white24),
              const SizedBox(height: 16),
              // Action buttons
              _buildActionButtons(context, resourceVM, wallVM),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResourceDisplay(ResourceViewModel resourceVM) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resources',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...ResourceType.values.map((type) {
          return _buildResourceRow(
            type,
            resourceVM.getAmount(type),
            resourceVM.getResource(type)?.generationRate ?? 0.0,
            resourceVM.getResource(type)?.isGenerating ?? false,
          );
        }),
      ],
    );
  }

  Widget _buildResourceRow(
    ResourceType type,
    int amount,
    double rate,
    bool isGenerating,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            _getResourceIcon(type),
            color: _getResourceColor(type),
            size: 20,
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(
              type.displayName,
              style: TextStyle(
                color: _getResourceColor(type),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            amount.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (isGenerating && rate > 0) ...[
            const SizedBox(width: 8),
            Text(
              '(+${rate.toStringAsFixed(1)}/s)',
              style: const TextStyle(color: Colors.green, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWallInfo(WallViewModel wallVM) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Wall Status',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text(
              'Level:',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(width: 8),
            Text(
              wallVM.level.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Text(
              'HP:',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(width: 8),
            Text(
              '${wallVM.currentHP}/${wallVM.maxHP}',
              style: TextStyle(
                color: _getHealthColor(wallVM.healthPercentage),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Health bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: wallVM.healthPercentage,
            backgroundColor: Colors.red.shade900,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getHealthColor(wallVM.healthPercentage),
            ),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    ResourceViewModel resourceVM,
    WallViewModel wallVM,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Actions',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        // Resource generation buttons
        _buildResourceButton(
          'Generate Blue',
          Icons.add_circle,
          Colors.blue,
          () => resourceVM.startGeneration(ResourceType.blue),
          enabled: true,
        ),
        const SizedBox(height: 8),
        _buildResourceButton(
          'Generate Green',
          Icons.add_circle,
          Colors.green,
          () => resourceVM.startGeneration(ResourceType.green),
          enabled: true,
        ),
        const SizedBox(height: 8),
        _buildResourceButton(
          'Generate Yellow',
          Icons.add_circle,
          Colors.yellow,
          () => resourceVM.startGeneration(ResourceType.yellow),
          enabled: true,
        ),
        const SizedBox(height: 12),
        // Wall upgrade button
        _buildActionButton(
          'Upgrade Wall (50 Blue)',
          Icons.arrow_upward,
          () => _upgradeWall(resourceVM, wallVM),
          enabled: resourceVM.canAfford(ResourceType.blue, 50),
        ),
        const SizedBox(height: 8),
        // Wall heal button
        _buildActionButton(
          'Heal Wall (30 Green)',
          Icons.favorite,
          () => _healWall(resourceVM, wallVM),
          enabled:
              resourceVM.canAfford(ResourceType.green, 30) &&
              wallVM.currentHP < wallVM.maxHP,
        ),
      ],
    );
  }

  Widget _buildResourceButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed, {
    required bool enabled,
  }) {
    return ElevatedButton.icon(
      onPressed: enabled ? onPressed : null,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    VoidCallback onPressed, {
    required bool enabled,
  }) {
    return ElevatedButton.icon(
      onPressed: enabled ? onPressed : null,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    );
  }

  void _upgradeWall(ResourceViewModel resourceVM, WallViewModel wallVM) {
    if (resourceVM.spend(ResourceType.blue, 50)) {
      wallVM.upgrade();
    }
  }

  void _healWall(ResourceViewModel resourceVM, WallViewModel wallVM) {
    if (resourceVM.spend(ResourceType.green, 30)) {
      wallVM.heal(50);
    }
  }

  IconData _getResourceIcon(ResourceType type) {
    switch (type) {
      case ResourceType.blue:
        return Icons.hexagon;
      case ResourceType.green:
        return Icons.favorite;
      case ResourceType.yellow:
        return Icons.star;
    }
  }

  Color _getResourceColor(ResourceType type) {
    switch (type) {
      case ResourceType.blue:
        return Colors.blue;
      case ResourceType.green:
        return Colors.green;
      case ResourceType.yellow:
        return Colors.yellow;
    }
  }

  Color _getHealthColor(double healthPercentage) {
    if (healthPercentage > 0.6) {
      return Colors.green;
    } else if (healthPercentage > 0.3) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
