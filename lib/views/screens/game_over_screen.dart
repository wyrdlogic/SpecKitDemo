import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/wall_viewmodel.dart';
import '../../viewmodels/enemy_viewmodel.dart';
import '../game_view.dart';

/// Screen displayed when the wall is destroyed (Game Over)
class GameOverScreen extends StatelessWidget {
  const GameOverScreen({
    super.key,
    required this.finalLevel,
    required this.enemiesDefeated,
  });

  final int finalLevel;
  final int enemiesDefeated;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withAlpha((0.95 * 255).round()),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.red.shade900.withAlpha((0.9 * 255).round()),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.red, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withAlpha((0.5 * 255).round()),
                blurRadius: 30,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Game Over Title
              const Icon(
                Icons.warning_amber_rounded,
                size: 80,
                color: Colors.white,
              ),
              const SizedBox(height: 20),
              Text(
                'WALL DESTROYED',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 48,
                  shadows: [
                    const Shadow(
                      offset: Offset(2, 2),
                      blurRadius: 4,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Stats
              _buildStatRow(context, 'Final Level', finalLevel.toString()),
              const SizedBox(height: 15),
              _buildStatRow(
                context,
                'Enemies Defeated',
                enemiesDefeated.toString(),
              ),

              const SizedBox(height: 60),

              // Buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildButton(
                    context,
                    label: 'Try Again',
                    icon: Icons.refresh,
                    color: Colors.green,
                    onPressed: () => _restartGame(context),
                  ),
                  const SizedBox(width: 20),
                  _buildButton(
                    context,
                    label: 'Main Menu',
                    icon: Icons.home,
                    color: Colors.grey,
                    onPressed: () => _returnToMenu(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: Colors.white70),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
      ],
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _restartGame(BuildContext context) {
    // Reset all ViewModels
    final wallVM = context.read<WallViewModel>();
    final enemyVM = context.read<EnemyViewModel>();

    wallVM.reset();
    enemyVM.clearAll();

    // Navigate back to game
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const GameView()),
    );
  }

  void _returnToMenu(BuildContext context) {
    // For now, just restart the game
    // TODO: Implement proper main menu
    _restartGame(context);
  }
}
