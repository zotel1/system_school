class Grade {
  final int? id;
  final int studentId;
  final int subjectId;
  final double value; // 1 to 10
  final String condition; // 'Regular' or 'Promoción'
  final DateTime date;

  Grade({
    this.id,
    required this.studentId,
    required this.subjectId,
    required this.value,
    required this.condition,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'subject_id': subjectId,
      'value': value,
      'condition': condition,
      'date': date.toIso8601String(),
    };
  }

  factory Grade.fromMap(Map<String, dynamic> map) {
    return Grade(
      id: map['id'],
      studentId: map['student_id'],
      subjectId: map['subject_id'],
      value: map['value'],
      condition: map['condition'],
      date: DateTime.parse(map['date']),
    );
  }
}
