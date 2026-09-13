import 'package:flutter/foundation.dart';
import '../models/app_models.dart';
import '../services/database_service.dart';

class StatsProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  Statistics? _statistics;
  List<Reform> _reforms = [];
  bool _isLoading = false;

  Statistics? get statistics => _statistics;
  List<Reform> get reforms => _reforms;
  bool get isLoading => _isLoading;

  StatsProvider() {
    _loadStats();
  }

  Future<void> _loadStats() async {
    _isLoading = true;
    notifyListeners();

    try {
      _statistics = _db.getStatistics();
      _reforms = await _db.getAllReforms();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      print('Error loading statistics: $e');
      notifyListeners();
    }
  }

  Future<void> addReform(Reform reform) async {
    try {
      await _db.addReform(reform);
      _reforms.add(reform);
      notifyListeners();
    } catch (e) {
      print('Error adding reform: $e');
    }
  }

  Future<void> updateReform(Reform reform) async {
    try {
      await _db.addReform(reform);
      final index = _reforms.indexWhere((r) => r.id == reform.id);
      if (index >= 0) {
        _reforms[index] = reform;
      }
      notifyListeners();
    } catch (e) {
      print('Error updating reform: $e');
    }
  }

  double getReformsCompletionRate() {
    if (_reforms.isEmpty) return 0.0;
    final avgProgress =
        _reforms.fold(0.0, (sum, r) => sum + r.progress) / _reforms.length;
    return avgProgress;
  }

  int getInProgressReforms() {
    return _reforms.where((r) => r.status == 'In Progress').length;
  }

  int getCompletedReforms() {
    return _reforms.where((r) => r.status == 'Completed').length;
  }

  int getPlannedReforms() {
    return _reforms.where((r) => r.status == 'Planned').length;
  }

  Future<void> refreshStats() async {
    await _loadStats();
  }
}