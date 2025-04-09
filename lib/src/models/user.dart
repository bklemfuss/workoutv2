class User {
  final int? userId;
  final String name;
  final String email;
  final String password;
  final int height;
  final int weight;
  final String dateOfBirth;
  final int gender;
  final int notificationPreferences;

  User({
    this.userId,
    required this.name,
    required this.email,
    required this.password,
    required this.height,
    required this.weight,
    required this.dateOfBirth,
    required this.gender,
    required this.notificationPreferences,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      userId: map['user_id'],
      name: map['name'],
      email: map['email'],
      password: map['password'],
      height: map['height'],
      weight: map['weight'],
      dateOfBirth: map['date_of_birth'],
      gender: map['gender'],
      notificationPreferences: map['notification_preferences'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
      'password': password,
      'height': height,
      'weight': weight,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'notification_preferences': notificationPreferences,
    };
  }
}