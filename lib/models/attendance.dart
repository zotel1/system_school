class Attendance {
  final int? id;
  final int studentId;
  final DateTime date;
  final String status; // 'Presente' or 'Ausente'

  Attendance({
    this.id,
    required this.studentId,
    required this.date,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'date': date.toIso8601String(),
      'status': status,
    };
  }

  factory Attendance.fromMap(Map<String, dynamic> map) {
    return Attendance(
      id: map['id'],
      studentId: map['student_id'],
      date: DateTime.parse(map['date']),
      status: map['status'],
    );
  }
}
