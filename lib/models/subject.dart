class Subject {
  final int? id;
  final String name;
  final String description;
  final String schedule;

  Subject({
    this.id,
    required this.name,
    required this.description,
    required this.schedule,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'schedule': schedule,
    };
  }

  factory Subject.fromMap(Map<String, dynamic> map) {
    return Subject(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      schedule: map['schedule'] ?? '',
    );
  }
}

// Tabla intermedia para asignar materias a estudiantes
class StudentSubject {
  final int? id;
  final int studentId;
  final int subjectId;

  StudentSubject({
    this.id,
    required this.studentId,
    required this.subjectId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'subject_id': subjectId,
    };
  }

  factory StudentSubject.fromMap(Map<String, dynamic> map) {
    return StudentSubject(
      id: map['id'],
      studentId: map['student_id'],
      subjectId: map['subject_id'],
    );
  }
}
