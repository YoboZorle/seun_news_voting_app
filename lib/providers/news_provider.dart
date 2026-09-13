import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../services/real_time_news_service.dart';

class NewsProvider extends ChangeNotifier {
  final RealTimeNewsService _newsService = RealTimeNewsService();
  final List<News> _allNews = [];
  final Map<String, List<News>> _newsByCategory = {
    'politics': [],
    'finance': [],
    'tech': [],
    'entertainment': [],
    'sports': [],
    'health': [],
  };

  NewsProvider() {
    _setupNewsStream();
  }

  // Getters
  List<News> getAllNews() => _allNews.toList();
  
  List<News> getCategoryNews(String category) {
    return _newsByCategory[category] ?? [];
  }

  // Setup news stream
  void _setupNewsStream() {
    _newsService.newsStream.listen((news) {
      // Add to all news (max 50)
      _allNews.insert(0, news);
      if (_allNews.length > 50) {
        _allNews.removeLast();
      }

      // Add to category
      final categoryList = _newsByCategory[news.category] ?? [];
      categoryList.insert(0, news);
      if (categoryList.length > 30) {
        categoryList.removeLast();
      }
      _newsByCategory[news.category] = categoryList;

      notifyListeners();
    });
  }

  // Like news
  Future<void> likeNews(String newsId) async {
    try {
      // Find news
      final index = _allNews.indexWhere((n) => n.id == newsId);
      if (index != -1) {
        _allNews[index] = _allNews[index].copyWith(
          likes: _allNews[index].likes + 1,
        );
        notifyListeners();
      }
    } catch (e) {
      print('Error liking news: $e');
    }
  }

  // Dislike news
  Future<void> dislikeNews(String newsId) async {
    try {
      final index = _allNews.indexWhere((n) => n.id == newsId);
      if (index != -1) {
        _allNews[index] = _allNews[index].copyWith(
          dislikes: _allNews[index].dislikes + 1,
        );
        notifyListeners();
      }
    } catch (e) {
      print('Error disliking news: $e');
    }
  }

  // Share news
  Future<void> shareNews(String newsId) async {
    try {
      final index = _allNews.indexWhere((n) => n.id == newsId);
      if (index != -1) {
        _allNews[index] = _allNews[index].copyWith(
          shares: _allNews[index].shares + 1,
        );
        notifyListeners();
      }
    } catch (e) {
      print('Error sharing news: $e');
    }
  }

  // Refresh news
  Future<void> refreshNews() async {
    // News updates automatically via stream
    notifyListeners();
  }

  @override
  void dispose() {
    _newsService.dispose();
    super.dispose();
  }
}
