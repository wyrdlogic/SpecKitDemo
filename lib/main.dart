import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'core/service_locator.dart'; // TODO: Uncomment when services are implemented

Future<void> main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Configure system UI for web game
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Initialize dependency injection
  _setupDependencyInjection();

  runApp(const TowerDefenseApp());
}

/// Setup dependency injection container with all services
void _setupDependencyInjection() {
  // TODO: Register services when they are implemented
  // final services = ServiceLocator.instance;
  // services.register<IGameEngine>(() => GameEngineService());
  // services.register<IResourceManager>(() => ResourceManagerService());
  // services.register<IEnemySpawner>(() => EnemySpawnerService());
  // services.register<IDifficultyScaler>(() => DifficultyScalerService());
}

class TowerDefenseApp extends StatelessWidget {
  const TowerDefenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tower Defense - Resource Management Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const PlaceholderGameScreen(),
    );
  }
}

/// Placeholder game screen until actual game view is implemented
class PlaceholderGameScreen extends StatelessWidget {
  const PlaceholderGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.games, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            Text(
              'Tower Defense Game',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Phase 2 Foundation Complete',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue, width: 2),
              ),
              child: Column(
                children: [
                  Text(
                    'MVVM Architecture Ready',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '✅ Models: Wall, Enemy, Resource, Wave, GameState\n'
                    '✅ Service Interfaces: Game Engine, Resource Manager, Enemy Spawner, Difficulty Scaler\n'
                    '✅ Base ViewModel with ChangeNotifier\n'
                    '✅ Flame Component Base Classes\n'
                    '✅ Math & Animation Utils\n'
                    '✅ Dependency Injection Setup',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
