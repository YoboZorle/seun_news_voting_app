import 'package:uuid/uuid.dart';

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
  final String summary;

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
    required this.summary,
  });

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).ceil()}w ago';
    } else {
      return '${(difference.inDays / 30).ceil()}m ago';
    }
  }

  double get approvalRating {
    final total = likes + dislikes;
    if (total == 0) return 0.0;
    return (likes / total) * 100;
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
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      category: map['category'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
      viewCount: map['viewCount'] ?? 0,
      likes: map['likes'] ?? 0,
      dislikes: map['dislikes'] ?? 0,
      source: map['source'] ?? 'NG News',
      summary: map['summary'] ?? '',
    );
  }
}

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
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      party: map['party'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      votes: map['votes'] ?? 0,
    );
  }
}

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
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      party: map['party'] ?? '',
      state: map['state'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      votes: map['votes'] ?? 0,
    );
  }
}

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
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      party: map['party'] ?? '',
      state: map['state'] ?? '',
      lga: map['lga'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      votes: map['votes'] ?? 0,
    );
  }
}

class Reform {
  final String id;
  final String title;
  final String description;
  final String status;
  final double progress;

  Reform({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.progress,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'progress': progress,
    };
  }

  factory Reform.fromMap(Map<String, dynamic> map) {
    return Reform(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      status: map['status'] ?? 'Planned',
      progress: (map['progress'] ?? 0.0).toDouble(),
    );
  }
}

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
}