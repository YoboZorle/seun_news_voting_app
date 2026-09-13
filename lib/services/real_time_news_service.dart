import 'dart:async';
import 'dart:math';
import '../models/app_models.dart';

/// Real-time news service generating news every 8 seconds
class RealTimeNewsService {
  static final RealTimeNewsService _instance = RealTimeNewsService._internal();

  factory RealTimeNewsService() {
    return _instance;
  }

  RealTimeNewsService._internal();

  late Timer _timer;
  late StreamController<News> _newsStream;
  bool _initialized = false;
  final Random _random = Random();

  Stream<News> get newsStream => _newsStream.stream;

  // News templates for each category
  static const Map<String, List<Map<String, String>>> newsTemplates = {
    'politics': [
      {
        'title': 'Federal Government Announces New Economic Policy',
        'content': 'The government has unveiled a comprehensive economic reform package aimed at boosting growth.',
        'source': 'NaijaNews Politics',
        'image': 'https://images.unsplash.com/photo-1611532736179-6b0ba97d3fe5?w=400'
      },
      {
        'title': 'Senate Passes Landmark Education Bill',
        'content': 'Lawmakers approve significant changes to Nigeria\'s education sector.',
        'source': 'Politics Daily',
        'image': 'https://images.unsplash.com/photo-1552664730-d307ca884978?w=400'
      },
      {
        'title': 'State Elections: APC Maintains Strong Lead',
        'content': 'Latest polling shows APC with commanding lead in upcoming elections.',
        'source': 'Electoral Commission',
        'image': 'https://images.unsplash.com/photo-1516382799192-d611c375a126?w=400'
      },
      {
        'title': 'President Addresses Nation on Infrastructure',
        'content': 'Leadership calls for renewed focus on national infrastructure development.',
        'source': 'State House Media',
        'image': 'https://images.unsplash.com/photo-1552664730-d307ca884978?w=400'
      },
      {
        'title': 'National Assembly Debates Healthcare Reform',
        'content': 'Lawmakers discuss sweeping changes to the healthcare system.',
        'source': 'NASS News',
        'image': 'https://images.unsplash.com/photo-1576091160550-2173dba999ef?w=400'
      },
    ],
    'finance': [
      {
        'title': 'Naira Gains Ground Against Dollar',
        'content': 'Nigerian currency strengthens on improved foreign exchange supply.',
        'source': 'Financial Times Nigeria',
        'image': 'https://images.unsplash.com/photo-1551453895-acf2f546fb29?w=400'
      },
      {
        'title': 'Stock Market Hits New Record High',
        'content': 'NSE reaches unprecedented levels as investor confidence soars.',
        'source': 'Market Watch NG',
        'image': 'https://images.unsplash.com/photo-1611532736579-6b16e2b50449?w=400'
      },
      {
        'title': 'Central Bank Announces Interest Rate Decision',
        'content': 'Monetary policy committee makes new decision on benchmark rate.',
        'source': 'CBN News',
        'image': 'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?w=400'
      },
      {
        'title': 'Oil Prices Rally on Supply Concerns',
        'content': 'Crude oil surges as global supply tightens.',
        'source': 'Energy Africa',
        'image': 'https://images.unsplash.com/photo-1611532736515-6b16e2b50449?w=400'
      },
      {
        'title': 'Tech Sector Boom Attracts Global Investment',
        'content': 'Billions flowing into Nigeria\'s growing technology sector.',
        'source': 'Finance Weekly',
        'image': 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=400'
      },
    ],
    'tech': [
      {
        'title': 'Nigerian Startup Raises \$50M in Funding',
        'content': 'Lagos-based tech company secures massive investment round.',
        'source': 'TechCrunch Africa',
        'image': 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=400'
      },
      {
        'title': '5G Network Rolls Out Across Major Cities',
        'content': 'Telecom operators launch lightning-fast mobile networks.',
        'source': 'Tech Daily NG',
        'image': 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=400'
      },
      {
        'title': 'AI Revolution Transforming Nigerian Industries',
        'content': 'Artificial intelligence adoption accelerating across sectors.',
        'source': 'Innovation Hub',
        'image': 'https://images.unsplash.com/photo-1677442d019cecf8d5cfc80086528cbf?w=400'
      },
      {
        'title': 'Cybersecurity Alert: Banks Strengthen Defenses',
        'content': 'Financial institutions invest heavily in security infrastructure.',
        'source': 'Tech Security',
        'image': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400'
      },
      {
        'title': 'Silicon Valley Eyes Nigerian Tech Talent',
        'content': 'Major tech giants recruiting from Nigeria\'s thriving startup scene.',
        'source': 'Global Tech News',
        'image': 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=400'
      },
    ],
    'entertainment': [
      {
        'title': 'Afrobeats Artist Breaks Streaming Records',
        'content': 'Nigerian musician shatters global streaming milestones.',
        'source': 'Entertainment Weekly',
        'image': 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400'
      },
      {
        'title': 'Nollywood Production Wins International Award',
        'content': 'Nigerian film makes history at prestigious film festival.',
        'source': 'Film Africa',
        'image': 'https://images.unsplash.com/photo-1485095329183-d0797cdc5676?w=400'
      },
      {
        'title': 'Music Concert Draws Record Crowds',
        'content': 'Festival becomes largest gathering in entertainment history.',
        'source': 'Event News NG',
        'image': 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=400'
      },
      {
        'title': 'Comedy Show Debuts on Streaming Platform',
        'content': 'Nigerian comedians reach global audience with new special.',
        'source': 'Entertainment Africa',
        'image': 'https://images.unsplash.com/photo-1514306688772-e01b5aa56f52?w=400'
      },
      {
        'title': 'Fashion Week Showcases Nigerian Designers',
        'content': 'Local designers take center stage at international event.',
        'source': 'Fashion Digest',
        'image': 'https://images.unsplash.com/photo-1523293182086-7651a899d37f?w=400'
      },
    ],
    'sports': [
      {
        'title': 'National Team Qualifies for World Cup',
        'content': 'Nigeria secures spot in premier international football tournament.',
        'source': 'Sports News Nigeria',
        'image': 'https://images.unsplash.com/photo-1461896836934-ffe607ba8211?w=400'
      },
      {
        'title': 'Olympic Champion Returns Home to Hero\'s Welcome',
        'content': 'Decorated athlete celebrated after historic achievement.',
        'source': 'Sports Daily',
        'image': 'https://images.unsplash.com/photo-1508098682722-e7c63dc13144?w=400'
      },
      {
        'title': 'Local Basketball League Breaks Viewership Records',
        'content': 'Basketball gaining massive popularity across the nation.',
        'source': 'Hoop Nigeria',
        'image': 'https://images.unsplash.com/photo-1546519638-68711109d298?w=400'
      },
      {
        'title': 'Tennis Star Reaches Grand Slam Final',
        'content': 'Nigerian player advances to major championship tournament.',
        'source': 'Tennis Africa',
        'image': 'https://images.unsplash.com/photo-1554224311-beee415c15cb?w=400'
      },
      {
        'title': 'Athletic Championships Set New Records',
        'content': 'National track and field event produces multiple records.',
        'source': 'Athletics Today',
        'image': 'https://images.unsplash.com/photo-1461896836934-ffe607ba8211?w=400'
      },
    ],
    'health': [
      {
        'title': 'Healthcare System Gets Major Upgrade',
        'content': 'Government invests in modern medical infrastructure.',
        'source': 'Health Monitor NG',
        'image': 'https://images.unsplash.com/photo-1576091160550-2173dba999ef?w=400'
      },
      {
        'title': 'New Hospital Opens in Rural Area',
        'content': 'Healthcare access improves for underserved communities.',
        'source': 'Medical News Nigeria',
        'image': 'https://images.unsplash.com/photo-1579154204601-01d3f2d751a0?w=400'
      },
      {
        'title': 'Vaccination Campaign Achieves Milestone',
        'content': 'National immunization program reaches significant target.',
        'source': 'Public Health NG',
        'image': 'https://images.unsplash.com/photo-1579154204601-01d3f2d751a0?w=400'
      },
      {
        'title': 'Medical Researchers Develop New Treatment',
        'content': 'Nigerian scientists make breakthrough in disease prevention.',
        'source': 'Science Daily Africa',
        'image': 'https://images.unsplash.com/photo-1576091160399-1122a606f0d3?w=400'
      },
      {
        'title': 'Wellness Initiative Promotes Healthy Lifestyle',
        'content': 'Government launches campaign for public health awareness.',
        'source': 'Wellness Africa',
        'image': 'https://images.unsplash.com/photo-1517836357463-d25ddfcbf042?w=400'
      },
    ],
  };

  void initialize() {
    if (_initialized) return;
    _initialized = true;

    _newsStream = StreamController<News>.broadcast();

    // Start generating news every 8 seconds
    _timer = Timer.periodic(const Duration(seconds: 8), (_) {
      final news = _generateRandomNews();
      _newsStream.add(news);
    });
  }

  /// Generate random news from templates
  News _generateRandomNews() {
    final categories = newsTemplates.keys.toList();
    final randomCategory = categories[_random.nextInt(categories.length)];
    final templates = newsTemplates[randomCategory]!;
    final template = templates[_random.nextInt(templates.length)];

    return News(
      title: template['title']!,
      content: template['content']!,
      category: randomCategory,
      imageUrl: template['image']!,
      source: template['source']!,
      likes: 100 + _random.nextInt(3000),
      dislikes: 10 + _random.nextInt(500),
      shares: 50 + _random.nextInt(1000),
      viewCount: 1000 + _random.nextInt(50000),
    );
  }

  void dispose() {
    _timer.cancel();
    _newsStream.close();
  }
}
