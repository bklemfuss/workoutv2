class WorkoutExercise {
  final int? workoutExerciseId;
  final int workoutId;
  final int exerciseId;
  final int sets;
  final int reps;
  final double weight;

  WorkoutExercise({
    this.workoutExerciseId,
    required this.workoutId,
    required this.exerciseId,
    required this.sets,
    required this.reps,
    required this.weight,
  });

  factory WorkoutExercise.fromMap(Map<String, dynamic> map) {
    return WorkoutExercise(
      workoutExerciseId: map['workout_exercise_id'],
      workoutId: map['workout_id'],
      exerciseId: map['exercise_id'],
      sets: map['sets'],
      reps: map['reps'],
      weight: map['weight'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'workout_exercise_id': workoutExerciseId,
      'workout_id': workoutId,
      'exercise_id': exerciseId,
      'sets': sets,
      'reps': reps,
      'weight': weight,
    };
  }
}