import 'package:flutter/foundation.dart';
import '../models/app_models.dart';
import '../services/database_service.dart';

class VotingProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  List<PresidentialCandidate> _presidentialCandidates = [];
  List<GovernorCandidate> _governorCandidates = [];
  List<LGACandidate> _lgaCandidates = [];
  String? _userVote;

  List<PresidentialCandidate> get presidentialCandidates =>
      _presidentialCandidates;
  List<GovernorCandidate> get governorCandidates => _governorCandidates;
  List<LGACandidate> get lgaCandidates => _lgaCandidates;
  String? get userVote => _userVote;

  VotingProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      _presidentialCandidates = _db.getAllPresidentialCandidates();
      _governorCandidates = await _db.getAllGovernorCandidates();
      _lgaCandidates = await _db.getAllLGACandidates();
      _userVote = _db.getUserVote();
      notifyListeners();
    } catch (e) {
      print('Error loading voting data: $e');
    }
  }

  Future<void> castVote(String candidateName) async {
    if (_userVote != null) return;

    try {
      await _db.setUserVote(candidateName);
      _userVote = candidateName;
      notifyListeners();
    } catch (e) {
      print('Error casting vote: $e');
    }
  }

  Future<void> updatePresidentialCandidate(PresidentialCandidate candidate) async {
    try {
      await _db.addPresidentialCandidate(candidate);
      final index = _presidentialCandidates.indexWhere((c) => c.id == candidate.id);
      if (index >= 0) {
        _presidentialCandidates[index] = candidate;
      } else {
        _presidentialCandidates.add(candidate);
      }
      notifyListeners();
    } catch (e) {
      print('Error updating presidential candidate: $e');
    }
  }

  Future<void> updateGovernorCandidate(GovernorCandidate candidate) async {
    try {
      await _db.addGovernorCandidate(candidate);
      final index = _governorCandidates.indexWhere((c) => c.id == candidate.id);
      if (index >= 0) {
        _governorCandidates[index] = candidate;
      } else {
        _governorCandidates.add(candidate);
      }
      notifyListeners();
    } catch (e) {
      print('Error updating governor candidate: $e');
    }
  }

  Future<void> updateLGACandidate(LGACandidate candidate) async {
    try {
      await _db.addLGACandidate(candidate);
      final index = _lgaCandidates.indexWhere((c) => c.id == candidate.id);
      if (index >= 0) {
        _lgaCandidates[index] = candidate;
      } else {
        _lgaCandidates.add(candidate);
      }
      notifyListeners();
    } catch (e) {
      print('Error updating LGA candidate: $e');
    }
  }

  int getTotalVotes() {
    int total = 0;
    total += _presidentialCandidates.fold(0, (sum, c) => sum + c.votes);
    total += _governorCandidates.fold(0, (sum, c) => sum + c.votes);
    total += _lgaCandidates.fold(0, (sum, c) => sum + c.votes);
    return total;
  }

  bool hasUserVoted() => _userVote != null;

  Future<void> refreshData() async {
    await _loadData();
  }
}