import 'package:flutter/material.dart';
import 'package:mentorme/src/models/user.dart';
import 'package:mentorme/src/database/database.dart';
import 'package:mentorme/src/pages/tutorias/detalleseguimiento_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SeguimientoPorProfesorPage extends StatefulWidget {
  const SeguimientoPorProfesorPage({super.key});

  @override
  State<SeguimientoPorProfesorPage> createState() => _SeguimientoPorProfesorPageState();
}

class _SeguimientoPorProfesorPageState extends State<SeguimientoPorProfesorPage> {
  List<User> profesores = [];

  @override
  void initState() {
    super.initState();
    _loadProfesores();
  }

  Future<void> _loadProfesores() async {
    // Load professors who have had tutoring sessions with the student
    final db = MentorMeDatabase.instance;
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userid');
    final profesorList = await db.getProfesoresPorAlumno(userId!);
    setState(() {
      profesores = profesorList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seguimiento por Profesor')),
      body: ListView.builder(
        itemCount: profesores.length,
        itemBuilder: (context, index) {
          final profesor = profesores[index];
          return Card(
            child: ListTile(
              title: Text(profesor.nombre),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetalleSeguimientoPage(profesorId: profesor.id!),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
