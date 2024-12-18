import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mentorme/src/models/tutoria.dart';
import 'package:mentorme/src/models/user.dart';
import 'package:mentorme/src/services/firebase_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetalleSeguimientoPage extends StatefulWidget {
  final User profesor;
  const DetalleSeguimientoPage({super.key, required this.profesor});

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
    final db = FirebaseServices.instance;
    final prefs = await SharedPreferences.getInstance();
    final alumnoId = prefs.getString('userid');

    final tutorias =
        await db.getTutoriasPorProfesorYAlumno(widget.profesor.id!, alumnoId!);
    setState(() {
      tutoriasConProfesor = tutorias;
      promedioCalificacion = _calcularPromedio(tutorias);
    });
  }

  double _calcularPromedio(List<Tutoria> tutorias) {
    if (tutorias.isEmpty) return 0.0;
    final suma = tutorias.fold(
        0, (acc, tutoria) => acc + (tutoria.calificacionalumno ?? 1));
    return suma / tutorias.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalles del Seguimiento')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundImage: widget.profesor.fotoperfil != null &&
                      widget.profesor.fotoperfil!.isNotEmpty
                  ? NetworkImage(widget.profesor.fotoperfil!)
                  : const AssetImage("assets/images/user.png"),
              radius: 50,
            ),
            Text(
                widget.profesor.nombre,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text(
                'Promedio de Calificación: ${promedioCalificacion.toStringAsFixed(1)}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: tutoriasConProfesor.length,
                itemBuilder: (context, index) {
                  final tutoria = tutoriasConProfesor[index];
                  return Card(
                    child: ListTile(
                      title: Text(
                          'Fecha: ${DateFormat('yyyy-MM-dd').format(tutoria.dia)}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              'Tareas Asignadas: ${tutoria.tareasAsignadas ?? "N/A"}'),
                          Text(
                              'Nota de Seguimiento: ${tutoria.notasSeguimiento ?? "N/A"}'),
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
