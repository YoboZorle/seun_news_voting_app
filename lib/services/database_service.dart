import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/app_models.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  late SharedPreferences _prefs;
  final logger = Logger();

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    logger.i('✅ DatabaseService initialized');
  }

  // POSTS
  Future<void> addPost(Post post) async {
    try {
      final posts = getAllPosts();
      posts.add(post);
      await _prefs.setString('posts', jsonEncode(posts.map((p) => p.toJson()).toList()));
      _updateStatistics();
    } catch (e) {
      logger.e('Error adding post: $e');
    }
  }

  List<Post> getAllPosts() {
    try {
      final json = _prefs.getString('posts');
      if (json == null) return [];
      final list = jsonDecode(json) as List;
      return list.map((p) => Post.fromJson(p)).toList();
    } catch (e) {
      logger.e('Error getting posts: $e');
      return [];
    }
  }

  List<Post> getPostsByCategory(String category) {
    return getAllPosts().where((p) => p.category == category).toList();
  }

  Post? getPost(String postId) {
    try {
      return getAllPosts().firstWhere((p) => p.id == postId);
    } catch (e) {
      return null;
    }
  }

  Future<void> incrementViewCount(String postId) async {
    try {
      final posts = getAllPosts();
      final index = posts.indexWhere((p) => p.id == postId);
      if (index >= 0) {
        posts[index].viewCount++;
        await _prefs.setString('posts', jsonEncode(posts.map((p) => p.toJson()).toList()));
        _updateStatistics();
      }
    } catch (e) {
      logger.e('Error incrementing view: $e');
    }
  }

  Future<void> likePost(String postId) async {
    try {
      final posts = getAllPosts();
      final index = posts.indexWhere((p) => p.id == postId);
      if (index >= 0) {
        posts[index].likes++;
        await _prefs.setString('posts', jsonEncode(posts.map((p) => p.toJson()).toList()));
        _updateStatistics();
      }
    } catch (e) {
      logger.e('Error liking post: $e');
    }
  }

  Future<void> dislikePost(String postId) async {
    try {
      final posts = getAllPosts();
      final index = posts.indexWhere((p) => p.id == postId);
      if (index >= 0) {
        posts[index].dislikes++;
        await _prefs.setString('posts', jsonEncode(posts.map((p) => p.toJson()).toList()));
        _updateStatistics();
      }
    } catch (e) {
      logger.e('Error disliking post: $e');
    }
  }

  // REFORMS
  Future<void> addReform(PoliticalReform reform) async {
    try {
      final reforms = getAllReforms();
      reforms.add(reform);
      await _prefs.setString('reforms', jsonEncode(reforms.map((r) => r.toJson()).toList()));
      _updateStatistics();
    } catch (e) {
      logger.e('Error adding reform: $e');
    }
  }

  List<PoliticalReform> getAllReforms() {
    try {
      final json = _prefs.getString('reforms');
      if (json == null) return [];
      final list = jsonDecode(json) as List;
      return list.map((r) => PoliticalReform.fromJson(r)).toList();
    } catch (e) {
      logger.e('Error getting reforms: $e');
      return [];
    }
  }

  Future<void> voteReformSupport(String reformId) async {
    try {
      final reforms = getAllReforms();
      final index = reforms.indexWhere((r) => r.id == reformId);
      if (index >= 0) {
        reforms[index].supportVotes++;
        await _prefs.setString('reforms', jsonEncode(reforms.map((r) => r.toJson()).toList()));
        _updateStatistics();
      }
    } catch (e) {
      logger.e('Error voting reform support: $e');
    }
  }

  Future<void> voteReformOppose(String reformId) async {
    try {
      final reforms = getAllReforms();
      final index = reforms.indexWhere((r) => r.id == reformId);
      if (index >= 0) {
        reforms[index].opposeVotes++;
        await _prefs.setString('reforms', jsonEncode(reforms.map((r) => r.toJson()).toList()));
        _updateStatistics();
      }
    } catch (e) {
      logger.e('Error voting reform oppose: $e');
    }
  }

  Future<void> voteReformNeutral(String reformId) async {
    try {
      final reforms = getAllReforms();
      final index = reforms.indexWhere((r) => r.id == reformId);
      if (index >= 0) {
        reforms[index].neutralVotes++;
        await _prefs.setString('reforms', jsonEncode(reforms.map((r) => r.toJson()).toList()));
        _updateStatistics();
      }
    } catch (e) {
      logger.e('Error voting reform neutral: $e');
    }
  }

  // PRESIDENTIAL ELECTIONS
  Future<void> addPresidentialCandidate(PresidentialCandidate candidate) async {
    try {
      final candidates = getAllPresidentialCandidates();
      candidates.add(candidate);
      await _prefs.setString('presidential', jsonEncode(candidates.map((c) => c.toJson()).toList()));
      _updateStatistics();
    } catch (e) {
      logger.e('Error adding presidential candidate: $e');
    }
  }

  List<PresidentialCandidate> getAllPresidentialCandidates() {
    try {
      final json = _prefs.getString('presidential');
      if (json == null) return [];
      final list = jsonDecode(json) as List;
      return list.map((c) => PresidentialCandidate.fromJson(c)).toList();
    } catch (e) {
      logger.e('Error getting presidential candidates: $e');
      return [];
    }
  }

  Future<void> votePresidential(String candidateId) async {
    try {
      final candidates = getAllPresidentialCandidates();
      final index = candidates.indexWhere((c) => c.id == candidateId);
      if (index >= 0) {
        candidates[index].votes++;
        await _prefs.setString('presidential', jsonEncode(candidates.map((c) => c.toJson()).toList()));
        _updateStatistics();
      }
    } catch (e) {
      logger.e('Error voting presidential: $e');
    }
  }

  // GOVERNOR ELECTIONS
  Future<void> addGovernorCandidate(GovernorCandidate candidate) async {
    try {
      final candidates = getAllGovernorCandidates();
      candidates.add(candidate);
      await _prefs.setString('governors', jsonEncode(candidates.map((c) => c.toJson()).toList()));
      _updateStatistics();
    } catch (e) {
      logger.e('Error adding governor candidate: $e');
    }
  }

  List<GovernorCandidate> getAllGovernorCandidates() {
    try {
      final json = _prefs.getString('governors');
      if (json == null) return [];
      final list = jsonDecode(json) as List;
      return list.map((c) => GovernorCandidate.fromJson(c)).toList();
    } catch (e) {
      logger.e('Error getting governor candidates: $e');
      return [];
    }
  }

  List<GovernorCandidate> getGovernorsByState(String state) {
    return getAllGovernorCandidates().where((g) => g.state == state).toList();
  }

  Future<void> voteGovernor(String candidateId) async {
    try {
      final candidates = getAllGovernorCandidates();
      final index = candidates.indexWhere((c) => c.id == candidateId);
      if (index >= 0) {
        candidates[index].votes++;
        await _prefs.setString('governors', jsonEncode(candidates.map((c) => c.toJson()).toList()));
        _updateStatistics();
      }
    } catch (e) {
      logger.e('Error voting governor: $e');
    }
  }

  // LGA ELECTIONS
  Future<void> addLGACandidate(LGACandidate candidate) async {
    try {
      final candidates = getAllLGACandidates();
      candidates.add(candidate);
      await _prefs.setString('lga', jsonEncode(candidates.map((c) => c.toJson()).toList()));
      _updateStatistics();
    } catch (e) {
      logger.e('Error adding LGA candidate: $e');
    }
  }

  List<LGACandidate> getAllLGACandidates() {
    try {
      final json = _prefs.getString('lga');
      if (json == null) return [];
      final list = jsonDecode(json) as List;
      return list.map((c) => LGACandidate.fromJson(c)).toList();
    } catch (e) {
      logger.e('Error getting LGA candidates: $e');
      return [];
    }
  }

  List<LGACandidate> getLGACandidatesByStateAndLGA(String state, String lga) {
    return getAllLGACandidates().where((c) => c.state == state && c.lga == lga).toList();
  }

  List<String> getLGAsByState(String state) {
    return getAllLGACandidates()
        .where((c) => c.state == state)
        .map((c) => c.lga)
        .toSet()
        .toList();
  }

  Future<void> voteLGA(String candidateId) async {
    try {
      final candidates = getAllLGACandidates();
      final index = candidates.indexWhere((c) => c.id == candidateId);
      if (index >= 0) {
        candidates[index].votes++;
        await _prefs.setString('lga', jsonEncode(candidates.map((c) => c.toJson()).toList()));
        _updateStatistics();
      }
    } catch (e) {
      logger.e('Error voting LGA: $e');
    }
  }

  // STATISTICS
  AppStatistics getStatistics() {
    try {
      final json = _prefs.getString('statistics');
      if (json == null) return AppStatistics();
      return AppStatistics.fromJson(jsonDecode(json));
    } catch (e) {
      logger.e('Error getting statistics: $e');
      return AppStatistics();
    }
  }

  void _updateStatistics() {
    try {
      final stats = AppStatistics(
        totalPosts: getAllPosts().length,
        totalViews: getAllPosts().fold<int>(0, (sum, p) => sum + p.viewCount),
        totalVotes: getAllPosts().fold<int>(0, (sum, p) => sum + p.likes + p.dislikes),
        totalEngagements: getAllPosts().fold<int>(0, (sum, p) => sum + p.engagement),
        totalReformVotes: getAllReforms().fold<int>(0, (sum, r) => sum + r.totalVotes),
        totalElectionVotes: getAllPresidentialCandidates().fold<int>(0, (sum, c) => sum + c.votes) +
            getAllGovernorCandidates().fold<int>(0, (sum, c) => sum + c.votes) +
            getAllLGACandidates().fold<int>(0, (sum, c) => sum + c.votes),
      );
      _prefs.setString('statistics', jsonEncode(stats.toJson()));
    } catch (e) {
      logger.e('Error updating statistics: $e');
    }
  }

  Map<String, int> getEngagementByCategory() {
    try {
      final posts = getAllPosts();
      final Map<String, int> engagement = {};
      for (var post in posts) {
        engagement[post.category] = (engagement[post.category] ?? 0) + post.engagement;
      }
      return engagement;
    } catch (e) {
      logger.e('Error getting engagement: $e');
      return {};
    }
  }

  List<Post> getTopPostsByViews({int limit = 5}) {
    final posts = getAllPosts();
    posts.sort((a, b) => b.viewCount.compareTo(a.viewCount));
    return posts.take(limit).toList();
  }

  Future<void> clearAllData() async {
    try {
      await _prefs.clear();
      logger.i('✅ All data cleared');
    } catch (e) {
      logger.e('Error clearing data: $e');
    }
  }
}
