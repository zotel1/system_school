import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/school_viewmodel.dart';
import '../models/student.dart';
import 'student_detail_screen.dart';

class StudentListScreen extends StatefulWidget {
  @override
  _StudentListScreenState createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SchoolViewModel>(context, listen: false).loadData();
    });
  }

  void _showAddStudentDialog(BuildContext context) {
    final nameController = TextEditingController();
    final lastNameController = TextEditingController();
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nuevo Alumno'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: 'Nombre')),
            TextField(controller: lastNameController, decoration: InputDecoration(labelText: 'Apellido')),
            TextField(controller: emailController, decoration: InputDecoration(labelText: 'Email')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final student = Student(
                name: nameController.text,
                lastName: lastNameController.text,
                email: emailController.text,
              );
              Provider.of<SchoolViewModel>(context, listen: false).addStudent(student);
              Navigator.pop(context);
            },
            child: Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Estudiantes'),
      ),
      body: Consumer<SchoolViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (viewModel.students.isEmpty) {
            return Center(child: Text('No hay estudiantes registrados.'));
          }

          return ListView.builder(
            itemCount: viewModel.students.length,
            itemBuilder: (context, index) {
              final student = viewModel.students[index];
              return ListTile(
                leading: CircleAvatar(child: Text(student.name[0])),
                title: Text('${student.lastName}, ${student.name}'),
                subtitle: Text(student.email),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    viewModel.deleteStudent(student.id!);
                  },
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StudentDetailScreen(student: student),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddStudentDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }
}
