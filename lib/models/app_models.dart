import 'package:uuid/uuid.dart';

// ============================================================
// NEWS MODEL WITH CATEGORIES & ENGAGEMENT
// ============================================================

class News {
  final String id;
  final String title;
  final String content;
  final String category; // politics, finance, tech, entertainment, sports, health
  final String imageUrl;
  final int likes;
  final int dislikes;
  final int shares;
  final int viewCount;
  final String source;
  final DateTime createdAt;

  News({
    String? id,
    required this.title,
    required this.content,
    required this.category,
    required this.imageUrl,
    this.likes = 0,
    this.dislikes = 0,
    this.shares = 0,
    this.viewCount = 0,
    required this.source,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  // Trending score calculation
  double get trendingScore => (likes * 2) + (shares * 3) + (viewCount * 0.5);

  // Engagement rate
  double get engagementRate => viewCount > 0 ? ((likes + shares) / viewCount) * 100 : 0;

  // Time ago text
  String get timeAgo {
    final duration = DateTime.now().difference(createdAt);
    if (duration.inSeconds < 60) {
      return '${duration.inSeconds}s ago';
    } else if (duration.inMinutes < 60) {
      return '${duration.inMinutes}m ago';
    } else if (duration.inHours < 24) {
      return '${duration.inHours}h ago';
    } else {
      return '${duration.inDays}d ago';
    }
  }

  // Copy with
  News copyWith({
    String? id,
    String? title,
    String? content,
    String? category,
    String? imageUrl,
    int? likes,
    int? dislikes,
    int? shares,
    int? viewCount,
    String? source,
    DateTime? createdAt,
  }) {
    return News(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      likes: likes ?? this.likes,
      dislikes: dislikes ?? this.dislikes,
      shares: shares ?? this.shares,
      viewCount: viewCount ?? this.viewCount,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// ============================================================
// VOTING MODELS
// ============================================================

class PresidentialCandidate {
  final String id;
  final String name;
  final String party;
  int votes;

  PresidentialCandidate({
    required this.id,
    required this.name,
    required this.party,
    this.votes = 0,
  });
}

class GovernorCandidate {
  final String id;
  final String name;
  final String party;
  final String state;
  int votes;

  GovernorCandidate({
    required this.id,
    required this.name,
    required this.party,
    required this.state,
    this.votes = 0,
  });
}

class LGACandidate {
  final String id;
  final String name;
  final String party;
  final String lga;
  int votes;

  LGACandidate({
    required this.id,
    required this.name,
    required this.party,
    required this.lga,
    this.votes = 0,
  });
}

class Reform {
  final String id;
  final String title;
  final String description;
  double progress;
  int votes;
  bool userVoted;

  Reform({
    required this.id,
    required this.title,
    required this.description,
    this.progress = 0,
    this.votes = 0,
    this.userVoted = false,
  });

  Reform copyWith({
    String? id,
    String? title,
    String? description,
    double? progress,
    int? votes,
    bool? userVoted,
  }) {
    return Reform(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      progress: progress ?? this.progress,
      votes: votes ?? this.votes,
      userVoted: userVoted ?? this.userVoted,
    );
  }
}

// ============================================================
// USER VOTE STATE MODEL
// ============================================================

class UserVoteState {
  bool hasVotedPresidential;
  String? votedPresidentialId;
  DateTime? lastVoteTime;

  UserVoteState({
    this.hasVotedPresidential = false,
    this.votedPresidentialId,
    this.lastVoteTime,
  });

  factory UserVoteState.fromMap(Map<String, dynamic> map) {
    return UserVoteState(
      hasVotedPresidential: map['hasVotedPresidential'] ?? false,
      votedPresidentialId: map['votedPresidentialId'],
      lastVoteTime: map['lastVoteTime'] != null ? DateTime.parse(map['lastVoteTime']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hasVotedPresidential': hasVotedPresidential,
      'votedPresidentialId': votedPresidentialId,
      'lastVoteTime': lastVoteTime?.toIso8601String(),
    };
  }
}

// ============================================================
// POST MODEL (Legacy)
// ============================================================

class Post {
  final String id;
  final String title;
  final String content;
  final String imageUrl;
  final int views;
  final DateTime createdAt;

  Post({
    String? id,
    required this.title,
    required this.content,
    required this.imageUrl,
    this.views = 0,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();
}
