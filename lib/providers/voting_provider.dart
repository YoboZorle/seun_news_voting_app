import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../services/database_service.dart';

class VotingProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();

  List<PoliticalReform> get reforms => _db.getAllReforms();
  List<PoliticalContestant> get contestants => _db.getAllContestants();

  Future<void> voteReformSupport(String reformId) async {
    await _db.voteReformSupport(reformId);
    notifyListeners();
  }

  Future<void> voteReformOppose(String reformId) async {
    await _db.voteReformOppose(reformId);
    notifyListeners();
  }

  Future<void> voteReformNeutral(String reformId) async {
    await _db.voteReformNeutral(reformId);
    notifyListeners();
  }

  Future<void> voteContestantSupport(String contestantId) async {
    await _db.voteContestantSupport(contestantId);
    notifyListeners();
  }

  Future<void> voteContestantOppose(String contestantId) async {
    await _db.voteContestantOppose(contestantId);
    notifyListeners();
  }
}
