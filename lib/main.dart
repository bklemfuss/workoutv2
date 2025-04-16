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
import 'src/theme/app_theme.dart'; // Import the theme file
import 'src/edit_profile_screen.dart';
import 'src/change_password_screen.dart';
import 'src/manage_account_screen.dart';
import 'src/in_progress_workout_screen.dart';
import 'src/start_workout_screen.dart';
import 'src/workout_summary.dart';
import 'src/create_workout_screen.dart';
import 'src/providers/theme_provider.dart';
import 'src/providers/unit_provider.dart'; // Import UnitProvider

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the database factory
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb; // Use web-specific factory
  } else if (
    io.Platform.isLinux || io.Platform.isWindows || io.Platform.isMacOS) {
    sqfliteFfiInit(); // Initialize FFI for desktop platforms
    databaseFactory = databaseFactoryFfi;
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()..loadPreferences()),
        ChangeNotifierProvider(create: (context) => UnitProvider()..loadPreferences()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Workout App',
      theme: themeProvider.currentTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const Dashboard(),
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
        '/workout_summary': (context) {
          final workoutId = ModalRoute.of(context)!.settings.arguments as int;
          return WorkoutSummaryScreen(workoutId: workoutId);
        },
        '/create_workout': (context) => const CreateWorkoutScreen(),
      },
    );
  }
}

