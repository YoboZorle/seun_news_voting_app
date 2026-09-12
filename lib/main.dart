import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';
import 'services/post_generator_service.dart';
import 'providers/posts_provider.dart';
import 'providers/voting_provider.dart';
import 'providers/stats_provider.dart';
import 'screens/home_screen.dart';
import 'screens/voting_screen.dart';
import 'screens/statistics_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await DatabaseService().init();
  await NotificationService().init();
  await PostGeneratorService().generateInitialPosts();
  PostGeneratorService().startGeneratingPosts(interval: Duration(seconds: 45));
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nigerian News',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue), useMaterial3: true),
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => PostsProvider()),
          ChangeNotifierProvider(create: (_) => VotingProvider()),
          ChangeNotifierProvider(create: (_) => StatsProvider()),
        ],
        child: const MainScreen(),
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

  final screens = [const HomeScreen(), const VotingScreen(), const StatisticsScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.newspaper), label: 'News'),
          NavigationDestination(icon: Icon(Icons.how_to_vote), label: 'Vote'),
          NavigationDestination(icon: Icon(Icons.trending_up), label: 'Stats'),
        ],
      ),
    );
  }
}
