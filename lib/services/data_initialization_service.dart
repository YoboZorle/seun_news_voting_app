import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import 'database_service.dart';
import '../models/app_models.dart';

const _uuid = Uuid();
final logger = Logger();

/// Initialize sample data for first-time app launch
Future<void> initializeSampleData(DatabaseService db) async {
  try {
    logger.i('🔄 Checking if sample data needs initialization...');

    // Check if data already exists
    if (db.getAllPosts().isNotEmpty) {
      logger.i('✅ Sample data already exists, skipping initialization');
      return;
    }

    logger.i('📝 Initializing sample data...');

    // Initialize Posts
    await _initializeSamplePosts(db);

    // Initialize Presidential Candidates
    await _initializePresidentialCandidates(db);

    // Initialize Governor Candidates
    await _initializeGovernorCandidates(db);

    // Initialize LGA Candidates
    await _initializeLGACandidates(db);

    // Initialize Reforms
    await _initializeReforms(db);

    logger.i('✅ Sample data initialization complete!');
  } catch (e) {
    logger.e('❌ Error initializing sample data: $e');
  }
}

Future<void> _initializeSamplePosts(DatabaseService db) async {
  final posts = [
    Post(
      id: _uuid.v4(),
      title: 'Breaking: New Electoral Reforms Announced',
      content: 'The National Electoral Commission has announced sweeping reforms to improve the electoral process. Key changes include improved voter registration, real-time results tracking, and enhanced security measures.',
      category: 'Politics',
      imageUrl: 'https://via.placeholder.com/400x300?text=Electoral+Reforms',
      source: 'NG Politics Daily',
      timestamp: DateTime.now(),
      viewCount: 1250,
      likes: 342,
      dislikes: 28,
      summary: 'Electoral reforms announced by NEC',
    ),
    Post(
      id: _uuid.v4(),
      title: 'Election 2023: Live Results Dashboard',
      content: 'Follow real-time results from the 2023 elections. Track presidential, gubernatorial, and local government elections across all states.',
      category: 'Elections',
      imageUrl: 'https://via.placeholder.com/400x300?text=Live+Results',
      source: 'Federal Affairs',
      timestamp: DateTime.now().subtract(Duration(hours: 1)),
      viewCount: 5420,
      likes: 1200,
      dislikes: 85,
      summary: 'Live election results dashboard',
    ),
    Post(
      id: _uuid.v4(),
      title: 'Voting Now Open: Presidential Elections',
      content: 'Voting is now live for the presidential elections. All registered voters can participate. Visit your designated polling units.',
      category: 'Voting',
      imageUrl: 'https://via.placeholder.com/400x300?text=Vote+Now',
      source: 'Admin',
      timestamp: DateTime.now().subtract(Duration(hours: 2)),
      viewCount: 8900,
      likes: 2100,
      dislikes: 120,
      summary: 'Presidential voting is now open',
    ),
    Post(
      id: _uuid.v4(),
      title: 'Youth Participation Record: 42% in Elections',
      content: 'Young voters have shown unprecedented participation this election season, with 42% turnout among ages 18-35. A historic milestone for Nigeria.',
      category: 'Politics',
      imageUrl: 'https://via.placeholder.com/400x300?text=Youth+Vote',
      source: 'Admin',
      timestamp: DateTime.now().subtract(Duration(hours: 3)),
      viewCount: 3210,
      likes: 876,
      dislikes: 34,
      summary: 'Youth voter turnout hits 42%',
    ),
    Post(
      id: _uuid.v4(),
      title: 'Governance: Economic Policies Under Review',
      content: 'The government releases quarterly review of economic policies. Focus on inflation control, job creation, and infrastructure development.',
      category: 'Governance',
      imageUrl: 'https://via.placeholder.com/400x300?text=Economic+Policy',
      source: 'Admin',
      timestamp: DateTime.now().subtract(Duration(hours: 4)),
      viewCount: 2100,
      likes: 512,
      dislikes: 92,
      summary: 'Economic policies under quarterly review',
    ),
    Post(
      id: _uuid.v4(),
      title: 'Federal Budget: 5.3 Trillion Naira Allocation',
      content: 'The National Assembly approves 5.3 trillion naira federal budget. Major allocations to education, healthcare, and infrastructure development.',
      category: 'Governance',
      imageUrl: 'https://via.placeholder.com/400x300?text=Budget',
      source: 'Admin',
      timestamp: DateTime.now().subtract(Duration(hours: 5)),
      viewCount: 4560,
      likes: 1100,
      dislikes: 210,
      summary: 'Federal budget approved at 5.3 trillion naira',
    ),
  ];

  for (var post in posts) {
    await db.addPost(post);
  }
  logger.i('✅ Added ${posts.length} sample posts');
}

Future<void> _initializePresidentialCandidates(DatabaseService db) async {
  final candidates = [
    PresidentialCandidate(
      id: _uuid.v4(),
      name: 'Bola Ahmed Tinubu',
      party: 'APC',
      votes: 8850000,
      imageUrl: 'https://via.placeholder.com/200x200?text=Tinubu',
    ),
    PresidentialCandidate(
      id: _uuid.v4(),
      name: 'Atiku Abubakar',
      party: 'PDP',
      votes: 6730000,
      imageUrl: 'https://via.placeholder.com/200x200?text=Atiku',
    ),
    PresidentialCandidate(
      id: _uuid.v4(),
      name: 'Peter Obi',
      party: 'LP',
      votes: 4220000,
      imageUrl: 'https://via.placeholder.com/200x200?text=PeterObi',
    ),
    PresidentialCandidate(
      id: _uuid.v4(),
      name: 'Rabiu Kwankwaso',
      party: 'NNPP',
      votes: 1890000,
      imageUrl: 'https://via.placeholder.com/200x200?text=Kwankwaso',
    ),
  ];

  for (var candidate in candidates) {
    await db.addPresidentialCandidate(candidate);
  }
  logger.i('✅ Added ${candidates.length} sample presidential candidates');
}

Future<void> _initializeGovernorCandidates(DatabaseService db) async {
  final states = ['Lagos', 'Kano', 'Rivers', 'Federal Capital Territory', 'Enugu'];

  for (var state in states) {
    final candidates = [
      GovernorCandidate(
        id: _uuid.v4(),
        name: '${state} Candidate A',
        party: 'APC',
        state: state,
        votes: 1200000,
        imageUrl: 'https://via.placeholder.com/150x150?text=$state+A',
      ),
      GovernorCandidate(
        id: _uuid.v4(),
        name: '${state} Candidate B',
        party: 'PDP',
        state: state,
        votes: 890000,
        imageUrl: 'https://via.placeholder.com/150x150?text=$state+B',
      ),
      GovernorCandidate(
        id: _uuid.v4(),
        name: '${state} Candidate C',
        party: 'LP',
        state: state,
        votes: 450000,
        imageUrl: 'https://via.placeholder.com/150x150?text=$state+C',
      ),
    ];

    for (var candidate in candidates) {
      await db.addGovernorCandidate(candidate);
    }
  }
  logger.i('✅ Added governor candidates for ${states.length} states');
}

Future<void> _initializeLGACandidates(DatabaseService db) async {
  final lgas = [
    {'state': 'Lagos', 'lga': 'Ikeja', 'count': 3},
    {'state': 'Lagos', 'lga': 'Lekki', 'count': 3},
    {'state': 'Kano', 'lga': 'Kano Municipal', 'count': 3},
    {'state': 'Rivers', 'lga': 'Port Harcourt', 'count': 3},
  ];

  int totalAdded = 0;
  for (var lga in lgas) {
    for (int i = 1; i <= (lga['count'] as int); i++) {
      final candidate = LGACandidate(
        id: _uuid.v4(),
        name: '${lga['lga']} Chairman Candidate $i',
        party: ['APC', 'PDP', 'LP'][i - 1],
        state: lga['state'] as String,
        lga: lga['lga'] as String,
        votes: (1000000 / i).toInt(),
        imageUrl: 'https://via.placeholder.com/120x120?text=LGA$i',
      );
      await db.addLGACandidate(candidate);
      totalAdded++;
    }
  }
  logger.i('✅ Added $totalAdded sample LGA candidates');
}

Future<void> _initializeReforms(DatabaseService db) async {
  final reforms = [
    PoliticalReform(
      id: _uuid.v4(),
      title: 'Electoral Process Modernization',
      description: 'Implement electronic voting systems and real-time result tracking nationwide',
      supportVotes: 450000,
      opposeVotes: 120000,
      neutralVotes: 89000,
    ),
    PoliticalReform(
      id: _uuid.v4(),
      title: 'Term Limit Review',
      description: 'Review and strengthen term limit provisions for political offices',
      supportVotes: 380000,
      opposeVotes: 210000,
      neutralVotes: 145000,
    ),
    PoliticalReform(
      id: _uuid.v4(),
      title: 'Anti-Corruption Measures',
      description: 'Strengthen anti-corruption agencies and enforcement mechanisms',
      supportVotes: 520000,
      opposeVotes: 95000,
      neutralVotes: 112000,
    ),
    PoliticalReform(
      id: _uuid.v4(),
      title: 'Fiscal Federalism Amendment',
      description: 'Adjust revenue sharing between federal and state governments',
      supportVotes: 290000,
      opposeVotes: 340000,
      neutralVotes: 198000,
    ),
  ];

  for (var reform in reforms) {
    await db.addReform(reform);
  }
  logger.i('✅ Added ${reforms.length} sample reforms');
}