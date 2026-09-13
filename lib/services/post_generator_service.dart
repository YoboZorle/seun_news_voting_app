import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';
import '../models/app_models.dart';
import 'database_service.dart';

final logger = Logger();
const uuid = Uuid();

class PostGeneratorService {
  final _random = Random();
  final DatabaseService db = DatabaseService();

  // ✅ GENERATE SAMPLE POSTS
  List<Post> generateSamplePosts() {
    return [
      // Politics - 3 posts
      Post(
        id: uuid.v4(),
        title: 'APC Strengthens Political Campaign Across Southern Nigeria',
        content: 'The All Progressives Congress (APC) has announced a comprehensive campaign strategy targeting key constituencies in the southern region of Nigeria. Party officials have outlined plans to strengthen grassroots organization and engage voters through town halls and community meetings.',
        category: 'Politics',
        imageUrl: 'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=500&h=300&fit=crop',
        timestamp: DateTime.now().subtract(Duration(hours: 2)),
        source: 'NG News Political Desk',
        summary: 'APC expands southern campaign efforts',
        likes: 142,
        dislikes: 18,
        viewCount: 3500,
      ),
      Post(
        id: uuid.v4(),
        title: 'PDP Announces Economic Stimulus Package for SMEs',
        content: 'The Peoples Democratic Party (PDP) has unveiled a detailed economic stimulus package aimed at supporting small and medium-sized enterprises (SMEs) across Nigeria. The initiative focuses on low-interest microloans and technical training programs.',
        category: 'Politics',
        imageUrl: 'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?w=500&h=300&fit=crop',
        timestamp: DateTime.now().subtract(Duration(hours: 4)),
        source: 'NG News Business Desk',
        summary: 'PDP unveils economic stimulus plan',
        likes: 89,
        dislikes: 23,
        viewCount: 2100,
      ),
      Post(
        id: uuid.v4(),
        title: 'Labour Party Launches Youth Leadership Initiative',
        content: 'The Labour Party has launched a comprehensive youth leadership development program to identify and train young political leaders. The initiative includes mentorship from senior party members and exposure to policy development processes.',
        category: 'Politics',
        imageUrl: 'https://images.unsplash.com/photo-1552664730-d307ca884978?w=500&h=300&fit=crop',
        timestamp: DateTime.now().subtract(Duration(hours: 6)),
        source: 'NG News Politics Desk',
        summary: 'LP focuses on youth leadership development',
        likes: 256,
        dislikes: 12,
        viewCount: 4200,
      ),

      // Entertainment - 3 posts
      Post(
        id: uuid.v4(),
        title: 'Wizkid Announces African Stadium Tour 2024',
        content: 'Grammy-winning artist Wizkid has announced an extensive African stadium tour featuring performances across major cities. The tour will include shows in Lagos, Accra, Johannesburg, and Cape Town with special guest appearances.',
        category: 'Entertainment',
        imageUrl: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=500&h=300&fit=crop',
        timestamp: DateTime.now().subtract(Duration(hours: 3)),
        source: 'Entertainment Weekly',
        summary: 'Wizkid announces continental tour',
        likes: 1203,
        dislikes: 45,
        viewCount: 12500,
      ),
      Post(
        id: uuid.v4(),
        title: 'AMVCA 2024: Nollywood Celebrates Film Excellence',
        content: 'The African Movie Academy Awards celebrated the best in African cinema this year. Nigerian films dominated nominations, with productions receiving recognition in multiple categories including Best Film, Best Director, and Best Actor.',
        category: 'Entertainment',
        imageUrl: 'https://images.unsplash.com/photo-1485846234645-a62644f84728?w=500&h=300&fit=crop',
        timestamp: DateTime.now().subtract(Duration(hours: 5)),
        source: 'Entertainment News',
        summary: 'Nigerian films shine at AMVCA 2024',
        likes: 567,
        dislikes: 34,
        viewCount: 6800,
      ),
      Post(
        id: uuid.v4(),
        title: 'Lagos Music Festival Attracts International Acts',
        content: 'The 2024 Lagos Music Festival has confirmed appearances from international music superstars alongside local artists. The three-day event will showcase diverse musical genres and celebrate African sound innovation.',
        category: 'Entertainment',
        imageUrl: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=500&h=300&fit=crop',
        timestamp: DateTime.now().subtract(Duration(hours: 8)),
        source: 'Music Events',
        summary: 'International acts confirmed for Lagos Music Fest',
        likes: 890,
        dislikes: 28,
        viewCount: 9100,
      ),

      // Finance - 3 posts
      Post(
        id: uuid.v4(),
        title: 'Naira Strengthens Against Dollar Amid Central Bank Reforms',
        content: 'The Nigerian Naira has strengthened significantly against the US Dollar following recent monetary policy reforms by the Central Bank of Nigeria. Analysts attribute the gains to improved foreign exchange management and increased inflows.',
        category: 'Finance',
        imageUrl: 'https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?w=500&h=300&fit=crop',
        timestamp: DateTime.now().subtract(Duration(hours: 1)),
        source: 'Financial Times Nigeria',
        summary: 'Naira strengthens on CBN reforms',
        likes: 456,
        dislikes: 67,
        viewCount: 5300,
      ),
      Post(
        id: uuid.v4(),
        title: 'Nigerian Stock Exchange Hits Record High in Q3',
        content: 'The Nigerian Stock Exchange (NSE) has reached a record high in the third quarter of 2024, driven by strong performance in banking and technology sectors. Market analysts project continued growth into the final quarter.',
        category: 'Finance',
        imageUrl: 'https://images.unsplash.com/photo-1460925895917-adf4e565db13?w=500&h=300&fit=crop',
        timestamp: DateTime.now().subtract(Duration(hours: 7)),
        source: 'Business Daily',
        summary: 'NSE records historic Q3 peak',
        likes: 623,
        dislikes: 41,
        viewCount: 7900,
      ),
      Post(
        id: uuid.v4(),
        title: 'CBN Expands eNaira Digital Currency Adoption',
        content: 'The Central Bank of Nigeria continues expanding eNaira adoption across the country with new merchant partnerships and consumer incentive programs. The digital currency is now accepted at over 50,000 merchant points nationwide.',
        category: 'Finance',
        imageUrl: 'https://images.unsplash.com/photo-1518544801212-7e1b89dda3f5?w=500&h=300&fit=crop',
        timestamp: DateTime.now().subtract(Duration(hours: 9)),
        source: 'Financial Daily',
        summary: 'eNaira adoption grows nationwide',
        likes: 234,
        dislikes: 89,
        viewCount: 3400,
      ),

      // Technology - 3 posts
      Post(
        id: uuid.v4(),
        title: 'Nigerian Tech Startup Secures \$5M Series A Funding',
        content: 'A Lagos-based fintech startup has secured \$5 million in Series A funding from prominent venture capital firms. The company focuses on payment solutions for emerging markets and plans to expand across West Africa.',
        category: 'Technology',
        imageUrl: 'https://images.unsplash.com/photo-1552664730-d307ca884978?w=500&h=300&fit=crop',
        timestamp: DateTime.now().subtract(Duration(hours: 4)),
        source: 'Tech Africa',
        summary: 'Nigerian startup raises \$5M funding',
        likes: 512,
        dislikes: 22,
        viewCount: 6200,
      ),
      Post(
        id: uuid.v4(),
        title: 'Africa Emerges as Top Tech Hub in Global Rankings',
        content: 'Recent global tech hub rankings show Africa, particularly Nigeria and Kenya, climbing the innovation index. The continent is now attracting increased investment in AI, blockchain, and software development sectors.',
        category: 'Technology',
        imageUrl: 'https://images.unsplash.com/photo-1516321318423-f06f70504c0a?w=500&h=300&fit=crop',
        timestamp: DateTime.now().subtract(Duration(hours: 6)),
        source: 'Global Tech News',
        summary: 'Africa ranks high in global tech innovation',
        likes: 789,
        dislikes: 31,
        viewCount: 8700,
      ),
      Post(
        id: uuid.v4(),
        title: 'AI Applications Transform Healthcare in Nigeria',
        content: 'Nigerian healthcare facilities are increasingly adopting artificial intelligence for diagnostics and treatment planning. New AI systems are improving accuracy in disease detection and reducing diagnostic time significantly.',
        category: 'Technology',
        imageUrl: 'https://images.unsplash.com/photo-1576091160550-112173f7f869?w=500&h=300&fit=crop',
        timestamp: DateTime.now().subtract(Duration(hours: 10)),
        source: 'Health Tech Nigeria',
        summary: 'AI revolutionizes Nigerian healthcare',
        likes: 654,
        dislikes: 19,
        viewCount: 7100,
      ),

      // General - 2 posts
      Post(
        id: uuid.v4(),
        title: 'Government Announces Flood Mitigation Strategy for 2024',
        content: 'The federal government has announced a comprehensive strategy to mitigate flood impacts across Nigeria. The plan includes infrastructure development, early warning systems, and community preparedness programs in flood-prone areas.',
        category: 'General',
        imageUrl: 'https://images.unsplash.com/photo-1559027615-cd4628902d4a?w=500&h=300&fit=crop',
        timestamp: DateTime.now().subtract(Duration(hours: 5)),
        source: 'Government News',
        summary: 'Flood mitigation strategy launched',
        likes: 423,
        dislikes: 56,
        viewCount: 5600,
      ),
      Post(
        id: uuid.v4(),
        title: 'Education Ministry Unveils Investment Initiative for Schools',
        content: 'The Ministry of Education has unveiled a comprehensive investment initiative aimed at improving educational infrastructure across Nigeria. The program includes renovation of school facilities, teacher training, and technology integration.',
        category: 'General',
        imageUrl: 'https://images.unsplash.com/photo-1427504494785-cdcdfeabc846?w=500&h=300&fit=crop',
        timestamp: DateTime.now().subtract(Duration(hours: 11)),
        source: 'Education Daily',
        summary: 'Education ministry invests in schools',
        likes: 567,
        dislikes: 45,
        viewCount: 6900,
      ),
    ];
  }

  // ✅ GENERATE PRESIDENTIAL CANDIDATES
  List<PresidentialCandidate> generatePresidentialCandidates() {
    return [
      PresidentialCandidate(
        id: uuid.v4(),
        name: 'Bola Ahmed Tinubu',
        party: 'APC',
        imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=250&fit=crop',
        votes: 8794826 + _random.nextInt(500000),
      ),
      PresidentialCandidate(
        id: uuid.v4(),
        name: 'Peter Obi',
        party: 'LP',
        imageUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&h=250&fit=crop',
        votes: 6101533 + _random.nextInt(500000),
      ),
      PresidentialCandidate(
        id: uuid.v4(),
        name: 'Atiku Abubakar',
        party: 'PDP',
        imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=250&fit=crop',
        votes: 6984520 + _random.nextInt(500000),
      ),
      PresidentialCandidate(
        id: uuid.v4(),
        name: 'Rabiu Magu Kwankwaso',
        party: 'NNPP',
        imageUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=200&h=250&fit=crop',
        votes: 1496687 + _random.nextInt(500000),
      ),
      PresidentialCandidate(
        id: uuid.v4(),
        name: 'Kola Ajayi',
        party: 'SDP',
        imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=250&fit=crop',
        votes: 385575 + _random.nextInt(500000),
      ),
    ];
  }

  // ✅ LOG GENERATED DATA
  void logGeneratedData() {
    logger.i('✅ Generated ${generateSamplePosts().length} sample posts');
    logger.i('✅ Generated ${generatePresidentialCandidates().length} presidential candidates');
  }
}