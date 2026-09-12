import 'dart:convert';

/// POST MODEL - News Article/Story
class Post {
  final String id;
  final String title;
  final String content;
  final String category; // Politics, Sports, Finance, Entertainment, Technology
  final String imageUrl;
  final DateTime timestamp;
  int viewCount;
  int likes;
  int dislikes;
  final String source;
  String? summary;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.imageUrl,
    required this.timestamp,
    this.viewCount = 0,
    this.likes = 0,
    this.dislikes = 0,
    this.source = 'NG News',
    this.summary,
  });

  int get engagement => likes + dislikes + viewCount;

  double get approvalRating {
    final total = likes + dislikes;
    if (total == 0) return 0.0;
    return (likes / total) * 100;
  }

  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    
    return timestamp.toString().split(' ')[0];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'imageUrl': imageUrl,
      'timestamp': timestamp.toIso8601String(),
      'viewCount': viewCount,
      'likes': likes,
      'dislikes': dislikes,
      'source': source,
      'summary': summary,
    };
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      category: json['category'] as String,
      imageUrl: json['imageUrl'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      viewCount: json['viewCount'] as int? ?? 0,
      likes: json['likes'] as int? ?? 0,
      dislikes: json['dislikes'] as int? ?? 0,
      source: json['source'] as String? ?? 'NG News',
      summary: json['summary'] as String?,
    );
  }

  Post copyWith({
    String? id,
    String? title,
    String? content,
    String? category,
    String? imageUrl,
    DateTime? timestamp,
    int? viewCount,
    int? likes,
    int? dislikes,
    String? source,
    String? summary,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      timestamp: timestamp ?? this.timestamp,
      viewCount: viewCount ?? this.viewCount,
      likes: likes ?? this.likes,
      dislikes: dislikes ?? this.dislikes,
      source: source ?? this.source,
      summary: summary ?? this.summary,
    );
  }
}

/// VOTE MODEL - Track post engagement
class Vote {
  final String id;
  final String postId;
  final bool isLike;
  final DateTime timestamp;

  Vote({
    required this.id,
    required this.postId,
    required this.isLike,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'isLike': isLike,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Vote.fromJson(Map<String, dynamic> json) {
    return Vote(
      id: json['id'] as String,
      postId: json['postId'] as String,
      isLike: json['isLike'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

/// POLITICAL REFORM MODEL
class PoliticalReform {
  final String id;
  final String title;
  final String description;
  int supportVotes;
  int opposeVotes;
  int neutralVotes;

  PoliticalReform({
    required this.id,
    required this.title,
    required this.description,
    this.supportVotes = 0,
    this.opposeVotes = 0,
    this.neutralVotes = 0,
  });

  int get totalVotes => supportVotes + opposeVotes + neutralVotes;

  double get supportPercentage {
    if (totalVotes == 0) return 0.0;
    return (supportVotes / totalVotes) * 100;
  }

  double get opposePercentage {
    if (totalVotes == 0) return 0.0;
    return (opposeVotes / totalVotes) * 100;
  }

  double get neutralPercentage {
    if (totalVotes == 0) return 0.0;
    return (neutralVotes / totalVotes) * 100;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'supportVotes': supportVotes,
      'opposeVotes': opposeVotes,
      'neutralVotes': neutralVotes,
    };
  }

  factory PoliticalReform.fromJson(Map<String, dynamic> json) {
    return PoliticalReform(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      supportVotes: json['supportVotes'] as int? ?? 0,
      opposeVotes: json['opposeVotes'] as int? ?? 0,
      neutralVotes: json['neutralVotes'] as int? ?? 0,
    );
  }
}

/// POLITICAL CONTESTANT MODEL
class PoliticalContestant {
  final String id;
  final String name;
  final String party;
  final String imageUrl;
  final String position;
  int supportVotes;
  int opposeVotes;
  int neutralVotes;

  PoliticalContestant({
    required this.id,
    required this.name,
    required this.party,
    required this.imageUrl,
    required this.position,
    this.supportVotes = 0,
    this.opposeVotes = 0,
    this.neutralVotes = 0,
  });

  int get totalVotes => supportVotes + opposeVotes + neutralVotes;

  double get supportPercentage {
    if (totalVotes == 0) return 0.0;
    return (supportVotes / totalVotes) * 100;
  }

  double get opposePercentage {
    if (totalVotes == 0) return 0.0;
    return (opposeVotes / totalVotes) * 100;
  }

  double get neutralPercentage {
    if (totalVotes == 0) return 0.0;
    return (neutralVotes / totalVotes) * 100;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'party': party,
      'imageUrl': imageUrl,
      'position': position,
      'supportVotes': supportVotes,
      'opposeVotes': opposeVotes,
      'neutralVotes': neutralVotes,
    };
  }

  factory PoliticalContestant.fromJson(Map<String, dynamic> json) {
    return PoliticalContestant(
      id: json['id'] as String,
      name: json['name'] as String,
      party: json['party'] as String,
      imageUrl: json['imageUrl'] as String,
      position: json['position'] as String,
      supportVotes: json['supportVotes'] as int? ?? 0,
      opposeVotes: json['opposeVotes'] as int? ?? 0,
      neutralVotes: json['neutralVotes'] as int? ?? 0,
    );
  }
}

/// APP STATISTICS
class AppStatistics {
  int totalPosts;
  int totalViews;
  int totalVotes;
  int totalEngagements;
  int totalReformVotes;
  int totalContestantVotes;
  DateTime lastUpdated;

  AppStatistics({
    this.totalPosts = 0,
    this.totalViews = 0,
    this.totalVotes = 0,
    this.totalEngagements = 0,
    this.totalReformVotes = 0,
    this.totalContestantVotes = 0,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'totalPosts': totalPosts,
      'totalViews': totalViews,
      'totalVotes': totalVotes,
      'totalEngagements': totalEngagements,
      'totalReformVotes': totalReformVotes,
      'totalContestantVotes': totalContestantVotes,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory AppStatistics.fromJson(Map<String, dynamic> json) {
    return AppStatistics(
      totalPosts: json['totalPosts'] as int? ?? 0,
      totalViews: json['totalViews'] as int? ?? 0,
      totalVotes: json['totalVotes'] as int? ?? 0,
      totalEngagements: json['totalEngagements'] as int? ?? 0,
      totalReformVotes: json['totalReformVotes'] as int? ?? 0,
      totalContestantVotes: json['totalContestantVotes'] as int? ?? 0,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : DateTime.now(),
    );
  }
}

const List<String> CATEGORIES = [
  'Politics',
  'Sports',
  'Finance',
  'Entertainment',
  'Technology',
];

const Map<String, String> CATEGORY_EMOJIS = {
  'Politics': '🏛️',
  'Sports': '⚽',
  'Finance': '💰',
  'Entertainment': '🎬',
  'Technology': '🚀',
};

List<Post> generateSamplePosts() {
  final posts = [
    Post(
      id: 'post_1',
      title: 'Lagos State Launches ₦50 Billion Infrastructure Initiative',
      content: 'The Lagos State Government has officially launched a comprehensive infrastructure development project aimed at improving transportation, water supply, and power distribution across the state. This landmark initiative is expected to create thousands of jobs and boost economic activities in the region.',
      category: 'Politics',
      imageUrl: 'https://via.placeholder.com/800x400?text=Lagos+Infrastructure',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      source: 'NG Politics Daily',
      summary: 'Lagos launches major ₦50B infrastructure project',
    ),
    Post(
      id: 'post_2',
      title: 'National Assembly Approves New Economic Stimulus Package',
      content: 'In a landmark decision, the National Assembly has approved a new economic stimulus package designed to support small and medium-sized enterprises across Nigeria. The package includes tax incentives, subsidized loans, and skill development programs.',
      category: 'Politics',
      imageUrl: 'https://via.placeholder.com/800x400?text=Economic+Package',
      timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
      source: 'Federal Affairs',
      summary: 'Assembly approves economic stimulus package for SMEs',
    ),
    Post(
      id: 'post_3',
      title: 'Super Eagles Advances to AFCON Semi-Finals',
      content: 'Nigeria\'s national football team has successfully advanced to the semi-finals of the Africa Cup of Nations after a thrilling 2-1 victory against Egypt. The team displayed excellent teamwork and tactical awareness throughout the match.',
      category: 'Sports',
      imageUrl: 'https://via.placeholder.com/800x400?text=Super+Eagles',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      source: 'Sports Central',
      summary: 'Super Eagles beat Egypt 2-1 in quarter-final',
    ),
    Post(
      id: 'post_4',
      title: 'Nigerian Boxer Wins Continental Championship',
      content: 'In an impressive display of skill and determination, Nigerian boxer Adekunle Johnson won the African heavyweight boxing championship. This marks his third continental title in as many years.',
      category: 'Sports',
      imageUrl: 'https://via.placeholder.com/800x400?text=Boxing+Champion',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      source: 'Boxing Today',
      summary: 'Adekunle Johnson wins African heavyweight title',
    ),
    Post(
      id: 'post_5',
      title: 'Naira Appreciates Against Major Global Currencies',
      content: 'The Nigerian naira has strengthened against the US dollar and other major currencies following strong crude oil prices and improved forex reserves. Analysts expect the naira to continue strengthening.',
      category: 'Finance',
      imageUrl: 'https://via.placeholder.com/800x400?text=Naira+Strong',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      source: 'Financial Times Nigeria',
      summary: 'Naira strengthens as oil prices surge',
    ),
    Post(
      id: 'post_6',
      title: 'Stock Exchange Reaches All-Time High',
      content: 'The Nigerian Stock Exchange (NSE) has reached an all-time high closing index of 98,450 points, driven by strong earnings reports from major blue-chip companies. Banking and energy sectors led the gains.',
      category: 'Finance',
      imageUrl: 'https://via.placeholder.com/800x400?text=Stock+Exchange',
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      source: 'Market Watch',
      summary: 'NSE hits all-time high at 98,450 points',
    ),
    Post(
      id: 'post_7',
      title: 'Burna Boy Wins Global Music Award',
      content: 'Grammy award-winning Nigerian artist Burna Boy has won another international music award, solidifying his position as one of Africa\'s biggest music exports. The award recognizes his contributions to global music.',
      category: 'Entertainment',
      imageUrl: 'https://via.placeholder.com/800x400?text=Burna+Boy',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      source: 'Entertainment Hub',
      summary: 'Burna Boy wins international music award',
    ),
    Post(
      id: 'post_8',
      title: 'Nollywood Film Selected for Cannes Festival',
      content: 'A groundbreaking Nigerian film has been selected for screening at the prestigious Cannes Film Festival, bringing Nollywood to the world stage. This is a major achievement for African cinema.',
      category: 'Entertainment',
      imageUrl: 'https://via.placeholder.com/800x400?text=Nollywood+Cannes',
      timestamp: DateTime.now().subtract(const Duration(hours: 6)),
      source: 'Cinema News',
      summary: 'Nigerian film selected for Cannes Festival',
    ),
    Post(
      id: 'post_9',
      title: 'Nigerian Tech Startup Raises \$50 Million Funding',
      content: 'A promising Nigerian fintech startup has successfully raised \$50 million in Series B funding to expand operations across West Africa. The funding will support product development and market expansion.',
      category: 'Technology',
      imageUrl: 'https://via.placeholder.com/800x400?text=Tech+Startup',
      timestamp: DateTime.now().subtract(const Duration(hours: 7)),
      source: 'Tech Africa',
      summary: 'Nigerian fintech startup raises \$50M Series B',
    ),
    Post(
      id: 'post_10',
      title: 'Nigeria Launches 5G Network Nationwide',
      content: 'Major telecom providers in Nigeria have launched nationwide 5G network service, promising faster internet speeds and better connectivity. This will accelerate digital transformation across the country.',
      category: 'Technology',
      imageUrl: 'https://via.placeholder.com/800x400?text=5G+Network',
      timestamp: DateTime.now().subtract(const Duration(hours: 8)),
      source: 'Tech Tribune',
      summary: 'Nigeria launches nationwide 5G service',
    ),
  ];

  return posts;
}

List<PoliticalReform> generateSampleReforms() {
  return [
    PoliticalReform(
      id: 'reform_1',
      title: 'Universal Healthcare Initiative',
      description: 'A comprehensive plan to provide affordable healthcare services to all Nigerians regardless of economic status.',
      supportVotes: 4521,
      opposeVotes: 1247,
      neutralVotes: 1892,
    ),
    PoliticalReform(
      id: 'reform_2',
      title: 'Education Reform Bill 2024',
      description: 'Modernizing Nigeria\'s education system with emphasis on STEM, digital literacy, and vocational training.',
      supportVotes: 5234,
      opposeVotes: 892,
      neutralVotes: 1456,
    ),
    PoliticalReform(
      id: 'reform_3',
      title: 'Renewable Energy Transition',
      description: 'Shifting Nigeria\'s energy production from fossil fuels to renewable sources like solar and wind.',
      supportVotes: 3876,
      opposeVotes: 2134,
      neutralVotes: 2098,
    ),
    PoliticalReform(
      id: 'reform_4',
      title: 'Digital Economy Development',
      description: 'Supporting tech innovation and digital infrastructure to position Nigeria as Africa\'s tech hub.',
      supportVotes: 6123,
      opposeVotes: 567,
      neutralVotes: 987,
    ),
  ];
}

List<PoliticalContestant> generateSampleContestants() {
  return [
    PoliticalContestant(
      id: 'contestant_1',
      name: 'President Bola Tinubu',
      party: 'APC',
      imageUrl: 'https://via.placeholder.com/200x200?text=Tinubu',
      position: '2027 Presidential Candidate',
      supportVotes: 2847,
      opposeVotes: 1523,
      neutralVotes: 892,
    ),
    PoliticalContestant(
      id: 'contestant_2',
      name: 'Atiku Abubakar',
      party: 'PDP',
      imageUrl: 'https://via.placeholder.com/200x200?text=Atiku',
      position: '2027 Presidential Candidate',
      supportVotes: 3421,
      opposeVotes: 1087,
      neutralVotes: 756,
    ),
    PoliticalContestant(
      id: 'contestant_3',
      name: 'Peter Obi',
      party: 'LP',
      imageUrl: 'https://via.placeholder.com/200x200?text=PeterObi',
      position: '2027 Presidential Candidate',
      supportVotes: 2156,
      opposeVotes: 892,
      neutralVotes: 634,
    ),
    PoliticalContestant(
      id: 'contestant_4',
      name: 'Dr. Rabiu Kwankwaso',
      party: 'NNPP',
      imageUrl: 'https://via.placeholder.com/200x200?text=Kwankwaso',
      position: '2027 Presidential Candidate',
      supportVotes: 1234,
      opposeVotes: 567,
      neutralVotes: 423,
    ),
  ];
}
