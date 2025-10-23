/// Game constants and configuration values
///
/// Centralized location for all game configuration values
/// to support easy tweaking and maintenance.
class GameConstants {
  // Private constructor to prevent instantiation
  GameConstants._();

  // ============================================================================
  // GAME PERFORMANCE
  // ============================================================================

  /// Target frame rate for game updates
  static const int targetFps = 60;

  /// Maximum frame time in milliseconds before performance warnings
  static const double maxFrameTime = 16.67; // ~60 FPS

  // ============================================================================
  // GAME DIMENSIONS
  // ============================================================================

  /// Default game canvas width
  static const double gameWidth = 800.0;

  /// Default game canvas height
  static const double gameHeight = 600.0;

  /// Minimum supported screen width
  static const double minScreenWidth = 480.0;

  /// Minimum supported screen height
  static const double minScreenHeight = 320.0;

  // ============================================================================
  // GAME MECHANICS
  // ============================================================================

  /// Starting player resources
  static const int initialGold = 100;
  static const int initialWood = 50;
  static const int initialStone = 30;

  /// Base building costs
  static const int towerBaseCost = 25;
  static const int wallBaseCost = 10;
  static const int resourceBuildingBaseCost = 50;

  /// Game timing
  static const double waveInterval = 30.0; // seconds between waves
  static const double resourceGenerationInterval =
      5.0; // seconds between resource ticks

  /// Enemy properties
  static const double enemyBaseSpeed = 50.0; // pixels per second
  static const int enemyBaseHealth = 100;
  static const double enemySpawnInterval = 2.0; // seconds between enemy spawns

  /// Tower properties
  static const double towerBaseRange = 100.0; // pixels
  static const int towerBaseDamage = 25;
  static const double towerBaseFireRate = 1.0; // attacks per second

  // ============================================================================
  // UI CONSTANTS
  // ============================================================================

  /// Standard UI measurements
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;

  /// Button dimensions
  static const double buttonHeight = 48.0;
  static const double buttonMinWidth = 120.0;

  /// Icon sizes
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;

  /// Animation durations (in milliseconds)
  static const int animationDurationFast = 150;
  static const int animationDurationMedium = 300;
  static const int animationDurationSlow = 500;

  // ============================================================================
  // ASSET PATHS
  // ============================================================================

  /// Image asset paths
  static const String imagesPath = 'assets/images/';
  static const String iconsPath = '${imagesPath}icons/';
  static const String spritesPath = '${imagesPath}sprites/';

  /// Audio asset paths
  static const String audioPath = 'assets/audio/';
  static const String soundEffectsPath = '${audioPath}sfx/';
  static const String musicPath = '${audioPath}music/';

  // ============================================================================
  // DEBUG & DEVELOPMENT
  // ============================================================================

  /// Debug configuration
  static const bool debugMode = true; // Should be false in production
  static const bool showFpsCounter = debugMode;
  static const bool showCollisionBoxes = debugMode;
  static const bool enableConsoleLogging = debugMode;

  /// Development shortcuts
  static const bool enableCheatCodes = debugMode;
  static const bool skipTutorial = debugMode;

  // ============================================================================
  // COLORS (Material Design inspired)
  // ============================================================================

  /// Primary colors
  static const int primaryColorValue = 0xFF2196F3;
  static const int secondaryColorValue = 0xFF03DAC6;
  static const int errorColorValue = 0xFFB00020;

  /// Resource colors
  static const int goldColorValue = 0xFFFFD700;
  static const int woodColorValue = 0xFF8D6E63;
  static const int stoneColorValue = 0xFF607D8B;

  /// Game element colors
  static const int enemyColorValue = 0xFFE53935;
  static const int towerColorValue = 0xFF43A047;
  static const int wallColorValue = 0xFF5E35B1;
}
