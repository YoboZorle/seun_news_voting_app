import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import '../models/app_models.dart';

final logger = Logger();

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static late SharedPreferences _prefs;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  // ✅ Initialize once in main.dart
  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    logger.i('✅ DatabaseService initialized');
  }

  // Rest of the methods stay the same...
  
  static const String _postsKey = 'posts';
  static const String _presidentialKey = 'presidential_candidates';
  static const String _governorKey = 'governor_candidates';
  static const String _lgaKey = 'lga_candidates';
  static const String _reformsKey = 'reforms';
  static const String _initKey = 'initialized';
  static const String _userVoteKey = 'user_voted_for';

  // Posts
  Future<void> addPost(Post post) async {
    final posts = getAllPosts();
    posts.add(post);
    final jsonList = posts.map((p) => jsonEncode(p.toMap())).toList();
    await _prefs.setStringList(_postsKey, jsonList);
    logger.i('✅ Post saved: ${post.title}');
  }

  List<Post> getAllPosts() {
    try {
      final jsonList = _prefs.getStringList(_postsKey) ?? [];
      return jsonList
          .map((json) => Post.fromMap(jsonDecode(json)))
          .toList();
    } catch (e) {
      logger.e('Error loading posts: $e');
      return [];
    }
  }

  // Presidential Candidates
  Future<void> addPresidentialCandidate(PresidentialCandidate candidate) async {
    final candidates = getAllPresidentialCandidates();
    candidates.removeWhere((c) => c.id == candidate.id);
    candidates.add(candidate);
    final jsonList = candidates.map((c) => jsonEncode(c.toMap())).toList();
    await _prefs.setStringList(_presidentialKey, jsonList);
    logger.i('✅ Presidential candidate saved: ${candidate.name}');
  }

  List<PresidentialCandidate> getAllPresidentialCandidates() {
    try {
      final jsonList = _prefs.getStringList(_presidentialKey) ?? [];
      return jsonList
          .map((json) => PresidentialCandidate.fromMap(jsonDecode(json)))
          .toList();
    } catch (e) {
      logger.e('Error loading presidential candidates: $e');
      return [];
    }
  }

  // Governor Candidates
  Future<void> addGovernorCandidate(GovernorCandidate candidate) async {
    final candidates = await getAllGovernorCandidates();
    candidates.removeWhere((c) => c.id == candidate.id);
    candidates.add(candidate);
    final jsonList = candidates.map((c) => jsonEncode(c.toMap())).toList();
    await _prefs.setStringList(_governorKey, jsonList);
    logger.i('✅ Governor candidate saved: ${candidate.name}');
  }

  Future<List<GovernorCandidate>> getAllGovernorCandidates() async {
    try {
      final jsonList = _prefs.getStringList(_governorKey) ?? [];
      return jsonList
          .map((json) => GovernorCandidate.fromMap(jsonDecode(json)))
          .toList();
    } catch (e) {
      logger.e('Error loading governor candidates: $e');
      return [];
    }
  }

  // LGA Candidates
  Future<void> addLGACandidate(LGACandidate candidate) async {
    final candidates = await getAllLGACandidates();
    candidates.removeWhere((c) => c.id == candidate.id);
    candidates.add(candidate);
    final jsonList = candidates.map((c) => jsonEncode(c.toMap())).toList();
    await _prefs.setStringList(_lgaKey, jsonList);
    logger.i('✅ LGA candidate saved: ${candidate.name}');
  }

  Future<List<LGACandidate>> getAllLGACandidates() async {
    try {
      final jsonList = _prefs.getStringList(_lgaKey) ?? [];
      return jsonList
          .map((json) => LGACandidate.fromMap(jsonDecode(json)))
          .toList();
    } catch (e) {
      logger.e('Error loading LGA candidates: $e');
      return [];
    }
  }

  // Reforms
  Future<void> addReform(Reform reform) async {
    final reforms = await getAllReforms();
    reforms.removeWhere((r) => r.id == reform.id);
    reforms.add(reform);
    final jsonList = reforms.map((r) => jsonEncode(r.toMap())).toList();
    await _prefs.setStringList(_reformsKey, jsonList);
    logger.i('✅ Reform saved: ${reform.title}');
  }

  Future<List<Reform>> getAllReforms() async {
    try {
      final jsonList = _prefs.getStringList(_reformsKey) ?? [];
      return jsonList
          .map((json) => Reform.fromMap(jsonDecode(json)))
          .toList();
    } catch (e) {
      logger.e('Error loading reforms: $e');
      return [];
    }
  }

  // Initialization Status
  Future<bool> getInitializationStatus() async {
    return _prefs.getBool(_initKey) ?? false;
  }

  Future<void> markInitialized() async {
    await _prefs.setBool(_initKey, true);
    logger.i('✅ App marked as initialized');
  }

  // User Vote Tracking
  Future<void> setUserVote(String candidateName) async {
    await _prefs.setString(_userVoteKey, candidateName);
    logger.i('✅ User vote saved: $candidateName');
  }

  String? getUserVote() {
    try {
      return _prefs.getString(_userVoteKey);
    } catch (e) {
      return null;
    }
  }

  // Clear all data
  Future<void> clearAllData() async {
    await _prefs.clear();
    logger.i('✅ All data cleared');
  }

  // Get statistics
  Statistics getStatistics() {
    final posts = getAllPosts();
    final totalViews = posts.fold(0, (sum, p) => sum + p.viewCount);
    final totalEngagements = posts.fold(0, (sum, p) => sum + p.likes + p.dislikes);
    
    return Statistics(
      totalPosts: posts.length,
      totalViews: totalViews,
      totalVotes: getAllPresidentialCandidates().fold(0, (sum, c) => sum + c.votes),
      totalEngagements: totalEngagements,
    );
  }
}
