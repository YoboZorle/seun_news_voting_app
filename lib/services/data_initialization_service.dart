import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import '../models/app_models.dart';
import 'database_service.dart';

final logger = Logger();
const uuid = Uuid();

class DataInitializationService {
  final DatabaseService _db = DatabaseService();

  Future<void> initializeIfNeeded() async {
    try {
      final isInitialized = await _db.getInitializationStatus();
      
      if (!isInitialized) {
        logger.i('🚀 Starting data initialization...');
        await initialize();
        await _db.markInitialized();
        logger.i('✅ Data initialization complete!');
      } else {
        logger.i('✅ Data already initialized');
      }
    } catch (e) {
      logger.e('⛔ Error during initialization: $e');
    }
  }

  Future<void> initialize() async {
    try {
      // Initialize posts
      await _initializePosts();
      // Initialize presidential candidates
      await _initializePresidentialCandidates();
      // Initialize governor candidates
      await _initializeGovernorCandidates();
      // Initialize LGA candidates
      await _initializeLGACandidates();
      // Initialize reforms
      await _initializeReforms();
    } catch (e) {
      logger.e('⛔ Error during initialization: $e');
    }
  }

  Future<void> _initializePosts() async {
    final posts = [
      Post(
        id: uuid.v4(),
        title: 'Breaking: New Healthcare Initiative Launched',
        content: 'The Nigerian government announces a comprehensive healthcare modernization program...',
        category: 'Politics',
        imageUrl: 'https://images.unsplash.com/photo-1576091160550-2173dba999ef?w=500',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      Post(
        id: uuid.v4(),
        title: 'Economy Shows Signs of Growth',
        content: 'Economic indicators suggest positive momentum in Q3 2027...',
        category: 'Finance',
        imageUrl: 'https://images.unsplash.com/photo-1579621970563-430f63602d4b?w=500',
        timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
      ),
      Post(
        id: uuid.v4(),
        title: 'Tech Companies Invest Heavily in Nigeria',
        content: 'Major tech firms announce expansion plans and job creation...',
        category: 'Technology',
        imageUrl: 'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=500',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      Post(
        id: uuid.v4(),
        title: 'Education Reform Targets 90% Literacy Rate',
        content: 'New policies aim to improve educational standards across states...',
        category: 'Politics',
        imageUrl: 'https://images.unsplash.com/photo-1427504494785-cdece0c5873b?w=500',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Post(
        id: uuid.v4(),
        title: 'Nigerian Music Festival Breaks Records',
        content: 'Afrobeat artists gather for historic music celebration...',
        category: 'Entertainment',
        imageUrl: 'https://images.unsplash.com/photo-1429961185008-0c45921aa4e8?w=500',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      Post(
        id: uuid.v4(),
        title: 'Infrastructure Development Accelerates',
        content: 'Major transport corridors and roads being upgraded nationwide...',
        category: 'Politics',
        imageUrl: 'https://images.unsplash.com/photo-1581578731548-c64695c952952?w=500',
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      Post(
        id: uuid.v4(),
        title: 'Sports: National Teams Advance in Continental Championship',
        content: 'Nigerian athletes showcase excellence on the global stage...',
        category: 'Sports',
        imageUrl: 'https://images.unsplash.com/photo-1489749798305-4fea3ba63d60?w=500',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      Post(
        id: uuid.v4(),
        title: 'Climate Action: Renewable Energy Projects Expand',
        content: 'Solar and wind initiatives reduce carbon footprint...',
        category: 'Politics',
        imageUrl: 'https://images.unsplash.com/photo-1509391366360-2e938aa1ef14?w=500',
        timestamp: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      Post(
        id: uuid.v4(),
        title: 'Agriculture Sector Sees Record Yields',
        content: 'Farmers embrace modern techniques, production up by 40%...',
        category: 'Finance',
        imageUrl: 'https://images.unsplash.com/photo-1595421683269-e84e319ca748?w=500',
        timestamp: DateTime.now().subtract(const Duration(hours: 7)),
      ),
      Post(
        id: uuid.v4(),
        title: 'Security: Operations Target Criminal Networks',
        content: 'Multi-agency task force achieves significant successes...',
        category: 'Politics',
        imageUrl: 'https://images.unsplash.com/photo-1557804506-669714d2e9d8?w=500',
        timestamp: DateTime.now().subtract(const Duration(hours: 8)),
      ),
      Post(
        id: uuid.v4(),
        title: 'Youth Entrepreneurship Program Thrives',
        content: 'Thousands of young Nigerians launching successful businesses...',
        category: 'Technology',
        imageUrl: 'https://images.unsplash.com/photo-1552664730-d307ca884978?w=500',
        timestamp: DateTime.now().subtract(const Duration(hours: 9)),
      ),
      Post(
        id: uuid.v4(),
        title: 'Healthcare Facilities Expanded in Rural Areas',
        content: 'Access to medical services improving in underserved regions...',
        category: 'Politics',
        imageUrl: 'https://images.unsplash.com/photo-1579154204601-01d47afb2147?w=500',
        timestamp: DateTime.now().subtract(const Duration(hours: 10)),
      ),
      Post(
        id: uuid.v4(),
        title: 'Water & Sanitation Project Reaches 1 Million People',
        content: 'Clean water access expanding, improving public health...',
        category: 'Politics',
        imageUrl: 'https://images.unsplash.com/photo-1509027923553-64ac3f1b49ab?w=500',
        timestamp: DateTime.now().subtract(const Duration(hours: 11)),
      ),
    ];

    for (var post in posts) {
      await _db.addPost(post);
    }
    logger.i('✅ Loaded ${posts.length} sample posts');
  }

  Future<void> _initializePresidentialCandidates() async {
    final candidates = [
      PresidentialCandidate(
        id: uuid.v4(),
        name: 'Bola Tinubu',
        party: 'APC (All Progressives Congress)',
        imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
      ),
      PresidentialCandidate(
        id: uuid.v4(),
        name: 'Atiku Abubakar',
        party: 'PDP (Peoples Democratic Party)',
        imageUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
      ),
      PresidentialCandidate(
        id: uuid.v4(),
        name: 'Peter Obi',
        party: 'LP (Labour Party)',
        imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
      ),
      PresidentialCandidate(
        id: uuid.v4(),
        name: 'Rabiu Kwankwaso',
        party: 'NNPP (New Nigeria Peoples Party)',
        imageUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
      ),
      PresidentialCandidate(
        id: uuid.v4(),
        name: 'Olorunfemi Ajayi',
        party: 'SDP (Social Democratic Party)',
        imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
      ),
    ];

    for (var candidate in candidates) {
      await _db.addPresidentialCandidate(candidate);
    }
    logger.i('✅ Loaded ${candidates.length} presidential candidates');
  }

  Future<void> _initializeGovernorCandidates() async {
    final states = ['Lagos', 'Kano', 'Rivers', 'Kaduna', 'Enugu', 'Katsina', 'Delta', 'Oyo'];
    final parties = ['APC', 'PDP', 'NNPP'];

    int count = 0;
    for (var state in states) {
      for (int i = 0; i < 3; i++) {
        final candidate = GovernorCandidate(
          id: uuid.v4(),
          name: 'Gov Candidate ${i + 1} - $state',
          party: parties[i],
          state: state,
          imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
        );
        await _db.addGovernorCandidate(candidate);
        count++;
      }
    }
    logger.i('✅ Loaded $count governor candidates');
  }

  Future<void> _initializeLGACandidates() async {
    final states = ['Lagos', 'Kano', 'Rivers', 'Kaduna', 'Enugu', 'Katsina', 'Delta', 'Oyo'];
    final lgas = ['LGA 1', 'LGA 2', 'LGA 3', 'LGA 4', 'LGA 5'];
    final parties = ['APC', 'PDP', 'NNPP'];

    int count = 0;
    for (var state in states) {
      for (var lga in lgas) {
        for (int i = 0; i < 2; i++) {
          final candidate = LGACandidate(
            id: uuid.v4(),
            name: 'Rep ${i + 1} - $lga',
            party: parties[i % 3],
            state: state,
            lga: lga,
            imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
          );
          await _db.addLGACandidate(candidate);
          count++;
        }
      }
    }
    logger.i('✅ Loaded $count LGA candidates');
  }

  Future<void> _initializeReforms() async {
    final reforms = [
      Reform(
        id: uuid.v4(),
        title: 'Healthcare System Modernization',
        description: 'Comprehensive upgrade of healthcare infrastructure and services nationwide',
        status: 'In Progress',
        progress: 0.45,
      ),
      Reform(
        id: uuid.v4(),
        title: 'Education Infrastructure Development',
        description: 'Building modern schools and providing quality educational resources',
        status: 'Planning',
        progress: 0.0,
      ),
      Reform(
        id: uuid.v4(),
        title: 'Security & Law Enforcement Reform',
        description: 'Strengthen security agencies and improve public safety',
        status: 'In Progress',
        progress: 0.60,
      ),
      Reform(
        id: uuid.v4(),
        title: 'Infrastructure Development Initiative',
        description: 'Roads, bridges, and transport corridor improvement',
        status: 'Completed',
        progress: 1.0,
      ),
      Reform(
        id: uuid.v4(),
        title: 'Environmental & Climate Action',
        description: 'Renewable energy projects and environmental conservation',
        status: 'In Progress',
        progress: 0.35,
      ),
    ];

    for (var reform in reforms) {
      await _db.addReform(reform);
    }
    logger.i('✅ Loaded ${reforms.length} reforms');
  }
}
