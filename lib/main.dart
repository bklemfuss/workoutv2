import 'dart:io' as io;
import 'package:flutter/foundation.dart'; // For kIsWeb and defaultTargetPlatform
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:provider/provider.dart';
import 'src/dashboard.dart';
import 'src/history_screen.dart';
import 'src/statistics_screen.dart';
import 'src/account_screen.dart';
import 'src/login_screen.dart';
import 'src/options_screen.dart';
import 'src/edit_profile_screen.dart';
import 'src/change_password_screen.dart';
import 'src/manage_account_screen.dart';
import 'src/in_progress_workout_screen.dart';
import 'src/start_workout_screen.dart';
import 'src/create_workout_screen.dart';
import 'src/providers/theme_provider.dart';
import 'src/providers/unit_provider.dart'; // Import UnitProvider
import 'src/providers/goal_provider.dart'; // Import GoalProvider
import 'src/post_workout_screen.dart';
import 'src/exercises_screen.dart'; // <-- Add this import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Add logging for startup
  debugPrint('main: Starting app initialization');

  try {
    // Initialize the database factory
    if (kIsWeb) {
      debugPrint('main: Detected web platform, using databaseFactoryFfiWeb');
      databaseFactory = databaseFactoryFfiWeb; // Use web-specific factory
    } else if (
      io.Platform.isLinux || io.Platform.isWindows || io.Platform.isMacOS) {
      debugPrint('main: Detected desktop platform, initializing sqfliteFfi');
      sqfliteFfiInit(); // Initialize FFI for desktop platforms
      databaseFactory = databaseFactoryFfi;
    }
  } catch (e, stack) {
    debugPrint('main: Error during database factory initialization: $e\n$stack');
  }

  try {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) {
            debugPrint('main: Initializing ThemeProvider');
            return ThemeProvider()..loadPreferences();
          }),
          ChangeNotifierProvider(create: (context) {
            debugPrint('main: Initializing UnitProvider');
            return UnitProvider()..loadPreferences();
          }),
          ChangeNotifierProvider(create: (context) {
            debugPrint('main: Initializing GoalProvider');
            return GoalProvider()..loadPreferences();
          }),
        ],
        child: const MyApp(),
      ),
    );
    debugPrint('main: runApp called');
  } catch (e, stack) {
    debugPrint('main: Error during runApp: $e\n$stack');
    rethrow;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('MyApp: build called');
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Workout App',
      theme: themeProvider.currentTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const Dashboard(), // Initial route for the Dashboard
        '/dashboard': (context) => const Dashboard(), // Explicit named route for the Dashboard
        '/history': (context) => const HistoryScreen(),
        '/statistics': (context) => const StatisticsScreen(),
        '/options': (context) => const OptionsScreen(),
        '/profile': (context) => const AccountScreen(),
        '/login': (context) => const LoginScreen(),
        '/start_workout': (context) {
          final templateId = ModalRoute.of(context)!.settings.arguments as int;
          return StartWorkoutScreen(templateId: templateId);
        },
        '/edit_profile': (context) {
          final user = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return EditProfileScreen(user: user);
        },
        '/change_password': (context) => const ChangePasswordScreen(),
        '/manage_account': (context) => const ManageAccountScreen(),
        '/in_progress_workout': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          final templateId = args['template_id'] as int;
          final exercises = args['exercises'] as List<Map<String, dynamic>>;
          return InProgressWorkoutScreen(templateId: templateId, exercises: exercises);
        },
        '/workout_summary': (context) => const PostWorkoutScreen(),
        '/create_workout': (context) => const CreateWorkoutScreen(),
        '/exercises': (context) => const ExercisesScreen(), // <-- Add this route
      },
    );
  }
}

