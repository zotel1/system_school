import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/school_viewmodel.dart';
import '../models/subject.dart';

class SubjectListScreen extends StatefulWidget {
  @override
  _SubjectListScreenState createState() => _SubjectListScreenState();
}

class _SubjectListScreenState extends State<SubjectListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SchoolViewModel>(context, listen: false).loadData();
    });
  }

  void _showAddOrEditSubjectDialog(BuildContext context, {Subject? existingSubject}) {
    final nameController = TextEditingController(text: existingSubject?.name ?? '');
    final descController = TextEditingController(text: existingSubject?.description ?? '');
    final scheduleController = TextEditingController(text: existingSubject?.schedule ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existingSubject == null ? 'Nueva Unidad Curricular' : 'Editar Unidad Curricular'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: 'Nombre')),
            SizedBox(height: 8),
            TextField(controller: descController, decoration: InputDecoration(labelText: 'Descripción')),
            SizedBox(height: 8),
            TextField(
              controller: scheduleController, 
              decoration: InputDecoration(labelText: 'Horario (ej. Lunes 18 a 20)'),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isEmpty) return;

              final subject = Subject(
                id: existingSubject?.id,
                name: nameController.text,
                description: descController.text,
                schedule: scheduleController.text,
              );

              final viewModel = Provider.of<SchoolViewModel>(context, listen: false);
              if (existingSubject == null) {
                viewModel.addSubject(subject);
              } else {
                viewModel.updateSubject(subject);
              }
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
        title: Text('Unidades Curriculares'),
      ),
      body: Consumer<SchoolViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (viewModel.subjects.isEmpty) {
            return Center(child: Text('No hay unidades curriculares registradas.'));
          }

          return ListView.builder(
            itemCount: viewModel.subjects.length,
            itemBuilder: (context, index) {
              final subject = viewModel.subjects[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(subject.name, style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${subject.description}\nHorario: ${subject.schedule}'),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showAddOrEditSubjectDialog(context, existingSubject: subject),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => viewModel.deleteSubject(subject.id!),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOrEditSubjectDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }
}
