import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../services/database_service.dart';

class VotingProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  
  late List<PoliticalReform> _reforms;
  late List<PoliticalContestant> _contestants;

  VotingProvider() {
    _loadData();
  }

  void _loadData() {
    _reforms = List.from(_db.getAllReforms());
    _contestants = List.from(_db.getAllContestants());
  }

  List<PoliticalReform> get reforms => _reforms;
  List<PoliticalContestant> get contestants => _contestants;

  Future<void> voteReformSupport(String reformId) async {
    await _db.voteReformSupport(reformId);
    _loadData();
    notifyListeners();
  }

  Future<void> voteReformOppose(String reformId) async {
    await _db.voteReformOppose(reformId);
    _loadData();
    notifyListeners();
  }

  Future<void> voteReformNeutral(String reformId) async {
    await _db.voteReformNeutral(reformId);
    _loadData();
    notifyListeners();
  }

  Future<void> voteContestantSupport(String contestantId) async {
    await _db.voteContestantSupport(contestantId);
    _loadData();
    notifyListeners();
  }

  Future<void> voteContestantOppose(String contestantId) async {
    await _db.voteContestantOppose(contestantId);
    _loadData();
    notifyListeners();
  }

  Future<void> refreshData() async {
    _loadData();
    notifyListeners();
  }
}
