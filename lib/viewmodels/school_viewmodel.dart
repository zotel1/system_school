import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../models/student.dart';
import '../models/subject.dart';
import '../models/grade.dart';
import '../models/attendance.dart';

class SchoolViewModel extends ChangeNotifier {
  List<Student> _students = [];
  List<Subject> _subjects = [];
  bool _isLoading = false;

  List<Student> get students => _students;
  List<Subject> get subjects => _subjects;
  bool get isLoading => _isLoading;

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    _students = await DatabaseHelper.instance.getStudents();
    _subjects = await DatabaseHelper.instance.getSubjects();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addStudent(Student student) async {
    await DatabaseHelper.instance.createStudent(student);
    await loadData();
  }

  Future<void> updateStudent(Student student) async {
    await DatabaseHelper.instance.updateStudent(student);
    await loadData();
  }

  Future<void> deleteStudent(int id) async {
    await DatabaseHelper.instance.deleteStudent(id);
    await loadData();
  }

  Future<Student?> getStudentByUserId(int userId) async {
    return await DatabaseHelper.instance.getStudentByUserId(userId);
  }

  // --- Subject Methods ---
  Future<void> addSubject(Subject subject) async {
    await DatabaseHelper.instance.createSubject(subject);
    await loadData();
  }

  Future<void> updateSubject(Subject subject) async {
    await DatabaseHelper.instance.updateSubject(subject);
    await loadData();
  }

  Future<void> deleteSubject(int id) async {
    await DatabaseHelper.instance.deleteSubject(id);
    await loadData();
  }

  // --- Grades & Attendance ---
  Future<List<Grade>> getStudentGrades(int studentId) async {
    return await DatabaseHelper.instance.getStudentGrades(studentId);
  }

  Future<void> addGrade(Grade grade) async {
    await DatabaseHelper.instance.createGrade(grade);
    notifyListeners();
  }

  Future<List<Attendance>> getStudentAttendances(int studentId) async {
    return await DatabaseHelper.instance.getStudentAttendances(studentId);
  }

  Future<void> addAttendance(Attendance attendance) async {
    await DatabaseHelper.instance.createAttendance(attendance);
    notifyListeners();
  }
}
