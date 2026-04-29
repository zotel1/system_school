import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/school_viewmodel.dart';
import '../models/student.dart';
import 'student_list_screen.dart';
import 'subject_list_screen.dart';
import 'student_detail_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Student? _currentStudent;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final user = Provider.of<AuthViewModel>(context, listen: false).currentUser;
      if (user?.role == 'student') {
        final schoolViewModel = Provider.of<SchoolViewModel>(context, listen: false);
        await schoolViewModel.loadData();
        final student = await schoolViewModel.getStudentByUserId(user!.id!);
        if (mounted) {
          setState(() {
            _currentStudent = student;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthViewModel>(context).currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard - ${user?.role == 'teacher' ? 'Docente' : 'Alumno'}'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthViewModel>(context, listen: false).logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      child: Icon(Icons.person, size: 40),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Bienvenido, ${user?.username}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            if (user?.role == 'teacher') ...[
              ElevatedButton.icon(
                icon: Icon(Icons.group),
                label: Text('Gestión de Alumnos'),
                style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 20)),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => StudentListScreen()));
                },
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                icon: Icon(Icons.book),
                label: Text('Unidades Curriculares'),
                style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 20), backgroundColor: Colors.blueGrey, foregroundColor: Colors.white),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => SubjectListScreen()));
                },
              ),
            ] else ...[
              if (_currentStudent == null)
                Center(child: CircularProgressIndicator())
              else
                ElevatedButton.icon(
                  icon: Icon(Icons.person),
                  label: Text('Ver Mi Perfil (Notas y Asistencia)'),
                  style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 20)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => StudentDetailScreen(student: _currentStudent!)),
                    );
                  },
                ),
            ]
          ],
        ),
      ),
    );
  }
}
