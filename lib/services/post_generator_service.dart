import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import '../models/app_models.dart';
import 'database_service.dart';
import 'notification_service.dart';
import 'dart:math';

class PostGeneratorService {
  static final PostGeneratorService _instance = PostGeneratorService._internal();
  final logger = Logger();
  final _uuid = const Uuid();
  final _random = Random();
  Timer? _timer;

  factory PostGeneratorService() {
    return _instance;
  }

  PostGeneratorService._internal();

  Future<void> startGeneratingPosts({Duration interval = const Duration(seconds: 45)}) async {
    try {
      logger.i('🚀 Starting post generator with ${interval.inSeconds}s interval');
      
      await generateInitialPosts();
      
      _timer = Timer.periodic(interval, (_) async {
        await _generateAndShowRandomPost();
      });
    } catch (e) {
      logger.e('Error starting post generator: $e');
    }
  }

  Future<void> generateInitialPosts() async {
    try {
      final db = DatabaseService();
      
      final posts = db.getAllPosts();
      final reforms = db.getAllReforms();
      final presidentialCandidates = db.getAllPresidentialCandidates();
      final governorCandidates = db.getAllGovernorCandidates();
      final lgaCandidates = db.getAllLGACandidates();

      if (posts.isEmpty) {
        for (final post in generateSamplePosts()) {
          await db.addPost(post);
        }
      }

      if (reforms.isEmpty) {
        for (final reform in generateSampleReforms()) {
          await db.addReform(reform);
        }
      }

      if (presidentialCandidates.isEmpty) {
        for (final candidate in generatePresidentialCandidates()) {
          await db.addPresidentialCandidate(candidate);
        }
      }

      if (governorCandidates.isEmpty) {
        for (final candidate in generateGovernorCandidates()) {
          await db.addGovernorCandidate(candidate);
        }
      }

      if (lgaCandidates.isEmpty) {
        for (final candidate in generateLGACandidates()) {
          await db.addLGACandidate(candidate);
        }
      }

      logger.i('✅ Initial data loaded - Posts: ${posts.length}, Reforms: ${reforms.length}, Presidential: ${presidentialCandidates.length}, Governors: ${governorCandidates.length}, LGA: ${lgaCandidates.length}');
    } catch (e) {
      logger.e('Error generating initial posts: $e');
    }
  }

  Future<void> _generateAndShowRandomPost() async {
    try {
      final samplePosts = generateSamplePosts();
      if (samplePosts.isEmpty) return;

      final randomPost = samplePosts[_random.nextInt(samplePosts.length)];
      
      final viewCount = 150 + _random.nextInt(850);
      final likes = 20 + _random.nextInt(480);
      final dislikes = _random.nextInt(100);
      
      final newPost = randomPost.copyWith(
        id: _uuid.v4(),
        timestamp: DateTime.now(),
        viewCount: viewCount,
        likes: likes,
        dislikes: dislikes,
      );

      await DatabaseService().addPost(newPost);
      
      await _addRandomVotes();
      
      final emoji = _getEmojiForCategory(newPost.category);
      await NotificationService().showNotification(
        title: '$emoji ${newPost.category} Update',
        body: newPost.title.length > 60
            ? '${newPost.title.substring(0, 60)}...'
            : newPost.title,
        payload: newPost.id,
      );

      logger.i('📰 Post: ${newPost.title} | Views: $viewCount | Likes: $likes');
    } catch (e) {
      logger.e('Error generating post: $e');
    }
  }

  Future<void> _addRandomVotes() async {
    try {
      final db = DatabaseService();
      
      // Random reform vote
      final reforms = db.getAllReforms();
      if (reforms.isNotEmpty) {
        final randomReform = reforms[_random.nextInt(reforms.length)];
        final voteType = _random.nextInt(3);
        if (voteType == 0) {
          await db.voteReformSupport(randomReform.id);
          await NotificationService().showNotification(
            title: '🗳️ Reform Vote',
            body: '+1 Support for ${randomReform.title.substring(0, 40)}...',
            payload: randomReform.id,
          );
        } else if (voteType == 1) {
          await db.voteReformOppose(randomReform.id);
        } else {
          await db.voteReformNeutral(randomReform.id);
        }
      }

      // Random presidential vote
      final presidentialCandidates = db.getAllPresidentialCandidates();
      if (presidentialCandidates.isNotEmpty) {
        final randomCandidate = presidentialCandidates[_random.nextInt(presidentialCandidates.length)];
        await db.votePresidential(randomCandidate.id);
        await NotificationService().showNotification(
          title: '🇳🇬 Presidential Vote',
          body: '+1 Vote for ${randomCandidate.name}',
          payload: randomCandidate.id,
        );
      }

      // Random governor vote
      final governorCandidates = db.getAllGovernorCandidates();
      if (governorCandidates.isNotEmpty) {
        final randomCandidate = governorCandidates[_random.nextInt(governorCandidates.length)];
        await db.voteGovernor(randomCandidate.id);
      }

      // Random LGA vote
      final lgaCandidates = db.getAllLGACandidates();
      if (lgaCandidates.isNotEmpty) {
        final randomCandidate = lgaCandidates[_random.nextInt(lgaCandidates.length)];
        await db.voteLGA(randomCandidate.id);
      }

      logger.i('🗳️ Random votes added');
    } catch (e) {
      logger.e('Error adding random votes: $e');
    }
  }

  String _getEmojiForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'politics':
        return '🏛️';
      case 'sports':
        return '⚽';
      case 'finance':
        return '💰';
      case 'entertainment':
        return '🎬';
      case 'technology':
        return '🚀';
      default:
        return '📰';
    }
  }

  void dispose() {
    _timer?.cancel();
    logger.i('🛑 Post generator stopped');
  }
}
