import 'package:flutter/material.dart';

class ProfesorEstadisticas extends StatelessWidget {
  final Map<String, dynamic> data;

  const ProfesorEstadisticas({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),  
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titulo
          Text(
            "Estadísticas del Profesor",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Promedio de Calificaciones Recibidas
          Card(
            elevation: 4,  // Sombra sutil
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),  // Bordes redondeados
            ),
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Icon(Icons.star_rate, color: Colors.amber[700]),  // Ícono
              title: Text(
                "Promedio de Calificaciones Recibidas",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                "${data['promProfe']}",
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),

          // Tutorías Completadas
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Icon(Icons.assignment_turned_in, color: Colors.green[600]),  // Ícono
              title: Text(
                "Tutorías Completadas",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                "${data['tutoriasCompletadas']}",
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),

          // Tareas Asignadas
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Icon(Icons.assignment, color: Colors.blue[600]),  // Ícono
              title: Text(
                "Tareas Asignadas",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                "${data['tareasAsignadas']}",
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),

          // Nota Seguimiento Asignadas
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Icon(Icons.grade, color: Colors.orange[600]),  // Ícono
              title: Text(
                "Nota Seguimiento Asignadas",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                "${data['notasSeguimiento']}",
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),

          // Alumnos Totales
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Icon(Icons.group, color: Colors.purple[600]),  // Ícono
              title: Text(
                "Alumnos Totales",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                "${data['cantAlumnos']}",
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
