import 'package:logger/logger.dart';
import 'dart:async';
import 'dart:math';
import '../models/app_models.dart';
import 'database_service.dart';
import 'notification_service.dart';

final logger = Logger();

class BackgroundEventService {
  static final BackgroundEventService _instance =
  BackgroundEventService._internal();
  final _random = Random();

  Timer? _ultraRapidEventTimer;
  Timer? _rapidEventTimer;
  Timer? _milestoneTimer;
  Timer? _breakingNewsTimer;
  Timer? _stateElectionTimer;
  Timer? _lgaElectionTimer;

  int _eventCount = 0;
  bool _running = false;

  factory BackgroundEventService() {
    return _instance;
  }

  BackgroundEventService._internal();

  /// Start continuous real-time event generation - NON-BLOCKING
  Future<void> startContinuousEvents() async {
    if (_running) {
      logger.i('⚠️ Background events already running');
      return;
    }

    _running = true;

    try {
      logger.i('🚀 Starting background event generators...');

      // Start all timers immediately - don't wait
      _startUltraRapidEventGenerator();
      _startRapidEventGenerator();
      _startMilestoneDetector();
      _startBreakingNewsGenerator();
      _startStateElectionUpdates();
      _startLGAElectionUpdates();

      logger.i('✅ All background event generators STARTED');
    } catch (e) {
      logger.e('❌ Error starting continuous events: $e');
      _running = false;
    }
  }

  /// ULTRA-RAPID: Votes every 0.5-1 second
  void _startUltraRapidEventGenerator() {
    _ultraRapidEventTimer?.cancel();
    _ultraRapidEventTimer = Timer.periodic(
      Duration(milliseconds: _random.nextInt(500) + 500),
          (_) {
        try {
          final db = DatabaseService();
          final eventType = _random.nextInt(4);

          switch (eventType) {
            case 0:
              _generateRandomVote();
            case 1:
              _generateGovernorVote();
            case 2:
              _generateLGAVote();
            case 3:
              _generatePostEngagement();
          }

          _eventCount++;
          if (_eventCount % 50 == 0) {
            logger.i('⚡ Events: $_eventCount (continuous)');
          }
        } catch (e) {
          logger.w('⚠️ Error in ultra-rapid generator: $e');
        }
      },
    );
  }

  /// RAPID: Post engagement every 1-2 seconds
  void _startRapidEventGenerator() {
    _rapidEventTimer?.cancel();
    _rapidEventTimer = Timer.periodic(
      Duration(seconds: _random.nextInt(2) + 1),
          (_) {
        try {
          final db = DatabaseService();
          final posts = db.getAllPosts();

          if (posts.isNotEmpty) {
            final randomPost = posts[_random.nextInt(posts.length)];
            randomPost.likes += _random.nextInt(50) + 10;
            randomPost.viewCount += _random.nextInt(200) + 50;

            db.addPost(randomPost);
          }
        } catch (e) {
          logger.w('⚠️ Error in rapid engagement: $e');
        }
      },
    );
  }

  /// MILESTONE DETECTION: Every 2-4 seconds
  void _startMilestoneDetector() {
    _milestoneTimer?.cancel();
    _milestoneTimer = Timer.periodic(
      Duration(seconds: _random.nextInt(3) + 2),
          (_) {
        try {
          final db = DatabaseService();

          final candidates = db.getAllPresidentialCandidates();
          for (var candidate in candidates) {
            final milestone = _checkMilestone(candidate.votes);
            if (milestone.isNotEmpty) {
              NotificationService().showCriticalNotification(
                title: '🎯 MILESTONE: ${candidate.name}',
                body: '${candidate.party} reached $milestone',
                payload: 'milestone:presidential:${candidate.id}:${candidate.votes}',
              );
            }
          }
        } catch (e) {
          logger.w('⚠️ Error in milestone detector: $e');
        }
      },
    );
  }

  /// BREAKING NEWS: Every 3-5 seconds
  void _startBreakingNewsGenerator() {
    _breakingNewsTimer?.cancel();
    _breakingNewsTimer = Timer.periodic(
      Duration(seconds: _random.nextInt(3) + 3),
          (_) {
        try {
          final db = DatabaseService();
          final candidates = db.getAllPresidentialCandidates();

          if (candidates.isNotEmpty) {
            candidates.sort((a, b) => b.votes.compareTo(a.votes));
            final leader = candidates.first;
            final totalVotes =
            candidates.fold<int>(0, (sum, c) => sum + c.votes);
            final percentage =
            totalVotes > 0 ? (leader.votes / totalVotes) * 100 : 0.0;

            NotificationService().showCriticalNotification(
              title: '📢 BREAKING NEWS',
              body: '${leader.name} (${leader.party}) LEADING at ${percentage.toStringAsFixed(1)}%',
              payload: 'breaking_news:presidential:${leader.id}',
            );
          }
        } catch (e) {
          logger.w('⚠️ Error in breaking news: $e');
        }
      },
    );
  }

  /// STATE ELECTIONS: Every 4-6 seconds
  void _startStateElectionUpdates() {
    _stateElectionTimer?.cancel();
    _stateElectionTimer = Timer.periodic(
      Duration(seconds: _random.nextInt(3) + 4),
          (_) {
        try {
          final db = DatabaseService();
          final states = ['Lagos', 'Kano', 'Rivers', 'Enugu'];
          final randomState = states[_random.nextInt(states.length)];

          final governors = db.getAllGovernorCandidates();
          final stateGovernors =
          governors.where((g) => g.state == randomState).toList();

          if (stateGovernors.isNotEmpty) {
            stateGovernors.sort((a, b) => b.votes.compareTo(a.votes));
            final leader = stateGovernors.first;

            NotificationService().showNotification(
              title: '🏛️ $randomState Election Update',
              body: '${leader.name} (${leader.party}) LEADING with ${leader.votes} votes',
              payload: 'state_election:$randomState:${leader.id}',
            );
          }
        } catch (e) {
          logger.w('⚠️ Error in state elections: $e');
        }
      },
    );
  }

  /// LGA ELECTIONS: Every 5-7 seconds
  void _startLGAElectionUpdates() {
    _lgaElectionTimer?.cancel();
    _lgaElectionTimer = Timer.periodic(
      Duration(seconds: _random.nextInt(3) + 5),
          (_) {
        try {
          final db = DatabaseService();
          final lgas = ['Ikeja', 'Lekki', 'Kano Municipal', 'Port Harcourt'];
          final randomLGA = lgas[_random.nextInt(lgas.length)];

          final lgaCandidates = db.getAllLGACandidates();
          final lgaOnly = lgaCandidates.where((c) => c.lga == randomLGA).toList();

          if (lgaOnly.isNotEmpty) {
            lgaOnly.sort((a, b) => b.votes.compareTo(a.votes));
            final leader = lgaOnly.first;

            NotificationService().showNotification(
              title: '🗳️ $randomLGA LGA Update',
              body: '${leader.name} (${leader.party}) in the lead',
              payload: 'lga_election:$randomLGA:${leader.id}',
            );
          }
        } catch (e) {
          logger.w('⚠️ Error in LGA elections: $e');
        }
      },
    );
  }

  // ========== VOTE GENERATORS ==========

  void _generateRandomVote() {
    try {
      final db = DatabaseService();
      final candidates = db.getAllPresidentialCandidates();
      if (candidates.isNotEmpty) {
        final randomCandidate = candidates[_random.nextInt(candidates.length)];
        randomCandidate.votes += _random.nextInt(100) + 50;
        db.addPresidentialCandidate(randomCandidate);
      }
    } catch (e) {
      logger.w('⚠️ Error generating vote: $e');
    }
  }

  void _generateGovernorVote() {
    try {
      final db = DatabaseService();
      final governors = db.getAllGovernorCandidates();
      if (governors.isNotEmpty) {
        final randomGovernor = governors[_random.nextInt(governors.length)];
        randomGovernor.votes += _random.nextInt(80) + 40;
        db.addGovernorCandidate(randomGovernor);
      }
    } catch (e) {
      logger.w('⚠️ Error generating governor vote: $e');
    }
  }

  void _generateLGAVote() {
    try {
      final db = DatabaseService();
      final lgaCandidates = db.getAllLGACandidates();
      if (lgaCandidates.isNotEmpty) {
        final randomLGA = lgaCandidates[_random.nextInt(lgaCandidates.length)];
        randomLGA.votes += _random.nextInt(60) + 20;
        db.addLGACandidate(randomLGA);
      }
    } catch (e) {
      logger.w('⚠️ Error generating LGA vote: $e');
    }
  }

  void _generatePostEngagement() {
    try {
      final db = DatabaseService();
      final posts = db.getAllPosts();
      if (posts.isNotEmpty) {
        final randomPost = posts[_random.nextInt(posts.length)];
        final engagementType = _random.nextInt(3);

        switch (engagementType) {
          case 0:
            randomPost.likes += _random.nextInt(100) + 20;
          case 1:
            randomPost.viewCount += _random.nextInt(500) + 100;
          case 2:
            randomPost.dislikes += _random.nextInt(30) + 5;
        }

        db.addPost(randomPost);
      }
    } catch (e) {
      logger.w('⚠️ Error in post engagement: $e');
    }
  }

  // ========== MILESTONE CHECKER ==========

  String _checkMilestone(int votes) {
    if (votes >= 10000000 && votes < 10000100) return '10M VOTES';
    if (votes >= 5000000 && votes < 5000100) return '5M VOTES';
    if (votes >= 1000000 && votes < 1000100) return '1M VOTES';
    if (votes >= 500000 && votes < 500100) return '500K VOTES';
    if (votes >= 100000 && votes < 100100) return '100K VOTES';
    return '';
  }

  // ========== CLEANUP ==========

  Future<void> stopContinuousEvents() async {
    try {
      _ultraRapidEventTimer?.cancel();
      _rapidEventTimer?.cancel();
      _milestoneTimer?.cancel();
      _breakingNewsTimer?.cancel();
      _stateElectionTimer?.cancel();
      _lgaElectionTimer?.cancel();

      _running = false;
      logger.i('⛔ All event generators STOPPED');
    } catch (e) {
      logger.w('⚠️ Error stopping events: $e');
    }
  }
}