import 'package:shared_preferences/shared_preferences.dart';

class DataInitializationService {
  Future<void> initializeIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final isInitialized = prefs.getBool('data_initialized') ?? false;

    if (!isInitialized) {
      // Initialize data
      await prefs.setBool('data_initialized', true);
    }
  }
}
