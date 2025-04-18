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
        template_name TEXT,
        template_premade INTEGER -- 0 for false, 1 for true
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
        template_id INTEGER,
        user_id INTEGER,
        date TEXT,
        workout_timer INTEGER,
        FOREIGN KEY (template_id) REFERENCES Template(template_id),
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
    await db.insert('Template', {'template_id': 1, 'template_name': 'Full Body Workout A', 'template_premade': 1});
    await db.insert('Template', {'template_id': 2, 'template_name': 'Upper Body Strength', 'template_premade': 1});
    await db.insert('Template', {'template_id': 3, 'template_name': 'Lower Body Endurance', 'template_premade': 1});
    await db.insert('Template', {'template_id': 4, 'template_name': 'Core Stability', 'template_premade': 1});

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
      'template_id': 1,
      'user_id': 1,
      'date': '2025-04-08',
      'workout_timer': 3600, // 1 hour
    });
    await db.insert('Workout', {
      'workout_id': 2,
      'template_id': 2,
      'user_id': 1,
      'date': '2025-04-09',
      'workout_timer': 2700, // 45 minutes
    });
    await db.insert('Workout', {
      'workout_id': 3,
      'template_id': 3,
      'user_id': 1,
      'date': '2025-04-10',
      'workout_timer': 1800, // 30 minutes
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
    return await db.update(
      'User',
      user,
      where: 'user_id = ?',
      whereArgs: [user['user_id']],
    );
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete('User', where: 'user_id = ?', whereArgs: [id]);
  }

  Future<Map<String, dynamic>> getUserById(int userId) async {
    final db = await database;
    final result = await db.query(
      'User',
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : {};
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

  Future<List<Map<String, dynamic>>> getWorkoutsWithDetails() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT 
        w.workout_id,
        w.date,
        t.template_name,
        u.name AS user_name,
        e.name AS exercise_name,
        we.sets,
        we.reps,
        we.weight
      FROM Workout w
      INNER JOIN Template t ON w.template_id = t.template_id
      INNER JOIN User u ON w.user_id = u.user_id
      INNER JOIN WorkoutExercise we ON w.workout_id = we.workout_id
      INNER JOIN Exercise e ON we.exercise_id = e.exercise_id
      ORDER BY w.date DESC
    ''');
  }

  Future<List<Map<String, dynamic>>> getExercisesByTemplateId(int templateId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT 
        e.exercise_id, 
        e.name, 
        e.Description, 
        e.instructions 
      FROM TemplateExercise te
      INNER JOIN Exercise e ON te.exercise_id = e.exercise_id
      WHERE te.template_id = ?
    ''', [templateId]);
  }

  Future<List<Map<String, dynamic>>> getTemplates() async {
    final db = await database;
    return await db.query('Template');
  }

  Future<int> createWorkout(int templateId, int userId) async {
    final db = await database;
    final workoutId = await db.insert('Workout', {
      'template_id': templateId,
      'user_id': userId,
      'date': DateTime.now().toIso8601String(), // Store the current date and time
    });
    return workoutId; // Return the newly created workout ID
  }

  Future<void> createWorkoutExercises(int workoutId, List<Map<String, dynamic>> exercises) async {
    final db = await database;
    for (final exercise in exercises) {
      await db.insert('WorkoutExercise', {
        'workout_id': workoutId,
        'exercise_id': exercise['exercise_id'],
        'sets': exercise['sets'],
        'reps': exercise['reps'],
        'weight': exercise['weight'],
      });
    }
  }

  Future<Map<String, dynamic>> getWorkoutDetails(int workoutId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 
        w.workout_id,
        t.template_name,
        w.workout_timer
      FROM Workout w
      INNER JOIN Template t ON w.template_id = t.template_id
      WHERE w.workout_id = ?
    ''', [workoutId]);

    return result.isNotEmpty ? result.first : {};
  }

  Future<List<Map<String, dynamic>>> getWorkoutExercises(int workoutId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT 
        we.workout_exercise_id,
        e.name AS exercise_name,
        we.sets,
        we.reps,
        we.weight
      FROM WorkoutExercise we
      INNER JOIN Exercise e ON we.exercise_id = e.exercise_id
      WHERE we.workout_id = ?
    ''', [workoutId]);
  }

  Future<List<Map<String, dynamic>>> getExercisesByMuscleGroup(String? muscleGroup) async {
    final db = await database;
    if (muscleGroup == null || muscleGroup == 'All') {
      return await db.query('Exercise');
    } else {
      return await db.rawQuery('''
        SELECT * FROM Exercise e
        INNER JOIN MuscleGroup mg ON e.muscle_group_id = mg.muscle_group_id
        WHERE mg.Name = ?
      ''', [muscleGroup]);
    }
  }

  Future<void> saveWorkoutTemplate({
    required String workoutName,
    required List<int> exerciseIds,
  }) async {
    final db = await database;

    // Start a transaction to ensure atomicity
    await db.transaction((txn) async {
      // Insert the template into the Template table
      final templateId = await txn.insert('Template', {
        'template_name': workoutName,
      });

      // Insert each exercise into the TemplateExercise table
      for (final exerciseId in exerciseIds) {
        await txn.insert('TemplateExercise', {
          'template_id': templateId,
          'exercise_id': exerciseId,
        });
      }
    });
  }

  Future<void> deleteTemplate(int templateId) async {
    final db = await database;

    await db.transaction((txn) async {
      // Delete associated TemplateExercise entries
      await txn.delete(
        'TemplateExercise',
        where: 'template_id = ?',
        whereArgs: [templateId],
      );

      // Delete the template itself
      await txn.delete(
        'Template',
        where: 'template_id = ?',
        whereArgs: [templateId],
      );
    });
  }

  Future<void> updateWorkoutTimer(int workoutId, int workoutTimer) async {
    final db = await database;
    await db.update(
      'Workout',
      {'workout_timer': workoutTimer},
      where: 'workout_id = ?',
      whereArgs: [workoutId],
    );
  }

  Future<void> deleteExerciseFromTemplate(int templateId, int exerciseId) async {
    final db = await database;
    await db.delete(
      'TemplateExercise',
      where: 'template_id = ? AND exercise_id = ?',
      whereArgs: [templateId, exerciseId],
    );
  }
}