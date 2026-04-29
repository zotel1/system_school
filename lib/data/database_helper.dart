import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/student.dart';
import '../models/subject.dart';
import '../models/grade.dart';
import '../models/attendance.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('school_system.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // Incrementar la versión para recrear la BD en dev
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.execute('DROP TABLE IF EXISTS attendances');
    await db.execute('DROP TABLE IF EXISTS grades');
    await db.execute('DROP TABLE IF EXISTS student_subjects');
    await db.execute('DROP TABLE IF EXISTS subjects');
    await db.execute('DROP TABLE IF EXISTS students');
    await db.execute('DROP TABLE IF EXISTS users');
    await _createDB(db, newVersion);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const realType = 'REAL NOT NULL';
    const intType = 'INTEGER NOT NULL';

    await db.execute('''
      CREATE TABLE users (
        id $idType,
        username $textType UNIQUE,
        password $textType,
        role $textType
      )
    ''');

    await db.execute('''
      CREATE TABLE students (
        id $idType,
        user_id INTEGER,
        name $textType,
        last_name $textType,
        email $textType,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE subjects (
        id $idType,
        name $textType,
        description $textType,
        schedule $textType
      )
    ''');

    await db.execute('''
      CREATE TABLE student_subjects (
        id $idType,
        student_id $intType,
        subject_id $intType,
        FOREIGN KEY (student_id) REFERENCES students (id) ON DELETE CASCADE,
        FOREIGN KEY (subject_id) REFERENCES subjects (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE grades (
        id $idType,
        student_id $intType,
        subject_id $intType,
        value $realType,
        condition $textType,
        date $textType,
        FOREIGN KEY (student_id) REFERENCES students (id) ON DELETE CASCADE,
        FOREIGN KEY (subject_id) REFERENCES subjects (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE attendances (
        id $idType,
        student_id $intType,
        date $textType,
        status $textType,
        FOREIGN KEY (student_id) REFERENCES students (id) ON DELETE CASCADE
      )
    ''');

    // Seed Data
    await db.insert('users', {
      'username': 'admin',
      'password': 'password123',
      'role': 'teacher'
    });
    
    // Alumno de prueba
    int userId = await db.insert('users', {
      'username': 'student1',
      'password': 'password123',
      'role': 'student'
    });
    await db.insert('students', {
      'user_id': userId,
      'name': 'Juan',
      'last_name': 'Pérez',
      'email': 'juan@email.com'
    });

    await db.insert('subjects', {
      'name': 'Programación',
      'description': 'Introducción a la programación',
      'schedule': 'Lunes 18:00 a 20:00'
    });
    
    await db.insert('subjects', {
      'name': 'Matemática',
      'description': 'Matemática discreta',
      'schedule': 'Martes y Jueves 19:00 a 21:00'
    });
  }

  // --- User Methods ---
  Future<User?> login(String username, String password) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<bool> registerStudent(String username, String password, String name, String lastName, String email) async {
    final db = await instance.database;
    
    try {
      await db.transaction((txn) async {
        final userId = await txn.insert('users', {
          'username': username,
          'password': password,
          'role': 'student'
        });

        await txn.insert('students', {
          'user_id': userId,
          'name': name,
          'last_name': lastName,
          'email': email
        });
      });
      return true;
    } catch (e) {
      return false; // Error (e.g. username already exists)
    }
  }

  Future<Student?> getStudentByUserId(int userId) async {
    final db = await instance.database;
    final result = await db.query('students', where: 'user_id = ?', whereArgs: [userId]);
    if (result.isNotEmpty) {
      return Student.fromMap(result.first);
    }
    return null;
  }

  // --- Student Methods ---
  Future<Student> createStudent(Student student) async {
    final db = await instance.database;
    final id = await db.insert('students', student.toMap());
    return Student(
      id: id,
      userId: student.userId,
      name: student.name,
      lastName: student.lastName,
      email: student.email,
    );
  }

  Future<List<Student>> getStudents() async {
    final db = await instance.database;
    final result = await db.query('students');
    return result.map((json) => Student.fromMap(json)).toList();
  }

  Future<int> updateStudent(Student student) async {
    final db = await instance.database;
    return db.update(
      'students',
      student.toMap(),
      where: 'id = ?',
      whereArgs: [student.id],
    );
  }

  Future<int> deleteStudent(int id) async {
    final db = await instance.database;
    return await db.delete(
      'students',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- Subject Methods ---
  Future<List<Subject>> getSubjects() async {
    final db = await instance.database;
    final result = await db.query('subjects');
    return result.map((json) => Subject.fromMap(json)).toList();
  }

  Future<int> createSubject(Subject subject) async {
    final db = await instance.database;
    return await db.insert('subjects', subject.toMap());
  }

  Future<int> updateSubject(Subject subject) async {
    final db = await instance.database;
    return await db.update('subjects', subject.toMap(), where: 'id = ?', whereArgs: [subject.id]);
  }

  Future<int> deleteSubject(int id) async {
    final db = await instance.database;
    return await db.delete('subjects', where: 'id = ?', whereArgs: [id]);
  }

  // --- Grade Methods ---
  Future<int> createGrade(Grade grade) async {
    final db = await instance.database;
    return await db.insert('grades', grade.toMap());
  }

  Future<List<Grade>> getStudentGrades(int studentId) async {
    final db = await instance.database;
    final result = await db.query(
      'grades',
      where: 'student_id = ?',
      whereArgs: [studentId],
    );
    return result.map((json) => Grade.fromMap(json)).toList();
  }

  // --- Attendance Methods ---
  Future<int> createAttendance(Attendance attendance) async {
    final db = await instance.database;
    return await db.insert('attendances', attendance.toMap());
  }

  Future<List<Attendance>> getStudentAttendances(int studentId) async {
    final db = await instance.database;
    final result = await db.query(
      'attendances',
      where: 'student_id = ?',
      whereArgs: [studentId],
    );
    return result.map((json) => Attendance.fromMap(json)).toList();
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
