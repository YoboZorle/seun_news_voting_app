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
      final newPost = randomPost.copyWith(
        id: _uuid.v4(),
        timestamp: DateTime.now(),
        viewCount: _random.nextInt(1000),
        likes: _random.nextInt(500),
        dislikes: _random.nextInt(200),
      );

      await DatabaseService().addPost(newPost);
      
      await NotificationService().showNotification(
        title: '${newPost.category} News 🔔',
        body: newPost.title.length > 60
            ? '${newPost.title.substring(0, 60)}...'
            : newPost.title,
        payload: newPost.id,
      );

      logger.i('📰 Generated: ${newPost.title}');
    } catch (e) {
      logger.e('Error generating post: $e');
    }
  }

  Future<void> generateInitialPosts() async {
    try {
      final db = DatabaseService();
      if (db.getAllPosts().isNotEmpty) return;

      final samplePosts = generateSamplePosts();
      for (final post in samplePosts) {
        await db.addPost(post);
      }

      final reforms = generateSampleReforms();
      for (final reform in reforms) {
        await db.addReform(reform);
      }

      final contestants = generateSampleContestants();
      for (final contestant in contestants) {
        await db.addContestant(contestant);
      }

      logger.i('✅ Initial data generated');
    } catch (e) {
      logger.e('Error generating initial posts: $e');
    }
  }
}
