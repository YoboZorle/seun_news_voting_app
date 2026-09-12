import 'dart:math';
import 'dart:async';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import '../models/app_models.dart';
import 'database_service.dart';
import 'notification_service.dart';

class PostGeneratorService {
  static final PostGeneratorService _instance = PostGeneratorService._internal();
  static final logger = Logger();
  
  Timer? _timer;
  final _random = Random();
  final _uuid = const Uuid();
  
  PostGeneratorService._internal();
  factory PostGeneratorService() => _instance;

  void startGeneratingPosts({Duration interval = const Duration(seconds: 45)}) {
    _timer?.cancel();
    
    _timer = Timer.periodic(interval, (_) {
      _generateAndShowRandomPost();
    });
    
    logger.i('✅ Post generation started (every ${interval.inSeconds}s)');
  }

  void stopGeneratingPosts() {
    _timer?.cancel();
    logger.i('⏸️ Post generation stopped');
  }

  Future<void> _generateAndShowRandomPost() async {
    try {
      final samplePosts = generateSamplePosts();
      if (samplePosts.isEmpty) return;

      final randomPost = samplePosts[_random.nextInt(samplePosts.length)];
      
      // Generate realistic engagement metrics
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
      
      // Also randomly update votes on reforms and contestants for real-time effect
      _addRandomVotes();
      
      final emoji = _getEmojiForCategory(newPost.category);
      await NotificationService().showNotification(
        title: '$emoji ${newPost.category} News Update',
        body: newPost.title.length > 60
            ? '${newPost.title.substring(0, 60)}...'
            : newPost.title,
        payload: newPost.id,
      );

      logger.i('📰 Generated: ${newPost.title} | Views: $viewCount | Likes: $likes');
    } catch (e) {
      logger.e('Error generating post: $e');
    }
  }

  Future<void> _addRandomVotes() async {
    try {
      final db = DatabaseService();
      final reforms = db.getAllReforms();
      final contestants = db.getAllContestants();

      // Random reform vote
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
      }

      // Random contestant vote
      if (contestants.isNotEmpty) {
        final randomContestant = contestants[_random.nextInt(contestants.length)];
        final voteType = _random.nextInt(2);
        if (voteType == 0) {
          await db.voteContestantSupport(randomContestant.id);
        } else {
          await db.voteContestantOppose(randomContestant.id);
        }
      }
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

  Future<void> generateInitialPosts() async {
    try {
      final db = DatabaseService();
      
      // Always ensure data is loaded (even if exists, refresh it)
      final posts = db.getAllPosts();
      final reforms = db.getAllReforms();
      final contestants = db.getAllContestants();

      if (posts.isEmpty) {
        final samplePosts = generateSamplePosts();
        for (final post in samplePosts) {
          await db.addPost(post);
        }
      }

      if (reforms.isEmpty) {
        final sampleReforms = generateSampleReforms();
        for (final reform in sampleReforms) {
          await db.addReform(reform);
        }
      }

      if (contestants.isEmpty) {
        final sampleContestants = generateSampleContestants();
        for (final contestant in sampleContestants) {
          await db.addContestant(contestant);
        }
      }

      logger.i('✅ Initial data verified - Posts: ${posts.length}, Reforms: ${reforms.length}, Contestants: ${contestants.length}');
    } catch (e) {
      logger.e('Error generating initial posts: $e');
    }
  }
}
