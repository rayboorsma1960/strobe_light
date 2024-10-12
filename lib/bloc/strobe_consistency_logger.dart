import 'dart:math';

class StrobeConsistencyLogger {
  List<int> _flashIntervals = [];
  bool _isLogging = false;
  int? _lastFlashTime;
  int? _startTime;

  void startLogging() {
    _isLogging = true;
    _flashIntervals.clear();
    _lastFlashTime = null;
    _startTime = DateTime.now().millisecondsSinceEpoch;
  }

  void logFlash() {
    if (!_isLogging) return;

    final now = DateTime.now().microsecondsSinceEpoch;
    if (_lastFlashTime != null) {
      _flashIntervals.add(now - _lastFlashTime!);
    }
    _lastFlashTime = now;
  }

  Map<String, dynamic> stopLoggingAndAnalyze() {
    _isLogging = false;
    final endTime = DateTime.now().millisecondsSinceEpoch;
    final durationMs = _startTime != null ? endTime - _startTime! : 0;

    if (_flashIntervals.isEmpty) {
      return {
        'average': 0,
        'stdDev': 0,
        'minDeviation': 0,
        'maxDeviation': 0,
        'intervalCounts': <int, int>{},
        'rawIntervals': <int>[],
        'totalFlashes': 0,
        'durationMs': durationMs,
      };
    }

    final avg = _flashIntervals.reduce((a, b) => a + b) / _flashIntervals.length;
    final variance = _flashIntervals.map((t) => pow(t - avg, 2)).reduce((a, b) => a + b) / _flashIntervals.length;
    final stdDev = sqrt(variance);
    final deviations = _flashIntervals.map((t) => (t - avg).abs()).toList();

    // Create a histogram of intervals
    final intervalCounts = <int, int>{};
    for (final interval in _flashIntervals) {
      final roundedInterval = (interval / 1000).round(); // Round to nearest millisecond
      intervalCounts[roundedInterval] = (intervalCounts[roundedInterval] ?? 0) + 1;
    }

    return {
      'average': avg,
      'stdDev': stdDev,
      'minDeviation': deviations.reduce(min).toDouble(),
      'maxDeviation': deviations.reduce(max).toDouble(),
      'intervalCounts': intervalCounts,
      'rawIntervals': _flashIntervals,
      'totalFlashes': _flashIntervals.length,
      'durationMs': durationMs,
    };
  }
}