import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart'; // For non-web platforms

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = await _getDatabasePath();

    // Check if the database already exists
    bool exists = await databaseExists(path);

    if (!exists) {
      // Copy the database from assets if it doesn't exist
      try {
        ByteData data = await rootBundle.load('assets/workout_db_test.db');
        List<int> bytes = data.buffer.asUint8List();
        await File(path).writeAsBytes(bytes);
      } catch (e) {
        if (kDebugMode) {
          print('Error copying database: $e');
        }
      }
    }

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<String> _getDatabasePath() async {
    if (kIsWeb) {
      return 'my_web_database.db'; // Web uses IndexedDB
    } else {
      final appDocumentsDir = await getApplicationDocumentsDirectory();
      return p.join(appDocumentsDir.path, 'workout_db_test.db');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create MuscleGroup table
    await db.execute('''
      CREATE TABLE MuscleGroup (
        muscle_group_id INTEGER PRIMARY KEY AUTOINCREMENT,
        Name TEXT
      )
    ''');

    // Create Template table
    await db.execute('''
      CREATE TABLE Template (
        template_id INTEGER PRIMARY KEY AUTOINCREMENT,
        template_name TEXT
      )
    ''');

    // Create TemplateExercise table
    await db.execute('''
      CREATE TABLE TemplateExercise (
        template_exercise_id INTEGER PRIMARY KEY AUTOINCREMENT,
        template_id INTEGER,
        exercise_id INTEGER,
        FOREIGN KEY (template_id) REFERENCES Template(template_id),
        FOREIGN KEY (exercise_id) REFERENCES Exercise(exercise_id)
      )
    ''');

    // Create Exercise table
    await db.execute('''
      CREATE TABLE Exercise (
        exercise_id INTEGER PRIMARY KEY AUTOINCREMENT,
        muscle_group_id INTEGER,
        name TEXT,
        Description TEXT,
        equipment INTEGER, -- 0 for false, 1 for true
        instructions TEXT,
        image_url TEXT,
        FOREIGN KEY (muscle_group_id) REFERENCES MuscleGroup(muscle_group_id)
      )
    ''');

    // Create User table
    await db.execute('''
      CREATE TABLE User (
        user_id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT UNIQUE,
        password TEXT,
        height INTEGER,
        weight INTEGER,
        date_of_birth TEXT,
        gender INTEGER, -- 0 for false, 1 for true
        notification_preferences INTEGER -- 0 for false, 1 for true
      )
    ''');

    // Create Workout table
    await db.execute('''
      CREATE TABLE Workout (
        workout_id INTEGER PRIMARY KEY AUTOINCREMENT,
        workout_template_id INTEGER,
        user_id INTEGER,
        date TEXT,
        FOREIGN KEY (workout_template_id) REFERENCES Template(template_id),
        FOREIGN KEY (user_id) REFERENCES User(user_id)
      )
    ''');

    // Create WorkoutExercise table
    await db.execute('''
      CREATE TABLE WorkoutExercise (
        workout_exercise_id INTEGER PRIMARY KEY AUTOINCREMENT,
        workout_id INTEGER,
        exercise_id INTEGER,
        sets INTEGER,
        reps INTEGER,
        weight REAL,
        FOREIGN KEY (workout_id) REFERENCES Workout(workout_id),
        FOREIGN KEY (exercise_id) REFERENCES Exercise(exercise_id)
      )
    ''');

    // Create BodyMeasurement table
    await db.execute('''
      CREATE TABLE BodyMeasurement (
        body_measurement_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        date TEXT,
        weight REAL,
        FOREIGN KEY (user_id) REFERENCES User(user_id)
      )
    ''');

    // Populate the database with sample data
    await insertSampleData(db);
  }

  Future<void> insertSampleData(Database db) async {
    // Insert sample Users
    await db.insert('User', {
      'user_id': 1,
      'name': 'John Doe',
      'email': 'john.doe@example.com',
      'password': 'password123',
      'height': 180,
      'weight': 75,
      'date_of_birth': '1990-01-01',
      'gender': 1,
      'notification_preferences': 1,
    });

    // Insert sample Templates
    await db.insert('Template', {'template_id': 1, 'template_name': 'Full Body Workout A'});
    await db.insert('Template', {'template_id': 2, 'template_name': 'Upper Body Strength'});
    await db.insert('Template', {'template_id': 3, 'template_name': 'Lower Body Endurance'});
    await db.insert('Template', {'template_id': 4, 'template_name': 'Core Stability'});

    // Insert sample MuscleGroups
    await db.insert('MuscleGroup', {'muscle_group_id': 1, 'Name': 'Chest'});
    await db.insert('MuscleGroup', {'muscle_group_id': 2, 'Name': 'Back'});
    await db.insert('MuscleGroup', {'muscle_group_id': 3, 'Name': 'Legs'});

    // Insert sample Exercises
    await db.insert('Exercise', {
      'exercise_id': 1,
      'muscle_group_id': 1,
      'name': 'Push-Up',
      'Description': 'A basic upper body exercise.',
      'equipment': 0,
      'instructions': 'Keep your back straight and lower yourself to the ground.',
      'image_url': 'https://example.com/push-up.png',
    });
    await db.insert('Exercise', {
      'exercise_id': 2,
      'muscle_group_id': 2,
      'name': 'Pull-Up',
      'Description': 'A basic back and biceps exercise.',
      'equipment': 0,
      'instructions': 'Pull yourself up until your chin is above the bar.',
      'image_url': 'https://example.com/pull-up.png',
    });
    await db.insert('Exercise', {
      'exercise_id': 3,
      'muscle_group_id': 3,
      'name': 'Squat',
      'Description': 'A basic lower body exercise.',
      'equipment': 0,
      'instructions': 'Lower your hips until your thighs are parallel to the ground.',
      'image_url': 'https://example.com/squat.png',
    });
    await db.insert('Exercise', {
      'exercise_id': 4,
      'muscle_group_id': 1,
      'name': 'Bench Press',
      'Description': 'A chest exercise using a barbell.',
      'equipment': 1,
      'instructions': 'Lower the barbell to your chest and press it back up.',
      'image_url': 'https://example.com/bench-press.png',
    });

    // Insert sample TemplateExercises
    await db.insert('TemplateExercise', {'template_exercise_id': 1, 'template_id': 1, 'exercise_id': 1});
    await db.insert('TemplateExercise', {'template_exercise_id': 2, 'template_id': 1, 'exercise_id': 2});
    await db.insert('TemplateExercise', {'template_exercise_id': 3, 'template_id': 2, 'exercise_id': 3});
    await db.insert('TemplateExercise', {'template_exercise_id': 4, 'template_id': 3, 'exercise_id': 4});

    // Insert sample Workouts
    await db.insert('Workout', {
      'workout_id': 1,
      'workout_template_id': 1,
      'user_id': 1,
      'date': '2025-04-08',
    });
    await db.insert('Workout', {
      'workout_id': 2,
      'workout_template_id': 2,
      'user_id': 1,
      'date': '2025-04-09',
    });
    await db.insert('Workout', {
      'workout_id': 3,
      'workout_template_id': 3,
      'user_id': 1,
      'date': '2025-04-10',
    });

    // Insert sample WorkoutExercises
    await db.insert('WorkoutExercise', {
      'workout_exercise_id': 1,
      'workout_id': 1,
      'exercise_id': 1,
      'sets': 3,
      'reps': 12,
      'weight': 0.0,
    });
    await db.insert('WorkoutExercise', {
      'workout_exercise_id': 2,
      'workout_id': 1,
      'exercise_id': 2,
      'sets': 3,
      'reps': 10,
      'weight': 0.0,
    });
    await db.insert('WorkoutExercise', {
      'workout_exercise_id': 3,
      'workout_id': 2,
      'exercise_id': 3,
      'sets': 4,
      'reps': 8,
      'weight': 50.0,
    });
    await db.insert('WorkoutExercise', {
      'workout_exercise_id': 4,
      'workout_id': 3,
      'exercise_id': 4,
      'sets': 5,
      'reps': 6,
      'weight': 70.0,
    });

    // Insert sample BodyMeasurements
    await db.insert('BodyMeasurement', {
      'body_measurement_id': 1,
      'user_id': 1,
      'date': '2025-04-08',
      'weight': 75.5,
    });
    await db.insert('BodyMeasurement', {
      'body_measurement_id': 2,
      'user_id': 1,
      'date': '2025-04-09',
      'weight': 76.0,
    });

    if (kDebugMode) {
      print('Sample data inserted successfully.');
    }
  }

  // Example CRUD methods for the User table
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('User', user);
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    return await db.query('User');
  }

  Future<int> updateUser(Map<String, dynamic> user) async {
    final db = await database;
    int id = user['user_id'];
    return await db.update('User', user, where: 'user_id = ?', whereArgs: [id]);
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete('User', where: 'user_id = ?', whereArgs: [id]);
  }

  // Example CRUD methods for the Workout table
  Future<int> insertWorkout(Map<String, dynamic> workout) async {
    final db = await database;
    return await db.insert('Workout', workout);
  }

  Future<List<Map<String, dynamic>>> getWorkouts() async {
    final db = await database;
    return await db.query('Workout');
  }

  Future<int> updateWorkout(Map<String, dynamic> workout) async {
    final db = await database;
    int id = workout['workout_id'];
    return await db.update('Workout', workout, where: 'workout_id = ?', whereArgs: [id]);
  }

  Future<int> deleteWorkout(int id) async {
    final db = await database;
    return await db.delete('Workout', where: 'workout_id = ?', whereArgs: [id]);
  }

  Future<String> getFirstTemplateName() async {
    final db = await database;
    final result = await db.query('Template', limit: 1);
    if (result.isNotEmpty) {
      return result.first['template_name'] as String;
    }
    return 'No Template Found';
  }
}