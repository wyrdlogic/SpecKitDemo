import 'game_enums.dart';

/// Resource model representing game currency system
class Resource {
  Resource({
    required this.type,
    int amount = 0,
    double generationRate = 0.0,
    bool isGenerating = false,
    DateTime? lastGenerationTime,
  }) : _amount = amount,
       _generationRate = generationRate,
       _isGenerating = isGenerating,
       _lastGenerationTime = lastGenerationTime ?? DateTime.now() {
    _validateState();
  }

  final ResourceType type;
  int _amount;
  double _generationRate;
  bool _isGenerating;
  DateTime _lastGenerationTime;

  /// Current quantity owned
  int get amount => _amount;

  /// Resources per second generation rate
  double get generationRate => _generationRate;

  /// Active generation state
  bool get isGenerating => _isGenerating;

  /// Last generation time for calculation timing
  DateTime get lastGenerationTime => _lastGenerationTime;

  /// Whether there are enough resources to spend the given amount
  bool canAfford(int cost) {
    return _amount >= cost && cost >= 0;
  }

  /// Spend resources if affordable
  bool spend(int cost) {
    if (!canAfford(cost)) {
      return false;
    }

    _amount -= cost;
    _validateState();
    return true;
  }

  /// Add resources to the current amount
  void add(int amountToAdd) {
    if (amountToAdd < 0) {
      throw ArgumentError('Cannot add negative amount: $amountToAdd');
    }

    _amount += amountToAdd;
    _validateState();
  }

  /// Generate resources based on time elapsed since last generation
  void generateResources() {
    if (!_isGenerating || _generationRate <= 0) {
      return;
    }

    final now = DateTime.now();
    final timeElapsedSeconds =
        now.difference(_lastGenerationTime).inMilliseconds / 1000.0;

    if (timeElapsedSeconds > 0) {
      final generatedAmount = (_generationRate * timeElapsedSeconds).floor();
      if (generatedAmount > 0) {
        _amount += generatedAmount;
        _lastGenerationTime = now;
        _validateState();
      }
    }
  }

  /// Start resource generation
  void startGeneration() {
    _isGenerating = true;
    _lastGenerationTime = DateTime.now();
  }

  /// Stop resource generation
  void stopGeneration() {
    _isGenerating = false;
  }

  /// Upgrade the generation rate
  void upgradeGenerationRate(double rateIncrease) {
    if (rateIncrease < 0) {
      throw ArgumentError('Rate increase cannot be negative: $rateIncrease');
    }

    _generationRate += rateIncrease;
    _validateState();
  }

  /// Set the generation rate to a specific value
  void setGenerationRate(double newRate) {
    if (newRate < 0) {
      throw ArgumentError('Generation rate cannot be negative: $newRate');
    }

    _generationRate = newRate;
    _validateState();
  }

  /// Reset resource to initial state
  void reset() {
    _amount = 0;
    _generationRate = 0.0;
    _isGenerating = false;
    _lastGenerationTime = DateTime.now();
    _validateState();
  }

  /// Validate the resource state
  void _validateState() {
    if (_amount < 0) {
      throw StateError('Amount cannot be negative: $_amount');
    }
    if (_generationRate < 0) {
      throw StateError('Generation rate cannot be negative: $_generationRate');
    }
  }

  /// Create a copy with updated values
  Resource copyWith({
    ResourceType? type,
    int? amount,
    double? generationRate,
    bool? isGenerating,
    DateTime? lastGenerationTime,
  }) {
    return Resource(
      type: type ?? this.type,
      amount: amount ?? _amount,
      generationRate: generationRate ?? _generationRate,
      isGenerating: isGenerating ?? _isGenerating,
      lastGenerationTime: lastGenerationTime ?? _lastGenerationTime,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Resource &&
        other.type == type &&
        other._amount == _amount &&
        other._generationRate == _generationRate &&
        other._isGenerating == _isGenerating &&
        other._lastGenerationTime == _lastGenerationTime;
  }

  @override
  int get hashCode {
    return Object.hash(
      type,
      _amount,
      _generationRate,
      _isGenerating,
      _lastGenerationTime,
    );
  }

  @override
  String toString() {
    return 'Resource(type: ${type.displayName}, amount: $_amount, rate: $_generationRate/s, generating: $_isGenerating)';
  }
}
