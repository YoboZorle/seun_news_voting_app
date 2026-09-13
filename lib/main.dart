import 'package:flutter/material.dart';
import 'package:naijanews/providers/posts_provider.dart';
import 'package:naijanews/providers/stats_provider.dart';
import 'package:naijanews/providers/voting_provider.dart';
import 'package:naijanews/screens/home_screen.dart';
import 'package:naijanews/screens/post_detail_screen.dart';
import 'package:naijanews/screens/statistics_screen.dart';
import 'package:naijanews/screens/voting_screen.dart';
import 'package:naijanews/services/background_event_service.dart';
import 'package:naijanews/services/data_initialization_service.dart';
import 'package:naijanews/services/database_service.dart';
import 'package:naijanews/services/notification_service.dart';
import 'package:naijanews/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import 'models/app_models.dart';

final logger = Logger();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize database
    logger.i('📦 Initializing database...');
    await DatabaseService().init();
    logger.i('✅ Database initialized');

    // Initialize sample data
    logger.i('📝 Initializing sample data...');
    await initializeSampleData(DatabaseService());
    logger.i('✅ Sample data loaded');

    // Initialize notifications (with error handling)
    logger.i('📬 Initializing notifications...');
    try {
      await NotificationService().init(
        onNotificationTap: _handleNotificationPayload,
      );
      logger.i('✅ Notifications initialized');
    } catch (e) {
      logger.w('⚠️ Notification init failed (continuing anyway): $e');
    }

    // Start real-time events in background (don't wait for it)
    logger.i('🚀 Starting background event service...');
    BackgroundEventService().startContinuousEvents().then((_) {
      logger.i('✅ Background events started');
    }).catchError((e) {
      logger.w('⚠️ Background events failed (continuing): $e');
    });

    logger.i('✅ App initialization complete! Running app...');
  } catch (e, stackTrace) {
    logger.e('❌ Fatal error during initialization: $e');
    logger.e('Stack trace: $stackTrace');
  }

  runApp(const MyApp());
}

/// Handle notification taps and route to content
void _handleNotificationPayload(String payload) {
  logger.i('📲 Handling notification payload: $payload');

  try {
    final parts = payload.split(':');
    if (parts.isEmpty) return;

    final type = parts[0];

    switch (type) {
      case 'milestone':
        logger.i('→ Routing to statistics');
        navigatorKey.currentState?.pushNamed('/statistics');
        break;

      case 'breaking_news':
        logger.i('→ Routing to home');
        navigatorKey.currentState?.popUntil((route) => route.isFirst);
        break;

      case 'state_election':
        logger.i('→ Routing to voting');
        navigatorKey.currentState?.pushNamed('/voting');
        break;

      case 'lga_election':
        logger.i('→ Routing to voting');
        navigatorKey.currentState?.pushNamed('/voting');
        break;

      case 'post':
        if (parts.length > 1) {
          final postId = parts[1];
          logger.i('→ Routing to post: $postId');

          try {
            final db = DatabaseService();
            final post = db.getAllPosts().firstWhere(
                  (p) => p.id == postId,
              orElse: () => db.getAllPosts().isNotEmpty
                  ? db.getAllPosts().first
                  : Post(
                id: 'default',
                title: 'Post',
                content: 'Content',
                category: 'News',
                imageUrl: '',
                timestamp: DateTime.now(),
              ),
            );

            navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (context) => PostDetailScreen(post: post),
              ),
            );
          } catch (e) {
            logger.w('⚠️ Failed to open post: $e');
          }
        }
        break;

      default:
        logger.w('⚠️ Unknown payload type: $type');
    }
  } catch (e) {
    logger.e('❌ Error handling notification: $e');
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    logger.i('🎬 MyApp initialized');
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PostsProvider()),
        ChangeNotifierProvider(create: (_) => VotingProvider()),
        ChangeNotifierProvider(create: (_) => StatsProvider()),
      ],
      child: MaterialApp(
        title: 'NG News - Live Elections & Updates',
        theme: AppTheme.darkTheme,
        home: const MainScreen(),
        navigatorKey: navigatorKey,
        routes: {
          '/voting': (context) => const VotingScreen(),
          '/statistics': (context) => const StatisticsScreen(),
        },
      ),
    );
  }

  @override
  void dispose() {
    try {
      BackgroundEventService().stopContinuousEvents();
    } catch (e) {
      logger.w('⚠️ Error stopping background events: $e');
    }
    super.dispose();
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const VotingScreen(),
    const StatisticsScreen(),
  ];

  final List<String> _titles = [
    'Home',
    'Vote Now',
    'Statistics',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        elevation: 0,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.how_to_vote_rounded),
            label: 'Vote',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart_rounded),
            label: 'Stats',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}