import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mentorme/src/database/database.dart';
import 'package:mentorme/src/models/tutoria.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetalleSeguimientoPage extends StatefulWidget {
  final int profesorId;
  const DetalleSeguimientoPage({super.key, required this.profesorId});

  @override
  State<DetalleSeguimientoPage> createState() => _DetalleSeguimientoPageState();
}

class _DetalleSeguimientoPageState extends State<DetalleSeguimientoPage> {
  double promedioCalificacion = 0.0;
  List<Tutoria> tutoriasConProfesor = [];

  @override
  void initState() {
    super.initState();
    _loadDetalles();
  }

  Future<void> _loadDetalles() async {
    final db = MentorMeDatabase.instance;
    final prefs = await SharedPreferences.getInstance();
    final alumnoId = prefs.getInt('userid');

    final tutorias = await db.getTutoriasPorProfesorYAlumno(widget.profesorId, alumnoId!);
    setState(() {
      tutoriasConProfesor = tutorias;
      promedioCalificacion = _calcularPromedio(tutorias);
    });
  }

  double _calcularPromedio(List<Tutoria> tutorias) {
    if (tutorias.isEmpty) return 0.0;
    final suma = tutorias.fold(0, (acc, tutoria) => acc + (tutoria.calificacionalumno ?? 0));
    return suma / tutorias.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalles del Seguimiento')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Promedio de Calificación: ${promedioCalificacion.toStringAsFixed(1)}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: tutoriasConProfesor.length,
                itemBuilder: (context, index) {
                  final tutoria = tutoriasConProfesor[index];
                  return Card(
                    child: ListTile(
                      title: Text('Fecha: ${DateFormat('yyyy-MM-dd').format(tutoria.dia)}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tareas Asignadas: ${tutoria.tareasAsignadas ?? "N/A"}'),
                          Text('Nota de Seguimiento: ${tutoria.notasSeguimiento ?? "N/A"}'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
