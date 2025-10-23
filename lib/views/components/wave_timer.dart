import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/wave_viewmodel.dart';

/// Widget displaying wave timer and level information
class WaveTimer extends StatelessWidget {
  const WaveTimer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WaveViewModel>(
      builder: (context, waveViewModel, child) {
        final timeRemaining = waveViewModel.timeRemaining;
        final currentLevel = waveViewModel.currentLevel;
        final progress = waveViewModel.progress;
        final isActive = waveViewModel.isWaveActive;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? Colors.blue : Colors.grey,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Level display
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Level $currentLevel',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Timer display
              Row(
                children: [
                  Icon(
                    Icons.timer,
                    color: isActive ? Colors.blue : Colors.grey,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatTime(timeRemaining),
                    style: TextStyle(
                      color: _getTimerColor(timeRemaining, isActive),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Progress bar
              SizedBox(
                height: 8,
                width: 200,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.shade800,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getProgressColor(progress, isActive),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),

              // Status text
              if (!isActive)
                const Text(
                  'Wave Complete!',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// Format time in MM:SS format
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  /// Get timer color based on remaining time
  Color _getTimerColor(int timeRemaining, bool isActive) {
    if (!isActive) return Colors.grey;
    if (timeRemaining <= 10) return Colors.red;
    if (timeRemaining <= 30) return Colors.orange;
    return Colors.white;
  }

  /// Get progress bar color based on progress
  Color _getProgressColor(double progress, bool isActive) {
    if (!isActive) return Colors.grey;
    if (progress >= 0.7) return Colors.green;
    if (progress >= 0.3) return Colors.orange;
    return Colors.red;
  }
}
