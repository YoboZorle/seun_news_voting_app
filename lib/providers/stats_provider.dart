import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../services/database_service.dart';

class StatsProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  
  late AppStatistics _stats;
  late Map<String, int> _engagementByCategory;
  late List<Post> _topPosts;

  StatsProvider() {
    _loadData();
  }

  void _loadData() {
    _stats = _db.getStatistics();
    _engagementByCategory = _db.getEngagementByCategory();
    _topPosts = _db.getTopPostsByViews(limit: 5);
  }

  AppStatistics get stats => _stats;
  Map<String, int> get engagementByCategory => _engagementByCategory;
  List<Post> get topPosts => _topPosts;

  void refresh() {
    _loadData();
    notifyListeners();
  }
}
