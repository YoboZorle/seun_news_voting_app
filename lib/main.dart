import 'package:flutter/material.dart';
import 'package:naijanews/services/data_initialization_service.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';
import 'services/background_event_service.dart';
import 'providers/posts_provider.dart';
import 'providers/voting_provider.dart';
import 'providers/stats_provider.dart';
import 'screens/home_screen.dart';
import 'screens/voting_screen.dart';
import 'screens/statistics_screen.dart';

final logger = Logger();

void main() async {
  // ✅ FIXED: Ensure widget binding before any async calls
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // ✅ Initialize Database Service (required)
    logger.i('🔄 Initializing DatabaseService...');
    await DatabaseService().init();
    logger.i('✅ DatabaseService initialized');

    // ✅ CRITICAL: Initialize sample data on first launch
    // This populates the database with posts, candidates, and reforms
    logger.i('🔄 Initializing sample data...');
    await initializeSampleData(DatabaseService());
    logger.i('✅ Sample data initialized');

  } catch (e) {
    logger.e('❌ DatabaseService error: $e');
    // Continue even if DB fails
  }

  try {
    // ✅ FIXED: Initialize Notifications WITHOUT blocking (non-blocking with .catchError)
    logger.i('🔄 Initializing NotificationService...');
    NotificationService().init().then((_) {
      logger.i('✅ NotificationService initialized');
    }).catchError((e) {
      logger.e('⚠️ NotificationService error (non-blocking): $e');
      // Continue even if notifications fail
    });
  } catch (e) {
    logger.e('⚠️ NotificationService error: $e');
  }

  // ✅ Run app immediately (don't wait for notifications)
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late BackgroundEventService _backgroundEventService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Start continuous real-time events
      _backgroundEventService = BackgroundEventService();
      await _backgroundEventService.startContinuousEvents();

      logger.i('✅ App initialized with real-time events');
    } catch (e) {
      logger.e('❌ Error initializing app: $e');
      // App continues even if events fail
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        logger.i('⏸️ App paused - events continue in background');
        break;
      case AppLifecycleState.resumed:
        logger.i('▶️ App resumed - events active');
        break;
      case AppLifecycleState.detached:
        logger.i('🛑 App detached');
        _backgroundEventService.stopContinuousEvents();
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _backgroundEventService.stopContinuousEvents();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ FIXED: Provide all necessary providers
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PostsProvider()),
        ChangeNotifierProvider(create: (_) => VotingProvider()),
        ChangeNotifierProvider(create: (_) => StatsProvider()),
      ],
      child: MaterialApp(
        title: 'NG News',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
          ),
        ),
        debugShowCheckedModeBanner: false,
        home: const MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    HomeScreen(),
    VotingScreen(),
    StatisticsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'News Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.how_to_vote),
            label: 'Vote Now',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Analytics',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue.shade700,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        elevation: 8,
      ),
    );
  }
}