/// Dependency injection service locator
///
/// Simple service locator implementation following SOLID principles
/// for dependency injection without external packages in MVP.
///
/// Usage:
/// ```dart
/// // Registration
/// ServiceLocator.instance.register<IGameService>(() => GameService());
///
/// // Resolution
/// final gameService = ServiceLocator.instance.get<IGameService>();
/// ```
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  static ServiceLocator get instance => _instance;

  ServiceLocator._internal();

  final Map<Type, dynamic> _services = {};
  final Map<Type, dynamic Function()> _factories = {};

  /// Register a singleton service instance
  void registerSingleton<T>(T service) {
    _services[T] = service;
  }

  /// Register a factory function for lazy instantiation
  void registerFactory<T>(T Function() factory) {
    _factories[T] = factory;
  }

  /// Register a service with automatic singleton behavior
  void register<T>(T Function() factory) {
    _factories[T] = factory;
  }

  /// Get a service instance
  T get<T>() {
    // Check if singleton already exists
    if (_services.containsKey(T)) {
      return _services[T] as T;
    }

    // Check if factory exists
    if (_factories.containsKey(T)) {
      final instance = _factories[T]!() as T;
      // Store as singleton after first creation
      _services[T] = instance;
      return instance;
    }

    throw Exception('Service of type $T is not registered');
  }

  /// Check if a service is registered
  bool isRegistered<T>() {
    return _services.containsKey(T) || _factories.containsKey(T);
  }

  /// Clear all services (useful for testing)
  void clear() {
    _services.clear();
    _factories.clear();
  }

  /// Reset to initial state
  void reset() {
    clear();
  }
}
