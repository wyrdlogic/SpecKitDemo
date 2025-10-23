import 'package:flutter/foundation.dart';
import '../core/service_locator.dart';

/// Base ViewModel class implementing MVVM pattern with ChangeNotifier
///
/// Provides common functionality for all ViewModels including:
/// - Service locator access
/// - Loading state management
/// - Error handling
/// - Disposal lifecycle
/// - Debug support
abstract base class BaseViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool _isDisposed = false;
  String? _errorMessage;

  /// Whether the ViewModel is currently in a loading state
  bool get isLoading => _isLoading;

  /// Current error message, if any
  String? get errorMessage => _errorMessage;

  /// Whether there is currently an error
  bool get hasError => _errorMessage != null;

  /// Whether the ViewModel has been disposed
  bool get isDisposed => _isDisposed;

  /// Service locator for dependency injection
  ServiceLocator get services => ServiceLocator.instance;

  /// Set loading state and notify listeners
  @protected
  void setLoading(bool loading) {
    if (_isDisposed || _isLoading == loading) return;

    _isLoading = loading;
    notifyListeners();
  }

  /// Set error message and notify listeners
  @protected
  void setError(String? error) {
    if (_isDisposed || _errorMessage == error) return;

    _errorMessage = error;
    notifyListeners();
  }

  /// Clear any current error
  @protected
  void clearError() {
    setError(null);
  }

  /// Execute an async operation with loading state management
  @protected
  Future<T> executeAsync<T>(
    Future<T> Function() operation, {
    String? errorContext,
  }) async {
    if (_isDisposed) {
      throw StateError('ViewModel has been disposed');
    }

    try {
      setLoading(true);
      clearError();

      final result = await operation();

      if (!_isDisposed) {
        setLoading(false);
      }

      return result;
    } catch (error, stackTrace) {
      if (!_isDisposed) {
        setLoading(false);

        final errorMsg = errorContext != null
            ? '$errorContext: ${error.toString()}'
            : error.toString();

        setError(errorMsg);

        // Log error in debug mode
        if (kDebugMode) {
          debugPrint('ViewModel Error ($runtimeType): $errorMsg');
          debugPrint('Stack trace: $stackTrace');
        }
      }

      rethrow;
    }
  }

  /// Execute a synchronous operation with error handling
  @protected
  T executeSync<T>(T Function() operation, {String? errorContext}) {
    if (_isDisposed) {
      throw StateError('ViewModel has been disposed');
    }

    try {
      clearError();
      return operation();
    } catch (error, stackTrace) {
      if (!_isDisposed) {
        final errorMsg = errorContext != null
            ? '$errorContext: ${error.toString()}'
            : error.toString();

        setError(errorMsg);

        // Log error in debug mode
        if (kDebugMode) {
          debugPrint('ViewModel Error ($runtimeType): $errorMsg');
          debugPrint('Stack trace: $stackTrace');
        }
      }

      rethrow;
    }
  }

  /// Safely notify listeners (checks if disposed)
  @protected
  void safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  /// Initialize the ViewModel (override in subclasses)
  @protected
  @mustCallSuper
  void initialize() {
    if (kDebugMode) {
      debugPrint('ViewModel initialized: $runtimeType');
    }
  }

  /// Cleanup resources when ViewModel is no longer needed
  @override
  @mustCallSuper
  void dispose() {
    if (_isDisposed) return;

    if (kDebugMode) {
      debugPrint('ViewModel disposed: $runtimeType');
    }

    _isDisposed = true;
    super.dispose();
  }

  /// Reset the ViewModel to initial state
  @protected
  @mustCallSuper
  void reset() {
    if (_isDisposed) return;

    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// Validate that the ViewModel is not disposed before operations
  @protected
  void checkNotDisposed() {
    if (_isDisposed) {
      throw StateError('Cannot perform operation: ViewModel has been disposed');
    }
  }

  /// Get a service from the service locator with type safety
  @protected
  T getService<T>() {
    checkNotDisposed();
    return services.get<T>();
  }

  /// Safely get a service, returns null if not registered
  @protected
  T? tryGetService<T>() {
    checkNotDisposed();
    try {
      return services.get<T>();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Service not found: $T');
      }
      return null;
    }
  }

  @override
  String toString() {
    return '$runtimeType(loading: $_isLoading, hasError: $hasError, disposed: $_isDisposed)';
  }
}
