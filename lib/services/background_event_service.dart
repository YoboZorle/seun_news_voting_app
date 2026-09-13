import 'package:logger/logger.dart';
import 'dart:async';
import 'dart:math';
import '../models/app_models.dart';
import 'database_service.dart';
import 'notification_service.dart';

class BackgroundEventService {
  static final BackgroundEventService _instance =
      BackgroundEventService._internal();
  final logger = Logger();
  final _random = Random();
  
  Timer? _rapidEventTimer;
  Timer? _milestoneTimer;
  Timer? _breakingNewsTimer;
  
  int _eventCount = 0;
  int _notificationBadge = 0;

  factory BackgroundEventService() {
    return _instance;
  }

  BackgroundEventService._internal();

  /// Start continuous real-time event generation
  Future<void> startContinuousEvents() async {
    try {
      logger.i('🚀 Starting continuous real-time event generation');
      
      // Rapid events every 2-5 seconds (votes, engagements)
      _startRapidEventGenerator();
      
      // Milestone checks every 3-8 seconds (voting milestones)
      _startMilestoneDetector();
      
      // Breaking news every 5-12 seconds
      _startBreakingNewsGenerator();
      
      logger.i('✅ All event generators started');
    } catch (e) {
      logger.e('Error starting continuous events: $e');
    }
  }

  /// Generate rapid events (votes, likes, views) every 2-5 seconds
  void _startRapidEventGenerator() {
    _rapidEventTimer?.cancel();
    _rapidEventTimer = Timer.periodic(
      Duration(seconds: _random.nextInt(4) + 2), // 2-5 seconds
      (_) async {
        try {
          final eventType = _random.nextInt(5);
          
          switch (eventType) {
            case 0:
              await _generateRandomVote(); // Presidential vote
            case 1:
              await _generateGovernorVote(); // Governor vote
            case 2:
              await _generateLGAVote(); // LGA vote
            case 3:
              await _generateReformVote(); // Reform vote
            case 4:
              await _generatePostEngagement(); // Post engagement
          }
          
          _eventCount++;
          logger.i('⚡ Event #$_eventCount generated');
        } catch (e) {
          logger.e('Error in rapid event generator: $e');
        }
      },
    );
  }

  /// Detect milestones (1M votes, 500K votes, etc.) every 3-8 seconds
  void _startMilestoneDetector() {
    _milestoneTimer?.cancel();
    _milestoneTimer = Timer.periodic(
      Duration(seconds: _random.nextInt(6) + 3), // 3-8 seconds
      (_) async {
        try {
          final db = DatabaseService();
          final candidates = db.getAllPresidentialCandidates();
          
          for (var candidate in candidates) {
            final milestone = _checkMilestone(candidate.votes);
            if (milestone.isNotEmpty) {
              final notification =
                  'milestone: ${candidate.name} (${candidate.party}) - ${milestone}';
              
              _notificationBadge++;
              
              await NotificationService().showNotification(
                title: '🎯 MILESTONE ACHIEVED!',
                body: '${candidate.name} (${candidate.party}) ${milestone}',
                payload: 'presidential:${candidate.id}',
              );
              
              logger.i('🏆 Milestone: ${candidate.name} - $milestone');
            }
          }
          
          // Check governors
          final governors = db.getAllGovernorCandidates();
          for (var governor in governors) {
            final milestone = _checkMilestone(governor.votes);
            if (milestone.isNotEmpty) {
              _notificationBadge++;
              
              await NotificationService().showNotification(
                title: '🎯 $milestone',
                body: '${governor.name} in ${governor.state}',
                payload: 'governor:${governor.id}',
              );
            }
          }
        } catch (e) {
          logger.e('Error in milestone detector: $e');
        }
      },
    );
  }

  /// Generate breaking news every 5-12 seconds
  void _startBreakingNewsGenerator() {
    _breakingNewsTimer?.cancel();
    _breakingNewsTimer = Timer.periodic(
      Duration(seconds: _random.nextInt(8) + 5), // 5-12 seconds
      (_) async {
        try {
          final db = DatabaseService();
          
          // Breaking news about election leaders
          final candidates = db.getAllPresidentialCandidates();
          if (candidates.isNotEmpty) {
            candidates.sort((a, b) => b.votes.compareTo(a.votes));
            final leader = candidates.first;
            final totalVotes =
                candidates.fold<int>(0, (sum, c) => sum + c.votes);
            final percentage = totalVotes > 0 ? (leader.votes / totalVotes) * 100 : 0.0;
            
            if (percentage > 35) {
              _notificationBadge++;
              
              await NotificationService().showNotification(
                title: '🚨 BREAKING NEWS',
                body: '${leader.name} (${leader.party}) LEADING with ${percentage.toStringAsFixed(1)}%!',
                payload: 'breaking:presidential',
              );
              
              logger.i('🚨 Breaking: ${leader.name} leading at ${percentage.toStringAsFixed(1)}%');
            }
          }
          
          // State election updates
          final governors = db.getAllGovernorCandidates();
          final states = NIGERIAN_STATES;
          
          if (governors.isNotEmpty && states.isNotEmpty) {
            final randomState = states[_random.nextInt(states.length)];
            final stateGovs =
                governors.where((g) => g.state == randomState).toList();
            
            if (stateGovs.isNotEmpty) {
              stateGovs.sort((a, b) => b.votes.compareTo(a.votes));
              final leader = stateGovs.first;
              final totalVotes = stateGovs.fold<int>(0, (sum, g) => sum + g.votes);
              final percentage = totalVotes > 0 ? (leader.votes / totalVotes) * 100 : 0.0;
              
              if (percentage > 40) {
                _notificationBadge++;
                
                await NotificationService().showNotification(
                  title: '🏛️ $randomState ELECTIONS',
                  body: '${leader.name} (${leader.party}) leads with ${percentage.toStringAsFixed(1)}%',
                  payload: 'breaking:governor:$randomState',
                );
                
                logger.i('🏛️ Breaking: $randomState - ${leader.name} leading');
              }
            }
          }
        } catch (e) {
          logger.e('Error in breaking news generator: $e');
        }
      },
    );
  }

  /// Generate random presidential vote
  Future<void> _generateRandomVote() async {
    try {
      final db = DatabaseService();
      final candidates = db.getAllPresidentialCandidates();
      
      if (candidates.isNotEmpty) {
        final randomCandidate = candidates[_random.nextInt(candidates.length)];
        
        // Add 1-3 votes randomly
        for (int i = 0; i < _random.nextInt(3) + 1; i++) {
          await db.votePresidential(randomCandidate.id);
        }
        
        logger.i('🇳🇬 ${randomCandidate.votes} votes for ${randomCandidate.name}');
      }
    } catch (e) {
      logger.e('Error generating random vote: $e');
    }
  }

  /// Generate random governor vote
  Future<void> _generateGovernorVote() async {
    try {
      final db = DatabaseService();
      final governors = db.getAllGovernorCandidates();
      
      if (governors.isNotEmpty) {
        final randomGovernor = governors[_random.nextInt(governors.length)];
        
        for (int i = 0; i < _random.nextInt(2) + 1; i++) {
          await db.voteGovernor(randomGovernor.id);
        }
        
        logger.i('🏛️ ${randomGovernor.votes} votes for ${randomGovernor.name}');
      }
    } catch (e) {
      logger.e('Error generating governor vote: $e');
    }
  }

  /// Generate random LGA vote
  Future<void> _generateLGAVote() async {
    try {
      final db = DatabaseService();
      final lgaCandidates = db.getAllLGACandidates();
      
      if (lgaCandidates.isNotEmpty) {
        final randomCandidate =
            lgaCandidates[_random.nextInt(lgaCandidates.length)];
        
        for (int i = 0; i < _random.nextInt(2) + 1; i++) {
          await db.voteLGA(randomCandidate.id);
        }
        
        logger.i('🏘️ ${randomCandidate.votes} votes for ${randomCandidate.name}');
      }
    } catch (e) {
      logger.e('Error generating LGA vote: $e');
    }
  }

  /// Generate random reform vote
  Future<void> _generateReformVote() async {
    try {
      final db = DatabaseService();
      final reforms = db.getAllReforms();
      
      if (reforms.isNotEmpty) {
        final randomReform = reforms[_random.nextInt(reforms.length)];
        final voteType = _random.nextInt(3);
        
        if (voteType == 0) {
          await db.voteReformSupport(randomReform.id);
        } else if (voteType == 1) {
          await db.voteReformOppose(randomReform.id);
        } else {
          await db.voteReformNeutral(randomReform.id);
        }
        
        logger.i('🗳️ Reform vote added to "${randomReform.title}"');
      }
    } catch (e) {
      logger.e('Error generating reform vote: $e');
    }
  }

  /// Generate post engagement (likes, views)
  Future<void> _generatePostEngagement() async {
    try {
      final db = DatabaseService();
      final posts = db.getAllPosts();
      
      if (posts.isNotEmpty) {
        final randomPost = posts[_random.nextInt(posts.length)];
        final engagementType = _random.nextInt(3);
        
        if (engagementType == 0) {
          await db.likePost(randomPost.id);
          logger.i('👍 Post liked: ${randomPost.title.substring(0, 30)}...');
        } else if (engagementType == 1) {
          await db.incrementViewCount(randomPost.id);
          logger.i('👁️ Post viewed: ${randomPost.title.substring(0, 30)}...');
        }
      }
    } catch (e) {
      logger.e('Error generating post engagement: $e');
    }
  }

  /// Check if votes hit a milestone
  String _checkMilestone(int votes) {
    if (votes > 0) {
      if (votes % 1000000 == 0) {
        return '🎯 Hits ${votes ~/ 1000000}M votes!';
      }
      if (votes % 500000 == 0) {
        return '📈 Reaches ${votes ~/ 1000000}.5M votes';
      }
      if (votes % 100000 == 0) {
        return '✅ Surpasses ${votes ~/ 100000}00K votes';
      }
    }
    return '';
  }

  /// Stop all event generators
  void stopContinuousEvents() {
    _rapidEventTimer?.cancel();
    _milestoneTimer?.cancel();
    _breakingNewsTimer?.cancel();
    logger.i('🛑 Continuous event generation stopped');
  }

  /// Get event statistics
  Map<String, dynamic> getEventStats() {
    return {
      'totalEvents': _eventCount,
      'notificationsSent': _notificationBadge,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
