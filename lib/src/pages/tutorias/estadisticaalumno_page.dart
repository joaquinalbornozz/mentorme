import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AlumnoEstadisticas extends StatelessWidget {
  final Map<String, dynamic> data;

  const AlumnoEstadisticas({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Promedio de Calificaciones Recibidas: ${data['promAlu'] ?? 'N/A'}",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Tutorías Completadas: ${data['tutoriasCompletadas'] ?? 'N/A'}",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          const Text(
            "Progreso por Materia:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          data['progresoPorMateria'] != null
              ? Column(
                  children: data['progresoPorMateria'].keys.map<Widget>((key) {
                    final value = data['progresoPorMateria'][key];
                    return ListTile(
                      title: Text(key),
                      trailing: Text('$value tutorías'),
                    );
                  }).toList(),
                )
              : const Text("No hay datos de progreso por materia."),
          const SizedBox(height: 20),
          const Text(
            "Porcentaje de Tutorías Completadas por Materia:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          data['porcentajesTuto'] != null && data['porcentajesTuto'].isNotEmpty
              ? _buildPieChart(data['porcentajesTuto'])
              : const Text("No hay datos de porcentajes de tutorías completadas."),
        ],
      ),
    );
  }

  // Función para construir el gráfico de torta
  Widget _buildPieChart(Map<String, double> porcentajes) {
    List<PieChartSectionData> sections = porcentajes.keys.map((key) {
      final value = porcentajes[key];
      return PieChartSectionData(
        title: '${value?.toStringAsFixed(1)}%',
        value: value ?? 0,
        color: _getColorForSubject(key),
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return SizedBox(
      height: 250,
      child: PieChart(
        PieChartData(
          sections: sections,
          centerSpaceRadius: 40,
          sectionsSpace: 2,
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  // Función para asignar un color a cada materia
  Color _getColorForSubject(String subject) {
    final colors = [
      Colors.blueAccent,
      Colors.green,
      Colors.redAccent,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];
    return colors[subject.hashCode % colors.length];
  }
}
