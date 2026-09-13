import 'dart:async';
import 'dart:math';
import '../models/app_models.dart';

/// Real-time voting service simulating 125.5M voters
/// APC always maintains leadership
class RealTimeVotingService {
  static final RealTimeVotingService _instance = RealTimeVotingService._internal();

  factory RealTimeVotingService() {
    return _instance;
  }

  RealTimeVotingService._internal();

  late List<PresidentialCandidate> _candidates;
  late Timer _timer;
  late StreamController<List<PresidentialCandidate>> _votingStream;
  bool _initialized = false;
  int totalVotes = 0;
  final int totalVoters = 125500000; // 125.5M voters

  // Initial vote distribution (APC gets more to stay #1)
  static const Map<String, int> initialVotes = {
    'apc': 32200000, // 32.2M
    'pdp': 28150000, // 28.15M
    'lp': 26310000,  // 26.31M
    'nnpp': 20850000, // 20.85M
    'sdp': 17990000,  // 17.99M
  };

  Stream<List<PresidentialCandidate>> get votingStream => _votingStream.stream;

  void initialize() {
    if (_initialized) return;
    _initialized = true;

    _votingStream = StreamController<List<PresidentialCandidate>>.broadcast();

    // Initialize candidates
    _candidates = [
      PresidentialCandidate(
        id: 'apc',
        name: 'Bola Ahmed Tinubu',
        party: 'APC',
        votes: initialVotes['apc']!,
      ),
      PresidentialCandidate(
        id: 'pdp',
        name: 'Atiku Abubakar',
        party: 'PDP',
        votes: initialVotes['pdp']!,
      ),
      PresidentialCandidate(
        id: 'lp',
        name: 'Peter Obi',
        party: 'LP',
        votes: initialVotes['lp']!,
      ),
      PresidentialCandidate(
        id: 'nnpp',
        name: 'Rabiu Kwankwaso',
        party: 'NNPP',
        votes: initialVotes['nnpp']!,
      ),
      PresidentialCandidate(
        id: 'sdp',
        name: 'Olorunfemi Ajayi',
        party: 'SDP',
        votes: initialVotes['sdp']!,
      ),
    ];

    totalVotes = _candidates.fold(0, (sum, c) => sum + c.votes);

    // Start real-time updates
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      _simulateNewVotes();
      _votingStream.add(List.from(_candidates));
    });
  }

  /// Simulate new votes every 2 seconds
  void _simulateNewVotes() {
    final random = Random();
    final newVotes = 500 + random.nextInt(1500); // 500-2000 new votes

    // APC gets 30% (weighted to always stay #1)
    final apcVotes = (newVotes / 3).floor();
    final otherVotesTotal = newVotes - apcVotes;

    _candidates[0].votes += apcVotes; // APC

    // Distribute remaining votes among others
    final votesPerOther = otherVotesTotal ~/ 4;
    final remainder = otherVotesTotal % 4;

    for (int i = 1; i < _candidates.length; i++) {
      _candidates[i].votes += votesPerOther + (i == 1 ? remainder : 0);
    }

    // Ensure APC stays #1
    _candidates.sort((a, b) => b.votes.compareTo(a.votes));
    if (_candidates[0].id != 'apc') {
      final apcIndex = _candidates.indexWhere((c) => c.id == 'apc');
      final temp = _candidates[0];
      _candidates[0] = _candidates[apcIndex];
      _candidates[apcIndex] = temp;
    }

    totalVotes += newVotes;
  }

  /// Add vote for a candidate
  Future<void> addVote(String candidateId) async {
    final candidate = _candidates.firstWhere((c) => c.id == candidateId, orElse: () {
      throw Exception('Candidate not found');
    });
    candidate.votes += 1;
    totalVotes += 1;
    _votingStream.add(List.from(_candidates));
  }

  /// Get list of candidates (sorted by votes)
  List<PresidentialCandidate> getCandidates() {
    final sorted = List<PresidentialCandidate>.from(_candidates);
    sorted.sort((a, b) => b.votes.compareTo(a.votes));
    return sorted;
  }

  /// Format large vote numbers
  String formatVotes(int votes) {
    if (votes >= 1000000) {
      return '${(votes / 1000000).toStringAsFixed(1)}M';
    } else if (votes >= 1000) {
      return '${(votes / 1000).toStringAsFixed(1)}K';
    }
    return votes.toString();
  }

  /// Get vote percentage
  double getVotePercentage(PresidentialCandidate candidate) {
    return totalVotes > 0 ? (candidate.votes / totalVotes) * 100 : 0;
  }

  /// Get leading candidate
  PresidentialCandidate? getLeadingCandidate() {
    if (_candidates.isEmpty) return null;
    return _candidates.reduce((a, b) => a.votes > b.votes ? a : b);
  }

  void dispose() {
    _timer.cancel();
    _votingStream.close();
  }
}
