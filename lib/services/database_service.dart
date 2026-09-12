import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_models.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static final logger = Logger();
  late SharedPreferences _prefs;

  final List<Post> _posts = [];
  final List<Vote> _votes = [];
  final List<PoliticalReform> _reforms = [];
  final List<PoliticalContestant> _contestants = [];
  late AppStatistics _stats;

  DatabaseService._internal();

  factory DatabaseService() => _instance;

  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _loadAllData();
      logger.i('✅ Database initialized');
    } catch (e) {
      logger.e('❌ Database init error: $e');
      rethrow;
    }
  }

  void _loadAllData() {
    try {
      final postsJson = _prefs.getString('posts');
      if (postsJson != null) {
        final List<dynamic> decoded = jsonDecode(postsJson);
        _posts.clear();
        _posts.addAll(decoded.map((p) => Post.fromJson(p as Map<String, dynamic>)));
      }

      final votesJson = _prefs.getString('votes');
      if (votesJson != null) {
        final List<dynamic> decoded = jsonDecode(votesJson);
        _votes.clear();
        _votes.addAll(decoded.map((v) => Vote.fromJson(v as Map<String, dynamic>)));
      }

      final reformsJson = _prefs.getString('reforms');
      if (reformsJson != null) {
        final List<dynamic> decoded = jsonDecode(reformsJson);
        _reforms.clear();
        _reforms.addAll(decoded.map((r) => PoliticalReform.fromJson(r as Map<String, dynamic>)));
      }

      final contestantsJson = _prefs.getString('contestants');
      if (contestantsJson != null) {
        final List<dynamic> decoded = jsonDecode(contestantsJson);
        _contestants.clear();
        _contestants.addAll(decoded.map((c) => PoliticalContestant.fromJson(c as Map<String, dynamic>)));
      }

      final statsJson = _prefs.getString('statistics');
      _stats = statsJson != null
          ? AppStatistics.fromJson(jsonDecode(statsJson) as Map<String, dynamic>)
          : AppStatistics();

      logger.d('✅ All data loaded');
    } catch (e) {
      logger.e('Error loading data: $e');
      _stats = AppStatistics();
    }
  }

  Future<void> _saveAllData() async {
    try {
      await _prefs.setString('posts', jsonEncode(_posts.map((p) => p.toJson()).toList()));
      await _prefs.setString('votes', jsonEncode(_votes.map((v) => v.toJson()).toList()));
      await _prefs.setString('reforms', jsonEncode(_reforms.map((r) => r.toJson()).toList()));
      await _prefs.setString('contestants', jsonEncode(_contestants.map((c) => c.toJson()).toList()));
      await _prefs.setString('statistics', jsonEncode(_stats.toJson()));
    } catch (e) {
      logger.e('Error saving data: $e');
    }
  }

  // POSTS
  Future<void> addPost(Post post) async {
    _posts.add(post);
    await _saveAllData();
    await _updateStatistics();
  }

  List<Post> getAllPosts() => List.from(_posts);

  List<Post> getPostsByCategory(String category) {
    return _posts.where((post) => post.category.toLowerCase() == category.toLowerCase()).toList();
  }

  Post? getPost(String id) {
    try {
      return _posts.firstWhere((post) => post.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> updatePost(Post post) async {
    final index = _posts.indexWhere((p) => p.id == post.id);
    if (index != -1) {
      _posts[index] = post;
    }
    await _saveAllData();
    await _updateStatistics();
  }

  Future<void> incrementViewCount(String postId) async {
    final post = getPost(postId);
    if (post != null) {
      post.viewCount++;
      await updatePost(post);
    }
  }

  // VOTES
  Future<void> likePost(String postId) async {
    final post = getPost(postId);
    if (post != null) {
      final existingVoteIndex = _votes.indexWhere((v) => v.postId == postId);
      if (existingVoteIndex != -1) {
        final existingVote = _votes[existingVoteIndex];
        if (existingVote.isLike) post.likes--;
        else post.dislikes--;
        _votes.removeAt(existingVoteIndex);
      }
      post.likes++;
      _votes.add(Vote(
        id: '${postId}_like_${DateTime.now().millisecondsSinceEpoch}',
        postId: postId,
        isLike: true,
        timestamp: DateTime.now(),
      ));
      await _saveAllData();
      await _updateStatistics();
    }
  }

  Future<void> dislikePost(String postId) async {
    final post = getPost(postId);
    if (post != null) {
      final existingVoteIndex = _votes.indexWhere((v) => v.postId == postId);
      if (existingVoteIndex != -1) {
        final existingVote = _votes[existingVoteIndex];
        if (existingVote.isLike) post.likes--;
        else post.dislikes--;
        _votes.removeAt(existingVoteIndex);
      }
      post.dislikes++;
      _votes.add(Vote(
        id: '${postId}_dislike_${DateTime.now().millisecondsSinceEpoch}',
        postId: postId,
        isLike: false,
        timestamp: DateTime.now(),
      ));
      await _saveAllData();
      await _updateStatistics();
    }
  }

  // REFORMS
  Future<void> addReform(PoliticalReform reform) async {
    _reforms.add(reform);
    await _saveAllData();
    await _updateStatistics();
  }

  List<PoliticalReform> getAllReforms() => List.from(_reforms);

  Future<void> voteReformSupport(String reformId) async {
    final idx = _reforms.indexWhere((r) => r.id == reformId);
    if (idx != -1) {
      _reforms[idx].supportVotes++;
      await _saveAllData();
      await _updateStatistics();
    }
  }

  Future<void> voteReformOppose(String reformId) async {
    final idx = _reforms.indexWhere((r) => r.id == reformId);
    if (idx != -1) {
      _reforms[idx].opposeVotes++;
      await _saveAllData();
      await _updateStatistics();
    }
  }

  Future<void> voteReformNeutral(String reformId) async {
    final idx = _reforms.indexWhere((r) => r.id == reformId);
    if (idx != -1) {
      _reforms[idx].neutralVotes++;
      await _saveAllData();
      await _updateStatistics();
    }
  }

  // CONTESTANTS
  Future<void> addContestant(PoliticalContestant contestant) async {
    _contestants.add(contestant);
    await _saveAllData();
    await _updateStatistics();
  }

  List<PoliticalContestant> getAllContestants() => List.from(_contestants);

  Future<void> voteContestantSupport(String contestantId) async {
    final idx = _contestants.indexWhere((c) => c.id == contestantId);
    if (idx != -1) {
      _contestants[idx].supportVotes++;
      await _saveAllData();
      await _updateStatistics();
    }
  }

  Future<void> voteContestantOppose(String contestantId) async {
    final idx = _contestants.indexWhere((c) => c.id == contestantId);
    if (idx != -1) {
      _contestants[idx].opposeVotes++;
      await _saveAllData();
      await _updateStatistics();
    }
  }

  // STATISTICS
  Future<void> _updateStatistics() async {
    _stats = AppStatistics(
      totalPosts: _posts.length,
      totalViews: _posts.fold<int>(0, (sum, post) => sum + post.viewCount),
      totalVotes: _votes.length,
      totalEngagements: _posts.fold<int>(0, (sum, post) => sum + post.engagement),
      totalReformVotes: _reforms.fold<int>(0, (sum, r) => sum + r.totalVotes),
      totalContestantVotes: _contestants.fold<int>(0, (sum, c) => sum + c.totalVotes),
      lastUpdated: DateTime.now(),
    );
    await _saveAllData();
  }

  AppStatistics getStatistics() => _stats;

  // UTILITIES
  Future<void> clearAllData() async {
    _posts.clear();
    _votes.clear();
    _reforms.clear();
    _contestants.clear();
    _stats = AppStatistics();
    await _prefs.clear();
    logger.i('✅ All data cleared');
  }

  int getTotalEngagement() => _posts.fold<int>(0, (sum, post) => sum + post.engagement);

  Map<String, int> getEngagementByCategory() {
    final map = <String, int>{};
    for (final post in _posts) {
      map[post.category] = (map[post.category] ?? 0) + post.engagement;
    }
    return map;
  }

  List<Post> getTopPostsByViews({int limit = 5}) {
    final sorted = List<Post>.from(_posts)..sort((a, b) => b.viewCount.compareTo(a.viewCount));
    return sorted.take(limit).toList();
  }
}
