import 'dart:math';
import 'package:uuid/uuid.dart';
import 'package:logger/logger.dart';
import '../models/app_models.dart';
import 'database_service.dart';
import 'post_generator_service.dart';

final logger = Logger();
const uuid = Uuid();

class DataInitializationService {
  final DatabaseService _db = DatabaseService();
  final PostGeneratorService _generator = PostGeneratorService();
  final _random = Random();

  Future<void> initializeIfNeeded() async {
    try {
      final isInitialized = await _db.getInitializationStatus();
      if (!isInitialized) {
        await initialize();
      } else {
        logger.i('✅ Data already initialized, skipping');
      }
    } catch (e) {
      logger.e('Error checking initialization status: $e');
      await initialize();
    }
  }

  Future<void> initialize() async {
    try {
      logger.i('🚀 Starting data initialization...');

      // Load sample posts
      final samplePosts = _generator.generateSamplePosts();
      for (final post in samplePosts) {
        await _db.addPost(post);
      }
      logger.i('✅ Loaded ${samplePosts.length} sample posts');

      // Load presidential candidates
      final presidentialCandidates =
      _generator.generatePresidentialCandidates();
      for (final candidate in presidentialCandidates) {
        await _db.addPresidentialCandidate(candidate);
      }
      logger.i('✅ Loaded ${presidentialCandidates.length} presidential candidates');

      // Generate and load governor candidates
      await _loadGovernorCandidates();

      // Generate and load LGA candidates
      await _loadLGACandidates();

      // Generate and load reforms
      await _loadReforms();

      // Mark as initialized
      await _db.markInitialized();
      logger.i('✅ Data initialization complete!');
    } catch (e) {
      logger.e('Error during initialization: $e');
    }
  }

  Future<void> _loadGovernorCandidates() async {
    try {
      final nigerianaStates = [
        'Lagos',
        'Kano',
        'Rivers',
        'Kaduna',
        'Katsina',
        'Enugu',
        'Oyo',
        'Delta'
      ];
      final parties = ['APC', 'PDP', 'NNPP', 'LP', 'SDP'];

      for (final state in nigerianaStates) {
        for (int i = 0; i < 3; i++) {
          final governor = GovernorCandidate(
            id: uuid.v4(),
            name: 'Governor Candidate ${i + 1}',
            party: parties[_random.nextInt(parties.length)],
            state: state,
            imageUrl:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=250&fit=crop',
            votes: _random.nextInt(100000) + 50000,
          );
          await _db.addGovernorCandidate(governor);
        }
      }
      logger.i('✅ Loaded governor candidates for all states');
    } catch (e) {
      logger.e('Error loading governor candidates: $e');
    }
  }

  Future<void> _loadLGACandidates() async {
    try {
      final lgas = ['Ikoyi', 'Victoria Island', 'Lekki', 'Surulere', 'Yaba'];
      final parties = ['APC', 'PDP', 'NNPP', 'LP', 'SDP'];

      for (final lga in lgas) {
        for (int i = 0; i < 2; i++) {
          final lgaCandidate = LGACandidate(
            id: uuid.v4(),
            name: 'LGA Candidate ${i + 1}',
            party: parties[_random.nextInt(parties.length)],
            state: 'Lagos',
            lga: lga,
            imageUrl:
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&h=250&fit=crop',
            votes: _random.nextInt(50000) + 10000,
          );
          await _db.addLGACandidate(lgaCandidate);
        }
      }
      logger.i('✅ Loaded LGA candidates for all councils');
    } catch (e) {
      logger.e('Error loading LGA candidates: $e');
    }
  }

  Future<void> _loadReforms() async {
    try {
      final reforms = [
        Reform(
          id: uuid.v4(),
          title: 'Healthcare Reform',
          description: 'Improving access to healthcare across Nigeria',
          status: 'In Progress',
          progress: 0.45,
        ),
        Reform(
          id: uuid.v4(),
          title: 'Education Initiative',
          description: 'Upgrading educational infrastructure nationwide',
          status: 'Planned',
          progress: 0.0,
        ),
        Reform(
          id: uuid.v4(),
          title: 'Security Modernization',
          description: 'Enhancing security operations and equipment',
          status: 'In Progress',
          progress: 0.60,
        ),
        Reform(
          id: uuid.v4(),
          title: 'Infrastructure Development',
          description: 'Building roads and utilities in rural areas',
          status: 'Completed',
          progress: 1.0,
        ),
        Reform(
          id: uuid.v4(),
          title: 'Environmental Protection',
          description: 'Conservation and climate action programs',
          status: 'In Progress',
          progress: 0.35,
        ),
      ];

      for (final reform in reforms) {
        await _db.addReform(reform);
      }
      logger.i('✅ Loaded ${reforms.length} government reforms');
    } catch (e) {
      logger.e('Error loading reforms: $e');
    }
  }
}