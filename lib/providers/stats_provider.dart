import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../services/database_service.dart';

class StatsProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();

  AppStatistics get stats => _db.getStatistics();
  
  Map<String, int> get engagementByCategory => _db.getEngagementByCategory();
  
  List<Post> get topPosts => _db.getTopPostsByViews(limit: 5);

  void refresh() {
    notifyListeners();
  }
}
