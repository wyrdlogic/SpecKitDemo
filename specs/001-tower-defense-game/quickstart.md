# Quick Start Guide: Tower Defense Game Development (MVVM + Flame)

**Purpose**: Get developers up and running with the MVVM tower defense game project  
**Target Audience**: Flutter developers familiar with MVVM patterns and game development  
**Generated**: October 23, 2025  
**Architecture**: MVVM with Flame game engine, SOLID principles

## Prerequisites

- Flutter SDK 3.16+ installed and configured
- Dart SDK 3.2+ (included with Flutter)
- VS Code or Android Studio with Flutter extensions
- Chrome or other web browser for testing
- Git for version control
- Basic understanding of MVVM architecture and dependency injection

## Project Setup

### 1. Repository Setup
```bash
# Clone the repository 
git clone [repository-url]
cd tower-defense-game

# Switch to the feature branch
git checkout 001-tower-defense-game

# Verify Flutter installation
flutter doctor
```

### 2. Dependencies Installation
```bash
# Get Flutter dependencies (minimal external packages)
flutter pub get

# Verify the project builds
flutter build android --debug
```

### 3. Web Development Environment
```bash
# Enable Flutter web (if not already enabled)
flutter config --enable-web

# Run the web app in debug mode
flutter run -d chrome

# Or run in any available browser
flutter run -d web-server --web-port 8080
```

## Project Architecture Overview

### Core Structure
```
lib/
├── main.dart              # App entry point and MaterialApp setup
├── models/                # Game entities (Wall, Enemy, Resource, Wave, GameState)
├── services/              # Game logic (GameEngine, ResourceManager, EnemySpawner, DifficultyScaler)  
├── widgets/               # UI components (GameScreen, ResourceButton, HUD, WallWidget)
└── utils/                 # Helpers (constants, animations, math utilities)
```

### Key Design Principles
- **Architecture**: MVVM pattern with ChangeNotifier ViewModels for presentation logic
- **Game Engine**: Flame engine for 2D rendering, game loop, and component management  
- **Dependency Injection**: Service interfaces with IoC container for testable architecture
- **SOLID Principles**: Single responsibility, dependency inversion, interface segregation
- **Testing**: TDD approach with ViewModel unit tests, Flame component tests, integration tests

## Development Workflow

### 1. TDD Process
```bash
# Write failing test first
flutter test test/unit_test/services/resource_manager_test.dart

# Implement minimal code to pass
# Edit lib/services/resource_manager.dart

# Run tests to verify
flutter test

# Refactor and repeat
```

### 2. Running Tests
```bash
# Run all tests
flutter test

# Run specific test categories
flutter test test/unit_test/
flutter test test/widget_test/
flutter test test/integration_test/

# Run with coverage
flutter test --coverage
```

### 3. Performance Testing
```bash
# Run with performance overlay
flutter run --debug --enable-software-rendering

# Profile the app
flutter run --profile
dart devtools
```

## Game Implementation Order

### Phase 1: Basic Game Foundation (P1 - MVP)
1. **Basic UI Layout**: GameScreen with placeholder widgets
2. **Wall Implementation**: Wall model, visual representation, HP display
3. **Resource System**: Resource generation buttons, amount tracking
4. **Simple Enemy**: Basic enemy spawning and movement toward wall
5. **Core Game Loop**: Timer, basic collision detection, win/lose conditions

### Phase 2: Resource Strategy (P2)
1. **Wall Upgrades**: Blue resource spending, level progression, visual changes
2. **Healing System**: Green resource spending, HP restoration
3. **Resource Optimization**: Yellow resource upgrades, generation rate improvements
4. **Strategic UI**: Clear cost display, upgrade feedback

### Phase 3: Progressive Challenge (P3)
1. **Difficulty Scaling**: Enemy attribute scaling per level
2. **Resource Cost Scaling**: Exponential upgrade costs
3. **Advanced Enemy Behaviors**: Multiple enemy types, varied attack patterns
4. **Polish**: Animations, sound effects, improved visuals

## Key Implementation Notes

### Performance Considerations
- Use `RepaintBoundary` around game area to optimize rendering
- Implement object pooling for enemies to reduce garbage collection
- Limit concurrent enemies to ~20 for 60 FPS performance
- Use `const` constructors where possible for widget efficiency

### Testing Guidelines
- Write widget tests for all UI interactions
- Unit test all game logic calculations  
- Integration tests for complete gameplay flows
- Performance tests for 60 FPS requirement validation

### Code Quality Standards
- Follow Dart naming conventions (camelCase for variables, PascalCase for classes)
- Add comprehensive documentation for public APIs
- Use meaningful variable names that explain game concepts
- Implement defensive programming with input validation

## Common Development Commands

```bash
# Hot reload during development
r (in flutter run session)

# Hot restart for state reset  
R (in flutter run session)

# Generate test coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html

# Analyze code quality
flutter analyze

# Format code
dart format lib/ test/

# Build for testing
flutter build android --debug
flutter install
```

## Debugging Tips

### Game Performance Issues
- Use Flutter Inspector to identify expensive widgets
- Check AnimationController disposal in widget lifecycle
- Monitor memory usage during extended gameplay
- Verify 60 FPS maintenance with performance overlay

### Game Logic Issues  
- Add debug prints for resource calculations
- Use Flutter debugger breakpoints in game logic
- Validate game state consistency after each update
- Test edge cases (rapid tapping, simultaneous events)

### UI/UX Issues
- Test on various Android device sizes
- Verify touch target sizes (minimum 44dp)
- Validate accessibility with TalkBack enabled
- Check Material Design compliance

## Next Steps

1. **Start Development**: Begin with Phase 1 foundation components using TDD
2. **Read Specifications**: Review `spec.md` and `data-model.md` for detailed requirements  
3. **Study Contracts**: Understand service interfaces in `contracts/game_services.md`
4. **Set Up Testing**: Establish test environment and coverage tracking
5. **Join Team**: Connect with other developers, establish code review process

For detailed technical specifications, see:
- [Feature Specification](spec.md) - Complete game requirements
- [Data Model](data-model.md) - Entity definitions and relationships
- [Service Contracts](contracts/game_services.md) - API interfaces
- [Implementation Plan](plan.md) - Technical architecture decisions