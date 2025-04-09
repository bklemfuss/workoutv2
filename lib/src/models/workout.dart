class Workout {
  final int? workoutId;
  final int workoutTemplateId;
  final int userId;
  final String date;

  Workout({
    this.workoutId,
    required this.workoutTemplateId,
    required this.userId,
    required this.date,
  });

  factory Workout.fromMap(Map<String, dynamic> map) {
    return Workout(
      workoutId: map['workout_id'],
      workoutTemplateId: map['workout_template_id'],
      userId: map['user_id'],
      date: map['date'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'workout_id': workoutId,
      'workout_template_id': workoutTemplateId,
      'user_id': userId,
      'date': date,
    };
  }
}