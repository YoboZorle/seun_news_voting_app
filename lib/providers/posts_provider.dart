import 'package:flutter/foundation.dart';
import '../models/app_models.dart';
import '../services/database_service.dart';

class PostsProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  List<Post> _posts = [];
  bool _isLoading = false;

  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;

  PostsProvider() {
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _posts = _db.getAllPosts();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addPost(Post post) async {
    try {
      await _db.addPost(post);
      _posts.add(post);
      notifyListeners();
    } catch (e) {
      print('Error adding post: $e');
    }
  }

  List<Post> getPostsByCategory(String category) {
    return _posts.where((p) => p.category == category).toList();
  }

  Post? getPostById(String id) {
    try {
      return _posts.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> updatePost(Post post) async {
    try {
      final index = _posts.indexWhere((p) => p.id == post.id);
      if (index >= 0) {
        _posts[index] = post;
        await _db.addPost(post);
        notifyListeners();
      }
    } catch (e) {
      print('Error updating post: $e');
    }
  }

  List<String> get categories {
    final cats = _posts.map((p) => p.category).toSet().toList();
    return cats..sort();
  }
}