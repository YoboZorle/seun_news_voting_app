import 'dart:convert';

// POST MODEL
class Post {
  final String id;
  final String title;
  final String content;
  final String category;
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

  double get approvalRating {
    final total = likes + dislikes;
    if (total == 0) return 0.0;
    return (likes / total) * 100;
  }

  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    if (diff.inMinutes < 1) return 'just now';
    else if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    else if (diff.inHours < 24) return '${diff.inHours}h ago';
    else if (diff.inDays < 7) return '${diff.inDays}d ago';
    else if (diff.inDays < 30) return '${(diff.inDays / 7).ceil()}w ago';
    else return '${(diff.inDays / 30).ceil()}m ago';
  }

  Map<String, dynamic> toMap() {
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

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      category: map['category'] as String,
      imageUrl: map['imageUrl'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      viewCount: map['viewCount'] as int? ?? 0,
      likes: map['likes'] as int? ?? 0,
      dislikes: map['dislikes'] as int? ?? 0,
      source: map['source'] as String? ?? 'NG News',
      summary: map['summary'] as String?,
    );
  }
}

// PRESIDENTIAL CANDIDATE MODEL
class PresidentialCandidate {
  final String id;
  final String name;
  final String party;
  final String imageUrl;
  int votes;

  PresidentialCandidate({
    required this.id,
    required this.name,
    required this.party,
    required this.imageUrl,
    this.votes = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'party': party,
      'imageUrl': imageUrl,
      'votes': votes,
    };
  }

  factory PresidentialCandidate.fromMap(Map<String, dynamic> map) {
    return PresidentialCandidate(
      id: map['id'] as String,
      name: map['name'] as String,
      party: map['party'] as String,
      imageUrl: map['imageUrl'] as String,
      votes: map['votes'] as int? ?? 0,
    );
  }
}

// GOVERNOR CANDIDATE MODEL
class GovernorCandidate {
  final String id;
  final String name;
  final String party;
  final String state;
  final String imageUrl;
  int votes;

  GovernorCandidate({
    required this.id,
    required this.name,
    required this.party,
    required this.state,
    required this.imageUrl,
    this.votes = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'party': party,
      'state': state,
      'imageUrl': imageUrl,
      'votes': votes,
    };
  }

  factory GovernorCandidate.fromMap(Map<String, dynamic> map) {
    return GovernorCandidate(
      id: map['id'] as String,
      name: map['name'] as String,
      party: map['party'] as String,
      state: map['state'] as String,
      imageUrl: map['imageUrl'] as String,
      votes: map['votes'] as int? ?? 0,
    );
  }
}

// LGA CANDIDATE MODEL
class LGACandidate {
  final String id;
  final String name;
  final String party;
  final String state;
  final String lga;
  final String imageUrl;
  int votes;

  LGACandidate({
    required this.id,
    required this.name,
    required this.party,
    required this.state,
    required this.lga,
    required this.imageUrl,
    this.votes = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'party': party,
      'state': state,
      'lga': lga,
      'imageUrl': imageUrl,
      'votes': votes,
    };
  }

  factory LGACandidate.fromMap(Map<String, dynamic> map) {
    return LGACandidate(
      id: map['id'] as String,
      name: map['name'] as String,
      party: map['party'] as String,
      state: map['state'] as String,
      lga: map['lga'] as String,
      imageUrl: map['imageUrl'] as String,
      votes: map['votes'] as int? ?? 0,
    );
  }
}

// REFORM MODEL - WITH VOTING SUPPORT
class Reform {
  final String id;
  final String title;
  final String description;
  final String status;
  double progress;
  int? supportVotes;
  int? opposeVotes;
  int? neutralVotes;

  Reform({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    this.progress = 0.0,
    this.supportVotes = 0,
    this.opposeVotes = 0,
    this.neutralVotes = 0,
  });

  int get totalVotes =>
      (supportVotes ?? 0) + (opposeVotes ?? 0) + (neutralVotes ?? 0);

  double get supportPercentage {
    final total = totalVotes;
    if (total == 0) return 0.0;
    return ((supportVotes ?? 0) / total) * 100;
  }

  double get opposePercentage {
    final total = totalVotes;
    if (total == 0) return 0.0;
    return ((opposeVotes ?? 0) / total) * 100;
  }

  double get neutralPercentage {
    final total = totalVotes;
    if (total == 0) return 0.0;
    return ((neutralVotes ?? 0) / total) * 100;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'progress': progress,
      'supportVotes': supportVotes ?? 0,
      'opposeVotes': opposeVotes ?? 0,
      'neutralVotes': neutralVotes ?? 0,
    };
  }

  factory Reform.fromMap(Map<String, dynamic> map) {
    return Reform(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      status: map['status'] as String,
      progress: (map['progress'] as num?)?.toDouble() ?? 0.0,
      supportVotes: map['supportVotes'] as int? ?? 0,
      opposeVotes: map['opposeVotes'] as int? ?? 0,
      neutralVotes: map['neutralVotes'] as int? ?? 0,
    );
  }
}

// STATISTICS MODEL
class Statistics {
  final int totalPosts;
  final int totalViews;
  final int totalVotes;
  final int totalEngagements;

  Statistics({
    required this.totalPosts,
    required this.totalViews,
    required this.totalVotes,
    required this.totalEngagements,
  });

  double get engagementRate {
    if (totalPosts == 0) return 0.0;
    return totalEngagements / totalPosts;
  }
}
