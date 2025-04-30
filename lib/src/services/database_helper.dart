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
      version: 3, // Updated database version
      onCreate: _onCreate,
      onUpgrade: _onUpgrade, // Handle database upgrades
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
        exercise_notes TEXT, -- New column for exercise notes
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

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add the exercise_notes column to the Exercise table
      await db.execute('''
        ALTER TABLE Exercise ADD COLUMN exercise_notes TEXT
      ''');
    }
    if (oldVersion < 3) {
      // Create a new WorkoutExercise table without the `sets` column
      await db.execute('''
        CREATE TABLE WorkoutExercise_new (
          workout_exercise_id INTEGER PRIMARY KEY AUTOINCREMENT,
          workout_id INTEGER,
          exercise_id INTEGER,
          reps INTEGER,
          weight REAL,
          FOREIGN KEY (workout_id) REFERENCES Workout(workout_id),
          FOREIGN KEY (exercise_id) REFERENCES Exercise(exercise_id)
        )
      ''');

      // Copy data from the old table to the new table
      await db.execute('''
        INSERT INTO WorkoutExercise_new (workout_exercise_id, workout_id, exercise_id, reps, weight)
        SELECT workout_exercise_id, workout_id, exercise_id, reps, weight
        FROM WorkoutExercise
      ''');

      // Drop the old table
      await db.execute('DROP TABLE WorkoutExercise');

      // Rename the new table to the original name
      await db.execute('ALTER TABLE WorkoutExercise_new RENAME TO WorkoutExercise');
    }
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
      'exercise_notes': 'Focus on form to avoid injury.', // Example note
    });
    await db.insert('Exercise', {
      'exercise_id': 2,
      'muscle_group_id': 2,
      'name': 'Pull-Up',
      'Description': 'A basic back and biceps exercise.',
      'equipment': 0,
      'instructions': 'Pull yourself up until your chin is above the bar.',
      'image_url': 'https://example.com/pull-up.png',
      'exercise_notes': 'Use a resistance band if needed.', // Example note
    });
    await db.insert('Exercise', {
      'exercise_id': 3,
      'muscle_group_id': 3,
      'name': 'Squat',
      'Description': 'A basic lower body exercise.',
      'equipment': 0,
      'instructions': 'Lower your hips until your thighs are parallel to the ground.',
      'image_url': 'https://example.com/squat.png',
      'exercise_notes': 'Keep your knees aligned with your toes.', // Example note
    });
    await db.insert('Exercise', {
      'exercise_id': 4,
      'muscle_group_id': 1,
      'name': 'Bench Press',
      'Description': 'A chest exercise using a barbell.',
      'equipment': 1,
      'instructions': 'Lower the barbell to your chest and press it back up.',
      'image_url': 'https://example.com/bench-press.png',
      'exercise_notes': 'Ensure a spotter is present for safety.', // Example note
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
      'reps': 12,
      'weight': 0.0,
    });
    await db.insert('WorkoutExercise', {
      'workout_exercise_id': 2,
      'workout_id': 1,
      'exercise_id': 2,
      'reps': 10,
      'weight': 0.0,
    });
    await db.insert('WorkoutExercise', {
      'workout_exercise_id': 3,
      'workout_id': 2,
      'exercise_id': 3,
      'reps': 8,
      'weight': 50.0,
    });
    await db.insert('WorkoutExercise', {
      'workout_exercise_id': 4,
      'workout_id': 3,
      'exercise_id': 4,
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
    final results = await db.rawQuery('''
      SELECT 
        w.workout_id,
        w.date,
        t.template_name,
        u.name AS user_name,
        GROUP_CONCAT(e.name, ', ') AS exercise_names,
        w.workout_timer
      FROM Workout w
      INNER JOIN Template t ON w.template_id = t.template_id
      INNER JOIN User u ON w.user_id = u.user_id
      INNER JOIN WorkoutExercise we ON w.workout_id = we.workout_id
      INNER JOIN Exercise e ON we.exercise_id = e.exercise_id
      GROUP BY w.workout_id
      ORDER BY w.date DESC
    ''');
    return results;
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

    // Insert each exercise into the workout_exercises table
    for (final exercise in exercises) {
      debugPrint('Inserting workout exercise: $exercise');
      await db.insert(
        'WorkoutExercise',
        {
          'workout_id': workoutId,
          'exercise_id': exercise['exercise_id'],
          'reps': exercise['reps'], // Ensure reps is handled
          'weight': exercise['weight'], // Ensure weight is handled
        },
      );
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

    // Correct query to fetch all workout exercises for the given workout_id
    final result = await db.rawQuery('''
      SELECT 
        we.workout_exercise_id AS workout_exercise_id, 
        we.exercise_id, 
        e.name AS exercise_name, 
        we.reps, 
        we.weight
      FROM WorkoutExercise AS we
      INNER JOIN Exercise AS e 
        ON we.exercise_id = e.exercise_id
      WHERE we.workout_id = ?
    ''', [workoutId]);

    return result;
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
      // Insert the template into the Template table with template_premade set to false
      final templateId = await txn.insert('Template', {
        'template_name': workoutName,
        'template_premade': 0, // Set to false (0)
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

  Future<void> deleteExerciseFromTemplate(int templateId, int exerciseId) async {
    final db = await database;
    await db.delete(
      'TemplateExercise',
      where: 'template_id = ? AND exercise_id = ?',
      whereArgs: [templateId, exerciseId],
    );
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

  Future<void> deleteWorkout(int workoutId) async {
    final db = await database;

    await db.transaction((txn) async {
      // Delete associated WorkoutExercises
      await txn.delete(
        'WorkoutExercise',
        where: 'workout_id = ?',
        whereArgs: [workoutId],
      );

      // Delete the workout itself
      await txn.delete(
        'Workout',
        where: 'workout_id = ?',
        whereArgs: [workoutId],
      );
    });
  }

  Future<List<Map<String, dynamic>>> getAllExercises() async {
    final db = await database;
    return await db.query('Exercise');
  }

  Future<void> addExerciseToTemplate(int templateId, int exerciseId) async {
    final db = await database;
    await db.insert('TemplateExercise', {
      'template_id': templateId,
      'exercise_id': exerciseId,
    });
  }

  Future<List<Map<String, dynamic>>> getExercisesNotInTemplate(int templateId) async {
    final db = await database;

    // Query to fetch exercises not in the current template
    return await db.rawQuery('''
      SELECT * FROM Exercise
      WHERE exercise_id NOT IN (
        SELECT exercise_id FROM TemplateExercise WHERE template_id = ?
      )
    ''', [templateId]);
  }

  Future<int> getTemplatePremadeStatus(int templateId) async {
    final db = await database;
    final result = await db.query(
      'Template',
      columns: ['template_premade'],
      where: 'template_id = ?',
      whereArgs: [templateId],
      limit: 1,
    );
    return result.isNotEmpty ? result.first['template_premade'] as int : 1; // Default to 1 if not found
  }

  Future<void> addCustomExercise({
    required String name,
    required String description,
    required String muscleGroup,
    required bool requiresEquipment,
  }) async {
    final db = await database;

    // Get the muscle group ID (default to 1 if not found)
    final muscleGroupResult = await db.query(
      'MuscleGroup',
      columns: ['muscle_group_id'],
      where: 'Name = ?',
      whereArgs: [muscleGroup],
      limit: 1,
    );
    final muscleGroupId = muscleGroupResult.isNotEmpty
        ? muscleGroupResult.first['muscle_group_id'] as int
        : 1;

    // Insert the custom exercise
    await db.insert('Exercise', {
      'muscle_group_id': muscleGroupId,
      'name': name,
      'Description': description,
      'equipment': requiresEquipment ? 1 : 0, // 1 for true, 0 for false
      'instructions': '', // Optional: Add default or empty instructions
      'image_url': '', // Optional: Add default or empty image URL
    });
  }

  Future<void> updateExerciseNotes(int exerciseId, String notes) async {
    final db = await database;
    await db.update(
      'Exercise',
      {'exercise_notes': notes},
      where: 'exercise_id = ?',
      whereArgs: [exerciseId],
    );
  }

  Future<List<Map<String, dynamic>>> getWorkoutExercisesGroupedByExercise(int workoutId) async {
    final db = await database;

    // Query to fetch exercises grouped by exercise_id
    final result = await db.rawQuery('''
      SELECT 
        e.exercise_id,
        e.name AS exercise_name,
        GROUP_CONCAT(we.reps || ':' || we.weight) AS sets_data
      FROM WorkoutExercise we
      INNER JOIN Exercise e ON we.exercise_id = e.exercise_id
      WHERE we.workout_id = ?
      GROUP BY e.exercise_id
    ''', [workoutId]);

    // Parse the grouped data into a structured format
    return result.map((row) {
      final setsData = (row['sets_data'] as String).split(',').map((set) {
        final parts = set.split(':');
        return {
          'reps': int.parse(parts[0]),
          'weight': double.parse(parts[1]),
        };
      }).toList();

      return {
        'exercise_id': row['exercise_id'],
        'exercise_name': row['exercise_name'],
        'sets': setsData,
      };
    }).toList();
  }
}