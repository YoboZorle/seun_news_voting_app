import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/app_models.dart';

class DatabaseService {
  static late SharedPreferences _prefs;

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ============================================================
  // VOTE STATE PERSISTENCE
  // ============================================================

  static Future<UserVoteState> getUserVoteState() async {
    try {
      final json = _prefs.getString('user_vote_state');
      if (json == null) {
        return UserVoteState();
      }
      return UserVoteState.fromMap(jsonDecode(json));
    } catch (e) {
      print('Error loading user vote state: $e');
      return UserVoteState();
    }
  }

  static Future<void> saveUserVoteState(UserVoteState state) async {
    try {
      final json = jsonEncode(state.toMap());
      await _prefs.setString('user_vote_state', json);
    } catch (e) {
      print('Error saving user vote state: $e');
    }
  }

  static Future<void> clearUserVoteState() async {
    try {
      await _prefs.remove('user_vote_state');
    } catch (e) {
      print('Error clearing user vote state: $e');
    }
  }

  static Future<bool> hasUserVotedPresidential() async {
    try {
      final state = await getUserVoteState();
      return state.hasVotedPresidential;
    } catch (e) {
      return false;
    }
  }

  static Future<String?> getUserPresidentialVote() async {
    try {
      final state = await getUserVoteState();
      return state.votedPresidentialId;
    } catch (e) {
      return null;
    }
  }

  static Future<DateTime?> getUserLastVoteTime() async {
    try {
      final state = await getUserVoteState();
      return state.lastVoteTime;
    } catch (e) {
      return null;
    }
  }

  // ============================================================
  // GENERIC KEY-VALUE STORAGE
  // ============================================================

  static Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  static String? getString(String key) {
    return _prefs.getString(key);
  }

  static Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  static int? getInt(String key) {
    return _prefs.getInt(key);
  }

  static Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  static bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  static Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  static Future<void> clear() async {
    await _prefs.clear();
  }
}
