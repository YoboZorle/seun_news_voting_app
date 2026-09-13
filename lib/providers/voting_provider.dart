import 'package:flutter/foundation.dart';
import '../models/app_models.dart';
import '../services/database_service.dart';

class VotingProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  
  List<PresidentialCandidate> _presidentialCandidates = [];
  List<GovernorCandidate> _governorCandidates = [];
  List<LGACandidate> _lgaCandidates = [];
  List<Reform> _reforms = [];

  List<PresidentialCandidate> get presidentialCandidates =>
      _presidentialCandidates;
  List<GovernorCandidate> get governorCandidates => _governorCandidates;
  List<LGACandidate> get lgaCandidates => _lgaCandidates;
  List<Reform> get reforms => _reforms;

  VotingProvider() {
    _loadVotingData();
  }

  Future<void> _loadVotingData() async {
    _presidentialCandidates =
        _db.getAllPresidentialCandidates();
    _governorCandidates =
        await _db.getAllGovernorCandidates();
    _lgaCandidates = await _db.getAllLGACandidates();
    _reforms = await _db.getAllReforms();
    notifyListeners();
  }

  Future<void> refreshData() async {
    await _loadVotingData();
  }

  // PRESIDENTIAL VOTING
  void votePresidential(String candidateId) {
    final index = _presidentialCandidates
        .indexWhere((c) => c.id == candidateId);
    if (index >= 0) {
      _presidentialCandidates[index].votes++;
      _db.addPresidentialCandidate(
          _presidentialCandidates[index]);
      notifyListeners();
    }
  }

  // GOVERNOR VOTING
  List<String> getGovernorStates() {
    final states = _governorCandidates
        .map((c) => c.state)
        .toSet()
        .toList();
    states.sort();
    return states;
  }

  List<GovernorCandidate> getGovernorCandidatesByState(
      String state) {
    return _governorCandidates
        .where((c) => c.state == state)
        .toList();
  }

  void voteGovernor(String candidateId) {
    final index = _governorCandidates
        .indexWhere((c) => c.id == candidateId);
    if (index >= 0) {
      _governorCandidates[index].votes++;
      _db.addGovernorCandidate(
          _governorCandidates[index]);
      notifyListeners();
    }
  }

  // LGA VOTING
  List<String> getLGAStates() {
    final states =
        _lgaCandidates.map((c) => c.state).toSet().toList();
    states.sort();
    return states;
  }

  List<String> getLGAsByState(String state) {
    final lgas = _lgaCandidates
        .where((c) => c.state == state)
        .map((c) => c.lga)
        .toSet()
        .toList();
    lgas.sort();
    return lgas;
  }

  List<LGACandidate> getLGACandidatesByLGA(String lga) {
    return _lgaCandidates
        .where((c) => c.lga == lga)
        .toList();
  }

  void voteLGA(String candidateId) {
    final index =
        _lgaCandidates.indexWhere((c) => c.id == candidateId);
    if (index >= 0) {
      _lgaCandidates[index].votes++;
      _db.addLGACandidate(_lgaCandidates[index]);
      notifyListeners();
    }
  }

  // REFORMS VOTING
  void voteReformSupport(String reformId) {
    final index = _reforms.indexWhere((r) => r.id == reformId);
    if (index >= 0) {
      _reforms[index].supportVotes =
          (_reforms[index].supportVotes ?? 0) + 1;
      _db.addReform(_reforms[index]);
      notifyListeners();
    }
  }

  void voteReformOppose(String reformId) {
    final index = _reforms.indexWhere((r) => r.id == reformId);
    if (index >= 0) {
      _reforms[index].opposeVotes =
          (_reforms[index].opposeVotes ?? 0) + 1;
      _db.addReform(_reforms[index]);
      notifyListeners();
    }
  }

  void voteReformNeutral(String reformId) {
    final index = _reforms.indexWhere((r) => r.id == reformId);
    if (index >= 0) {
      _reforms[index].neutralVotes =
          (_reforms[index].neutralVotes ?? 0) + 1;
      _db.addReform(_reforms[index]);
      notifyListeners();
    }
  }
}
