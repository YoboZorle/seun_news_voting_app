import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../services/database_service.dart';
import '../services/real_time_voting_service.dart';

class VotingProvider extends ChangeNotifier {
  final RealTimeVotingService _votingService = RealTimeVotingService();
  List<PresidentialCandidate> _presidentialCandidates = [];
  List<GovernorCandidate> _governorCandidates = [];
  List<LGACandidate> _lgaCandidates = [];
  List<Reform> _reforms = [];
  UserVoteState _userVoteState = UserVoteState();

  // Constructor
  VotingProvider() {
    _initializeCandidates();
    _loadUserVoteState();
    _setupVotingStream();
  }

  // Getters
  List<PresidentialCandidate> get presidentialCandidates => _presidentialCandidates;
  List<GovernorCandidate> get governorCandidates => _governorCandidates;
  List<LGACandidate> get lgaCandidates => _lgaCandidates;
  List<Reform> get reforms => _reforms;
  UserVoteState get userVoteState => _userVoteState;

  int get totalVotes => _votingService.totalVotes;
  int get totalVoters => _votingService.totalVoters;

  // Initialize candidates
  void _initializeCandidates() {
    // Presidential candidates (from real-time service)
    _presidentialCandidates = _votingService.getCandidates();

    // Governor candidates (24 total - 3 per state, 8 states)
    const states = ['Lagos', 'Kano', 'Rivers', 'Kaduna', 'Enugu', 'Katsina', 'Delta', 'Oyo'];
    _governorCandidates = [];
    for (final state in states) {
      _governorCandidates.addAll([
        GovernorCandidate(
          id: '${state}_gov_1',
          name: '$state Governor 1',
          party: 'APC',
          state: state,
          votes: 5000 + (state.length * 1000),
        ),
        GovernorCandidate(
          id: '${state}_gov_2',
          name: '$state Governor 2',
          party: 'PDP',
          state: state,
          votes: 4500 + (state.length * 800),
        ),
        GovernorCandidate(
          id: '${state}_gov_3',
          name: '$state Governor 3',
          party: 'LP',
          state: state,
          votes: 3000 + (state.length * 500),
        ),
      ]);
    }

    // LGA candidates (80 total - 10 per state)
    _lgaCandidates = [];
    for (final state in states) {
      for (int i = 1; i <= 10; i++) {
        _lgaCandidates.add(
          LGACandidate(
            id: '${state}_lga_$i',
            name: '$state LGA $i Candidate',
            party: i % 2 == 0 ? 'APC' : 'PDP',
            lga: '$state LGA $i',
            votes: 1000 + (i * 100),
          ),
        );
      }
    }

    // Reforms
    _reforms = [
      Reform(
        id: 'reform_1',
        title: 'Healthcare System Modernization',
        description: 'Implementing digital health records and telemedicine',
        progress: 45,
      ),
      Reform(
        id: 'reform_2',
        title: 'Education Technology Integration',
        description: 'Introducing smart classrooms in 500 schools',
        progress: 60,
      ),
      Reform(
        id: 'reform_3',
        title: 'Transportation Infrastructure',
        description: 'Building new rail networks across major regions',
        progress: 35,
      ),
      Reform(
        id: 'reform_4',
        title: 'Energy Transition',
        description: 'Moving to 50% renewable energy by 2030',
        progress: 40,
      ),
      Reform(
        id: 'reform_5',
        title: 'Digital Economy Development',
        description: 'Investing in tech startups and innovation hubs',
        progress: 75,
      ),
    ];
  }

  // Load user vote state from storage
  Future<void> _loadUserVoteState() async {
    _userVoteState = await DatabaseService.getUserVoteState();
    notifyListeners();
  }

  // Setup voting stream
  void _setupVotingStream() {
    _votingService.votingStream.listen((candidates) {
      _presidentialCandidates = candidates;
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
      // Add vote via service
      await _votingService.addVote(candidateId);

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

  // Check if user can vote
  bool canVotePresidential() {
    return !_userVoteState.hasVotedPresidential;
  }

  // Get vote percentage
  double getVotePercentage(PresidentialCandidate candidate) {
    return _votingService.getVotePercentage(candidate);
  }

  // Format votes
  String formatVotes(int votes) {
    return _votingService.formatVotes(votes);
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
    _initializeCandidates();
    await _loadUserVoteState();
    notifyListeners();
  }

  @override
  void dispose() {
    _votingService.dispose();
    super.dispose();
  }
}
