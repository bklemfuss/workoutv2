class MuscleGroup {
  final int? muscleGroupId;
  final String name;

  MuscleGroup({this.muscleGroupId, required this.name});

  // Convert a Map (from the database) to a MuscleGroup object
  factory MuscleGroup.fromMap(Map<String, dynamic> map) {
    return MuscleGroup(
      muscleGroupId: map['muscle_group_id'],
      name: map['Name'],
    );
  }

  // Convert a MuscleGroup object to a Map (for the database)
  Map<String, dynamic> toMap() {
    return {
      'muscle_group_id': muscleGroupId,
      'Name': name,
    };
  }
}