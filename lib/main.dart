import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'src/dashboard.dart';
import 'src/history_screen.dart';
import 'src/statistics_screen.dart';
import 'src/account_screen.dart';
import 'src/login_screen.dart';
import 'src/options_screen.dart';
import 'src/start_workout_screen.dart';
import 'src/widgets/colors.dart';
import 'src/general_settings_screen.dart';
import 'src/appearance_settings_screen.dart';
import 'src/preferences_settings_screen.dart';
import 'src/goals_settings_screen.dart';
import 'src/about_screen.dart';
import 'src/edit_profile_screen.dart';
import 'src/change_password_screen.dart';
import 'src/manage_account_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the database factory
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb; // Use web-specific factory
  } else if (io.Platform.isLinux || io.Platform.isWindows || io.Platform.isMacOS) {
    sqfliteFfiInit(); // Initialize FFI for desktop platforms
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workout App',
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 16, color: AppColors.textPrimary),
          bodyMedium: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: AppColors.secondary, // Color for selected items
          unselectedItemColor: AppColors.primary, // Color for unselected items
          backgroundColor: AppColors.background, // Background color of the BottomNavBar
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const Dashboard(),
        '/history': (context) => const HistoryScreen(),
        '/statistics': (context) => const StatisticsScreen(),
        '/options': (context) => const OptionsScreen(),
        '/profile': (context) => const AccountScreen(),
        '/login': (context) => const LoginScreen(),
        '/start_workout': (context) => StartWorkoutScreen(
              templateId: ModalRoute.of(context)!.settings.arguments as int,
            ),
        '/general_settings': (context) => const GeneralSettingsScreen(),
        '/appearance_settings': (context) => const AppearanceSettingsScreen(),
        '/preferences_settings': (context) => const PreferencesSettingsScreen(),
        '/goals_settings': (context) => const GoalsSettingsScreen(),
        '/about_settings': (context) => const AboutScreen(),
        '/edit_profile': (context) => const EditProfileScreen(),
        '/change_password': (context) => const ChangePasswordScreen(),
        '/manage_account': (context) => const ManageAccountScreen(),
      },
    );
  }
}
// Dead code database test - delete when not needed
/*
class DatabaseTestScreen extends StatelessWidget {
  const DatabaseTestScreen({super.key});

  Future<void> _testDatabase() async {
    final dbPath = await _getDatabasePath();
    final db = await databaseFactory.openDatabase(dbPath);

    // Create a table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Product (
        id INTEGER PRIMARY KEY,
        title TEXT
      )
    ''');

    // Insert data
    await db.insert('Product', {'title': 'Product 1'});
    await db.insert('Product', {'title': 'Product 2'});

    // Query data
    final result = await db.query('Product');
    print(result);

    await db.close();
  }

  Future<String> _getDatabasePath() async {
    if (kIsWeb) {
      return 'my_web_database.db'; // Web uses IndexedDB
    } else {
      final appDocumentsDir = await getApplicationDocumentsDirectory();
      return p.join(appDocumentsDir.path, 'my_database.db');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Database Test')),
      body: Center(
        child: ElevatedButton(
          onPressed: _testDatabase,
          child: const Text('Test Database'),
        ),
      ),
    );
  }
}
*/