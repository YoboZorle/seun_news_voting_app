import 'package:flutter/foundation.dart';
import '../models/app_models.dart';
import '../services/database_service.dart';

class StatsProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  
  Statistics? _stats;

  Statistics? get stats => _stats;

  StatsProvider() {
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      _stats = _db.getStatistics();
      notifyListeners();
    } catch (e) {
      print('⛔ Error loading stats: $e');
    }
  }

  Future<void> refreshStats() async {
    await _loadStats();
  }
}
