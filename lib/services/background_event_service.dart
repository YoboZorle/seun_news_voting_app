import 'dart:async';

class BackgroundEventService {
  static final BackgroundEventService _instance = BackgroundEventService._internal();

  factory BackgroundEventService() {
    return _instance;
  }

  BackgroundEventService._internal();

  final List<Timer> _timers = [];

  void startAllTimers() {
    // Background timers for maintenance tasks
  }

  void stopAllTimers() {
    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();
  }

  void dispose() {
    stopAllTimers();
  }
}
