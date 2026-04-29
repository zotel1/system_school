class Student {
  final int? id;
  final int? userId;
  final String name;
  final String lastName;
  final String email;

  Student({
    this.id,
    this.userId,
    required this.name,
    required this.lastName,
    required this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'last_name': lastName,
      'email': email,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'],
      userId: map['user_id'],
      name: map['name'],
      lastName: map['last_name'],
      email: map['email'],
    );
  }
}
