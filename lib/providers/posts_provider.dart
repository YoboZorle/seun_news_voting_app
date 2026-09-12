import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../services/database_service.dart';

class PostsProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  
  List<Post> _posts = [];
  String _selectedCategory = 'Politics';
  bool _isLoading = false;

  List<Post> get posts => _getFilteredPosts();
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;

  PostsProvider() {
    loadPosts();
  }

  void loadPosts() {
    _isLoading = true;
    notifyListeners();
    
    _posts = _db.getAllPosts();
    
    _isLoading = false;
    notifyListeners();
  }

  List<Post> _getFilteredPosts() {
    if (_selectedCategory == 'All') return List.from(_posts);
    return _posts.where((p) => p.category == _selectedCategory).toList();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> incrementView(String postId) async {
    await _db.incrementViewCount(postId);
    loadPosts();
  }

  Future<void> likePost(String postId) async {
    await _db.likePost(postId);
    loadPosts();
  }

  Future<void> dislikePost(String postId) async {
    await _db.dislikePost(postId);
    loadPosts();
  }

  List<Post> getAllPosts() => List.from(_posts);

  List<Post> getTopPosts({int limit = 5}) {
    return _db.getTopPostsByViews(limit: limit);
  }
}
