import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../services/database_service.dart';

class VotingProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  
  late List<PoliticalReform> _reforms;
  late List<PresidentialCandidate> _presidentialCandidates;
  late List<GovernorCandidate> _governorCandidates;
  late List<LGACandidate> _lgaCandidates;
  
  String _selectedState = 'Lagos';
  String _selectedLGA = '';

  VotingProvider() {
    _loadData();
  }

  void _loadData() {
    _reforms = List.from(_db.getAllReforms());
    _presidentialCandidates = List.from(_db.getAllPresidentialCandidates());
    _governorCandidates = List.from(_db.getAllGovernorCandidates());
    _lgaCandidates = List.from(_db.getAllLGACandidates());
  }

  // Getters
  List<PoliticalReform> get reforms => _reforms;
  List<PresidentialCandidate> get presidentialCandidates => _presidentialCandidates;
  List<GovernorCandidate> get governorCandidates => _governorCandidates;
  List<GovernorCandidate> getGovernorsByState(String state) =>
      _governorCandidates.where((g) => g.state == state).toList();
  
  List<String> getStates() => NIGERIAN_STATES;
  String get selectedState => _selectedState;
  
  List<String> getLGAsByState(String state) {
    final lgas = _lgaCandidates
        .where((c) => c.state == state)
        .map((c) => c.lga)
        .toSet()
        .toList();
    return lgas;
  }
  
  String get selectedLGA => _selectedLGA;
  
  List<LGACandidate> getLGACandidates(String state, String lga) =>
      _lgaCandidates.where((c) => c.state == state && c.lga == lga).toList();

  // State setters
  void setSelectedState(String state) {
    _selectedState = state;
    _selectedLGA = '';
    notifyListeners();
  }

  void setSelectedLGA(String lga) {
    _selectedLGA = lga;
    notifyListeners();
  }

  // Reform votes
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

  // Presidential votes
  Future<void> votePresidential(String candidateId) async {
    await _db.votePresidential(candidateId);
    _loadData();
    notifyListeners();
  }

  // Governor votes
  Future<void> voteGovernor(String candidateId) async {
    await _db.voteGovernor(candidateId);
    _loadData();
    notifyListeners();
  }

  // LGA votes
  Future<void> voteLGA(String candidateId) async {
    await _db.voteLGA(candidateId);
    _loadData();
    notifyListeners();
  }

  // Refresh all data
  Future<void> refreshData() async {
    _loadData();
    notifyListeners();
  }
}
