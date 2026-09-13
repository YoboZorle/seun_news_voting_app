import 'package:flutter/foundation.dart';
import '../models/app_models.dart';
import '../services/database_service.dart';

class PostsProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  
  List<Post> _posts = [];

  List<Post> get posts => _posts;

  PostsProvider() {
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    try {
      _posts = _db.getAllPosts();
      notifyListeners();
    } catch (e) {
      print('⛔ Error loading posts: $e');
    }
  }

  Future<void> refreshPosts() async {
    await _loadPosts();
  }

  void likePost(String postId) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index >= 0) {
      _posts[index].likes++;
      _db.addPost(_posts[index]);
      notifyListeners();
    }
  }

  void dislikePost(String postId) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index >= 0) {
      _posts[index].dislikes++;
      _db.addPost(_posts[index]);
      notifyListeners();
    }
  }

  void viewPost(String postId) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index >= 0) {
      _posts[index].viewCount++;
      _db.addPost(_posts[index]);
      notifyListeners();
    }
  }
}
