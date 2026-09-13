import 'package:flutter/material.dart';

class StatsProvider extends ChangeNotifier {
  Map<String, dynamic> _stats = {};

  StatsProvider() {
    _initializeStats();
  }

  Map<String, dynamic> get stats => _stats;

  void _initializeStats() {
    _stats = {
      'totalVotes': 0,
      'totalUsers': 0,
    };
  }

  Future<void> refreshStats() async {
    _initializeStats();
    notifyListeners();
  }
}
