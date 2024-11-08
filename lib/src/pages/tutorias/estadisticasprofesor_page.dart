import 'package:flutter/material.dart';

class ProfesorEstadisticas extends StatelessWidget {
  final Map<String, dynamic> data;

  const ProfesorEstadisticas({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Promedio de Calificaciones Recibidas: ${data['promProfe']}",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Tutorías Completadas: ${data['tutoriasCompletadas']}",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Text(
            "Tareas Asignadas: ${data['tareasAsignadas']}",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            "Nota Seguimiento asignadas: ${data['notasSeguimiento']}",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            "Alumnos totales: ${data['cantAlumnos']}",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
