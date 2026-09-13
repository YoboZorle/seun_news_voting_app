import 'dart:async';
import 'dart:math';
import '../models/app_models.dart';

/// Continuous voting service - votes happen every second, non-stop
class ContinuousVotingService {
  static final ContinuousVotingService _instance = ContinuousVotingService._internal();

  factory ContinuousVotingService() {
    return _instance;
  }

  ContinuousVotingService._internal();

  late Timer _presidentialTimer;
  late Timer _governorsTimer;
  late Timer _lgaTimer;
  late Timer _reformsTimer;
  
  late StreamController<List<PresidentialCandidate>> _presidentialStream;
  late StreamController<List<GovernorCandidate>> _governorsStream;
  late StreamController<List<LGACandidate>> _lgaStream;
  late StreamController<List<Reform>> _reformsStream;

  late List<PresidentialCandidate> _presidentialCandidates;
  late Map<String, List<GovernorCandidate>> _governorsByState;
  late Map<String, List<LGACandidate>> _lgasByArea;
  late List<Reform> _reforms;

  bool _initialized = false;
  
  int _totalVotes = 0;
  int _totalVoters = 125500000;

  Stream<List<PresidentialCandidate>> get presidentialStream => _presidentialStream.stream;
  
  int get totalVotes => _totalVotes;
  int get totalVoters => _totalVoters;
  Stream<List<GovernorCandidate>> get governorsStream => _governorsStream.stream;
  Stream<List<LGACandidate>> get lgaStream => _lgaStream.stream;
  Stream<List<Reform>> get reformsStream => _reformsStream.stream;

  void initialize() {
    if (_initialized) return;
    _initialized = true;

    _presidentialStream = StreamController<List<PresidentialCandidate>>.broadcast();
    _governorsStream = StreamController<List<GovernorCandidate>>.broadcast();
    _lgaStream = StreamController<List<LGACandidate>>.broadcast();
    _reformsStream = StreamController<List<Reform>>.broadcast();

    // Initialize candidates
    _initializeCandidates();

    // Start continuous voting timers (every 1 second)
    _presidentialTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      _simulatePresidentialVotes();
      _presidentialStream.add(List.from(_presidentialCandidates));
    });

    _governorsTimer = Timer.periodic(const Duration(milliseconds: 800), (_) {
      _simulateGovernorVotes();
      _governorsStream.add(_governorsByState.values.expand((e) => e).toList());
    });

    _lgaTimer = Timer.periodic(const Duration(milliseconds: 1000), (_) {
      _simulateLGAVotes();
      _lgaStream.add(_lgasByArea.values.expand((e) => e).toList());
    });

    _reformsTimer = Timer.periodic(const Duration(milliseconds: 600), (_) {
      _simulateReformsVotes();
      _reformsStream.add(List.from(_reforms));
    });
  }

  void _initializeCandidates() {
    // Presidential
    _presidentialCandidates = [
      PresidentialCandidate(id: 'apc', name: 'Bola Ahmed Tinubu', party: 'APC', votes: 32200000),
      PresidentialCandidate(id: 'pdp', name: 'Atiku Abubakar', party: 'PDP', votes: 28150000),
      PresidentialCandidate(id: 'lp', name: 'Peter Obi', party: 'LP', votes: 26310000),
      PresidentialCandidate(id: 'nnpp', name: 'Rabiu Kwankwaso', party: 'NNPP', votes: 20850000),
      PresidentialCandidate(id: 'sdp', name: 'Olorunfemi Ajayi', party: 'SDP', votes: 17990000),
    ];
    _totalVotes = _presidentialCandidates.fold<int>(0, (sum, c) => sum + c.votes);

    // Governors
    const states = ['Lagos', 'Kano', 'Rivers', 'Kaduna', 'Enugu', 'Katsina', 'Delta', 'Oyo'];
    _governorsByState = {};
    for (final state in states) {
      _governorsByState[state] = [
        GovernorCandidate(
          id: '${state}_gov_1',
          name: '$state Governor 1',
          party: 'APC',
          state: state,
          votes: 850000 + (state.length * 50000),
        ),
        GovernorCandidate(
          id: '${state}_gov_2',
          name: '$state Governor 2',
          party: 'PDP',
          state: state,
          votes: 750000 + (state.length * 40000),
        ),
        GovernorCandidate(
          id: '${state}_gov_3',
          name: '$state Governor 3',
          party: 'LP',
          state: state,
          votes: 620000 + (state.length * 30000),
        ),
      ];
    }

    // LGAs
    _lgasByArea = {};
    for (final state in states) {
      _lgasByArea[state] = [];
      for (int i = 1; i <= 10; i++) {
        _lgasByArea[state]!.add(
          LGACandidate(
            id: '${state}_lga_${i}',
            name: '$state LGA $i Candidate',
            party: i % 2 == 0 ? 'APC' : 'PDP',
            lga: '$state LGA $i',
            votes: 150000 + (i * 10000),
          ),
        );
      }
    }

    // Reforms
    _reforms = [
      Reform(id: 'reform_1', title: 'Healthcare System Modernization', 
             description: 'Digital health records and telemedicine', 
             progress: 45, votes: 5620000),
      Reform(id: 'reform_2', title: 'Education Technology Integration', 
             description: 'Smart classrooms in 500 schools', 
             progress: 60, votes: 6850000),
      Reform(id: 'reform_3', title: 'Transportation Infrastructure', 
             description: 'New rail networks across regions', 
             progress: 35, votes: 4320000),
      Reform(id: 'reform_4', title: 'Energy Transition', 
             description: '50% renewable energy by 2030', 
             progress: 40, votes: 5100000),
      Reform(id: 'reform_5', title: 'Digital Economy Development', 
             description: 'Tech startups and innovation hubs', 
             progress: 75, votes: 7890000),
    ];
  }

  void _simulatePresidentialVotes() {
    final random = Random();
    final newVotes = 150 + random.nextInt(300); // 150-450 per update (0.5s)
    
    _presidentialCandidates[0].votes += (newVotes ~/ 3); // APC gets 30%
    for (int i = 1; i < _presidentialCandidates.length; i++) {
      _presidentialCandidates[i].votes += (newVotes ~/ (3 * (_presidentialCandidates.length - 1)));
    }
    _totalVotes += newVotes;
  }

  void _simulateGovernorVotes() {
    final random = Random();
    for (final candidates in _governorsByState.values) {
      final newVotes = 100 + random.nextInt(200);
      for (final candidate in candidates) {
        candidate.votes += random.nextInt(newVotes);
      }
    }
  }

  void _simulateLGAVotes() {
    final random = Random();
    for (final candidates in _lgasByArea.values) {
      for (final candidate in candidates) {
        candidate.votes += random.nextInt(50) + 10;
      }
    }
  }

  void _simulateReformsVotes() {
    final random = Random();
    for (final reform in _reforms) {
      reform.votes += random.nextInt(100) + 50;
      // Update progress based on votes
      reform.progress = ((reform.progress * 100 + random.nextInt(5)) / 100).clamp(0, 100);
    }
  }

  String formatVotes(int votes) {
    if (votes >= 1000000) return '${(votes / 1000000).toStringAsFixed(1)}M';
    if (votes >= 1000) return '${(votes / 1000).toStringAsFixed(1)}K';
    return votes.toString();
  }

  void votePresidential(String candidateId) {
    final idx = _presidentialCandidates.indexWhere((c) => c.id == candidateId);
    if (idx != -1) {
      _presidentialCandidates[idx].votes += 1;
    }
  }

  void voteGovernor(String candidateId) {
    for (final candidates in _governorsByState.values) {
      final idx = candidates.indexWhere((c) => c.id == candidateId);
      if (idx != -1) {
        candidates[idx].votes += 1;
        break;
      }
    }
  }

  void voteLGA(String candidateId) {
    for (final candidates in _lgasByArea.values) {
      final idx = candidates.indexWhere((c) => c.id == candidateId);
      if (idx != -1) {
        candidates[idx].votes += 1;
        break;
      }
    }
  }

  void voteReform(String reformId) {
    final idx = _reforms.indexWhere((r) => r.id == reformId);
    if (idx != -1) {
      _reforms[idx].votes += 1;
      _reforms[idx].userVoted = true;
    }
  }

  void dispose() {
    _presidentialTimer.cancel();
    _governorsTimer.cancel();
    _lgaTimer.cancel();
    _reformsTimer.cancel();
    _presidentialStream.close();
    _governorsStream.close();
    _lgaStream.close();
    _reformsStream.close();
  }
}
