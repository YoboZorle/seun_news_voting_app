import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';
import 'services/background_event_service.dart';
import 'services/data_initialization_service.dart';
import 'providers/posts_provider.dart';
import 'providers/voting_provider.dart';
import 'providers/stats_provider.dart';
import 'screens/home_screen.dart';
import 'screens/voting_screen.dart';
import 'screens/statistics_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Step 1: Initialize Database (STATIC - shared instance)
  await DatabaseService.initialize();

  // ✅ Step 2: Initialize Data (Load sample posts, candidates, reforms)
  final dataInitService = DataInitializationService();
  await dataInitService.initializeIfNeeded();

  // ✅ Step 3: Initialize Notifications with error handling
  final notificationService = NotificationService();
  try {
    await notificationService.init();
  } catch (e) {
    print('⚠️ Notification initialization failed: $e');
    // App continues even if notifications fail
  }

  // ✅ Step 4: Initialize Background Events
  BackgroundEventService().startAllTimers();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PostsProvider()),
        ChangeNotifierProvider(create: (_) => VotingProvider()),
        ChangeNotifierProvider(create: (_) => StatsProvider()),
      ],
      child: MaterialApp(
        title: 'NaijaNews',
        theme: AppTheme.lightTheme,
        home: const MainScreen(),
        routes: {
          '/voting': (_) => const VotingScreen(),
          '/statistics': (_) => const StatisticsScreen(),
        },
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

  final List<Widget> _pages = [
    const HomeScreen(),
    const VotingScreen(),
    const StatisticsScreen(),
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
        title: const Text('NaijaNews'),
        centerTitle: true,
        backgroundColor: AppTheme.primaryOrange,
        elevation: 0,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.how_to_vote),
            label: 'Vote',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
        ],
      ),
    );
  }
}
