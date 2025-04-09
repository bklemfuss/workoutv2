class Exercise {
  final int? exerciseId;
  final int muscleGroupId;
  final String name;
  final String description;
  final int equipment; // 0 for false, 1 for true
  final String instructions;
  final String? imageUrl;

  Exercise({
    this.exerciseId,
    required this.muscleGroupId,
    required this.name,
    required this.description,
    required this.equipment,
    required this.instructions,
    this.imageUrl,
  });

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      exerciseId: map['exercise_id'],
      muscleGroupId: map['muscle_group_id'],
      name: map['name'],
      description: map['Description'],
      equipment: map['equipment'],
      instructions: map['instructions'],
      imageUrl: map['image_url'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'exercise_id': exerciseId,
      'muscle_group_id': muscleGroupId,
      'name': name,
      'Description': description,
      'equipment': equipment,
      'instructions': instructions,
      'image_url': imageUrl,
    };
  }
}