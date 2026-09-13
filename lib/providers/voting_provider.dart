import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../services/database_service.dart';
import '../services/continuous_voting_service.dart';

class VotingProvider extends ChangeNotifier {
  final ContinuousVotingService _votingService = ContinuousVotingService();
  List<PresidentialCandidate> _presidentialCandidates = [];
  List<GovernorCandidate> _governorCandidates = [];
  List<LGACandidate> _lgaCandidates = [];
  List<Reform> _reforms = [];
  UserVoteState _userVoteState = UserVoteState();
  
  // Vote tracking for all elections
  final Set<String> _votedGovernors = {};
  final Set<String> _votedLGAs = {};
  final Set<String> _votedReforms = {};

  // Constructor
  VotingProvider() {
    _loadUserVoteState();
    _setupVotingStreams();
  }

  // Getters
  List<PresidentialCandidate> get presidentialCandidates => _presidentialCandidates;
  List<GovernorCandidate> get governorCandidates => _governorCandidates;
  List<LGACandidate> get lgaCandidates => _lgaCandidates;
  List<Reform> get reforms => _reforms;
  UserVoteState get userVoteState => _userVoteState;

  int get totalVotes => _votingService.totalVotes;
  int get totalVoters => _votingService.totalVoters;

  // Load user vote state from storage
  Future<void> _loadUserVoteState() async {
    _userVoteState = await DatabaseService.getUserVoteState();
    notifyListeners();
  }

  // Setup voting streams
  void _setupVotingStreams() {
    // Presidential stream
    _votingService.presidentialStream.listen((candidates) {
      _presidentialCandidates = candidates;
      notifyListeners();
    });

    // Governors stream
    _votingService.governorsStream.listen((candidates) {
      _governorCandidates = candidates;
      notifyListeners();
    });

    // LGA stream
    _votingService.lgaStream.listen((candidates) {
      _lgaCandidates = candidates;
      notifyListeners();
    });

    // Reforms stream
    _votingService.reformsStream.listen((reforms) {
      _reforms = reforms;
      notifyListeners();
    });
  }

  // Vote for presidential candidate
  Future<bool> votePresidential(String candidateId) async {
    // Check if already voted
    if (_userVoteState.hasVotedPresidential) {
      return false;
    }

    try {
      _votingService.votePresidential(candidateId);

      // Update local state
      _userVoteState.hasVotedPresidential = true;
      _userVoteState.votedPresidentialId = candidateId;
      _userVoteState.lastVoteTime = DateTime.now();

      // Save to persistent storage
      await DatabaseService.saveUserVoteState(_userVoteState);

      notifyListeners();
      return true;
    } catch (e) {
      print('Error voting: $e');
      return false;
    }
  }

  // Vote for governor
  Future<void> voteGovernor(String candidateId) async {
    if (!_votedGovernors.contains(candidateId)) {
      _votingService.voteGovernor(candidateId);
      _votedGovernors.add(candidateId);
      notifyListeners();
    }
  }

  // Vote for LGA
  Future<void> voteLGA(String candidateId) async {
    if (!_votedLGAs.contains(candidateId)) {
      _votingService.voteLGA(candidateId);
      _votedLGAs.add(candidateId);
      notifyListeners();
    }
  }

  // Vote for reform
  Future<void> voteReform(String reformId) async {
    if (!_votedReforms.contains(reformId)) {
      _votingService.voteReform(reformId);
      _votedReforms.add(reformId);
      notifyListeners();
    }
  }

  // Check if user has voted
  bool hasVotedGovernor(String candidateId) => _votedGovernors.contains(candidateId);
  bool hasVotedLGA(String candidateId) => _votedLGAs.contains(candidateId);
  bool hasVotedReform(String reformId) => _votedReforms.contains(reformId);

  // Check if user can vote
  bool canVotePresidential() {
    return !_userVoteState.hasVotedPresidential;
  }

  // Format votes
  String formatVotes(int votes) {
    return _votingService.formatVotes(votes);
  }

  // Get total votes
  int getTotalVotes(List<dynamic> candidates) {
    int total = 0;
    for (final candidate in candidates) {
      if (candidate is PresidentialCandidate) {
        total += candidate.votes;
      } else if (candidate is GovernorCandidate) {
        total += candidate.votes;
      } else if (candidate is LGACandidate) {
        total += candidate.votes;
      }
    }
    return total;
  }

  // Get vote percentage
  double getVotePercentage(dynamic candidate) {
    int total = 0;
    if (candidate is PresidentialCandidate) {
      total = getTotalVotes(_presidentialCandidates);
      return total > 0 ? (candidate.votes / total) * 100 : 0;
    } else if (candidate is GovernorCandidate) {
      total = getTotalVotes(_governorCandidates);
      return total > 0 ? (candidate.votes / total) * 100 : 0;
    } else if (candidate is LGACandidate) {
      total = getTotalVotes(_lgaCandidates);
      return total > 0 ? (candidate.votes / total) * 100 : 0;
    }
    return 0;
  }

  // Get governor states
  List<String> getGovernorStates() {
    final states = <String>{};
    for (final candidate in _governorCandidates) {
      states.add(candidate.state);
    }
    return states.toList()..sort();
  }

  // Get governor candidates by state
  List<GovernorCandidate> getGovernorCandidatesByState(String state) {
    return _governorCandidates.where((c) => c.state == state).toList()
      ..sort((a, b) => b.votes.compareTo(a.votes));
  }

  // Get LGAs by state
  List<String> getLGAsByState(String state) {
    final lgas = <String>{};
    for (final candidate in _lgaCandidates) {
      if (candidate.lga.startsWith(state)) {
        lgas.add(candidate.lga);
      }
    }
    return lgas.toList()..sort();
  }

  // Get LGA candidates by LGA
  List<LGACandidate> getLGACandidatesByLGA(String lga) {
    return _lgaCandidates.where((c) => c.lga == lga).toList()
      ..sort((a, b) => b.votes.compareTo(a.votes));
  }

  // Refresh data
  Future<void> refreshData() async {
    await _loadUserVoteState();
    notifyListeners();
  }

  @override
  void dispose() {
    _votingService.dispose();
    super.dispose();
  }
}
