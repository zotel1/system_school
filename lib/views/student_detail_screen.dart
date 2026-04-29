import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/student.dart';
import '../models/grade.dart';
import '../models/attendance.dart';
import '../viewmodels/school_viewmodel.dart';

class StudentDetailScreen extends StatefulWidget {
  final Student student;

  const StudentDetailScreen({Key? key, required this.student}) : super(key: key);

  @override
  _StudentDetailScreenState createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.student.name} ${widget.student.lastName}'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Notas', icon: Icon(Icons.grade)),
            Tab(text: 'Asistencia', icon: Icon(Icons.event_available)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _GradesTab(student: widget.student),
          _AttendanceTab(student: widget.student),
        ],
      ),
    );
  }
}

class _GradesTab extends StatelessWidget {
  final Student student;

  const _GradesTab({required this.student});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SchoolViewModel>(context);

    return Column(
      children: [
        Expanded(
          child: FutureBuilder<List<Grade>>(
            future: viewModel.getStudentGrades(student.id!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No hay notas registradas.'));
              }
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final grade = snapshot.data![index];
                  final subject = viewModel.subjects.firstWhere((s) => s.id == grade.subjectId);
                  return ListTile(
                    title: Text(subject.name),
                    subtitle: Text('Condición: ${grade.condition} - Fecha: ${DateFormat('dd/MM/yyyy').format(grade.date)}'),
                    trailing: CircleAvatar(
                      backgroundColor: grade.value >= 6 ? Colors.green : Colors.red,
                      child: Text(grade.value.toStringAsFixed(1), style: TextStyle(color: Colors.white)),
                    ),
                  );
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            icon: Icon(Icons.add),
            label: Text('Cargar Nota'),
            onPressed: () => _showAddGradeDialog(context, viewModel),
          ),
        )
      ],
    );
  }

  void _showAddGradeDialog(BuildContext context, SchoolViewModel viewModel) {
    final valueController = TextEditingController();
    int? selectedSubject;
    String selectedCondition = 'Regular';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Cargar Nota'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                decoration: InputDecoration(labelText: 'Materia'),
                items: viewModel.subjects.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                onChanged: (val) => setState(() => selectedSubject = val),
              ),
              TextField(
                controller: valueController,
                decoration: InputDecoration(labelText: 'Nota (1 al 10)'),
                keyboardType: TextInputType.number,
              ),
              DropdownButtonFormField<String>(
                value: selectedCondition,
                decoration: InputDecoration(labelText: 'Condición'),
                items: ['Regular', 'Promoción', 'Libre'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() => selectedCondition = val!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                if (selectedSubject != null && valueController.text.isNotEmpty) {
                  final grade = Grade(
                    studentId: student.id!,
                    subjectId: selectedSubject!,
                    value: double.parse(valueController.text),
                    condition: selectedCondition,
                    date: DateTime.now(),
                  );
                  viewModel.addGrade(grade);
                  Navigator.pop(context);
                }
              },
              child: Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttendanceTab extends StatelessWidget {
  final Student student;

  const _AttendanceTab({required this.student});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SchoolViewModel>(context);

    return Column(
      children: [
        Expanded(
          child: FutureBuilder<List<Attendance>>(
            future: viewModel.getStudentAttendances(student.id!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No hay asistencias registradas.'));
              }
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final att = snapshot.data![index];
                  return ListTile(
                    leading: Icon(
                      att.status == 'Presente' ? Icons.check_circle : Icons.cancel,
                      color: att.status == 'Presente' ? Colors.green : Colors.red,
                    ),
                    title: Text(att.status),
                    subtitle: Text(DateFormat('dd/MM/yyyy HH:mm').format(att.date)),
                  );
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                icon: Icon(Icons.check),
                label: Text('Presente'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                onPressed: () {
                  viewModel.addAttendance(Attendance(studentId: student.id!, date: DateTime.now(), status: 'Presente'));
                },
              ),
              ElevatedButton.icon(
                icon: Icon(Icons.close),
                label: Text('Ausente'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                onPressed: () {
                  viewModel.addAttendance(Attendance(studentId: student.id!, date: DateTime.now(), status: 'Ausente'));
                },
              ),
            ],
          ),
        )
      ],
    );
  }
}
