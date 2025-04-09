class TemplateExercise {
  final int? templateExerciseId;
  final int templateId;
  final int exerciseId;

  TemplateExercise({
    this.templateExerciseId,
    required this.templateId,
    required this.exerciseId,
  });

  factory TemplateExercise.fromMap(Map<String, dynamic> map) {
    return TemplateExercise(
      templateExerciseId: map['template_exercise_id'],
      templateId: map['template_id'],
      exerciseId: map['exercise_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'template_exercise_id': templateExerciseId,
      'template_id': templateId,
      'exercise_id': exerciseId,
    };
  }
}