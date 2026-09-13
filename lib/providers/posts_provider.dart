import 'package:flutter/material.dart';
import '../models/app_models.dart';

class PostsProvider extends ChangeNotifier {
  List<Post> _posts = [];

  PostsProvider() {
    _initializePosts();
  }

  List<Post> get posts => _posts;

  void _initializePosts() {
    _posts = [];
  }

  Future<void> refreshPosts() async {
    _initializePosts();
    notifyListeners();
  }

  void viewPost(String postId) {
    // Handle post view
  }
}
