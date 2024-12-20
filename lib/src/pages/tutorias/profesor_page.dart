import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mentorme/src/models/materia.dart';
import 'package:mentorme/src/models/user.dart';
import 'package:mentorme/src/pages/tutorias/requesttutoria.dart';

class ProfesorDetallePage extends StatelessWidget {
  final User profesor;
  final List<Materia> materias;

  const ProfesorDetallePage({
    super.key,
    required this.profesor,
    required this.materias,
  });

  @override
  Widget build(BuildContext context) {
    final profesorMaterias = materias
        .where((materia) =>
            profesor.idMateria != null &&
            profesor.idMateria!.contains(materia.id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Profesor'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Foto de perfil
                CircleAvatar(
                  radius: 60,
                  backgroundImage: profesor.fotoperfil != null &&
                          profesor.fotoperfil!.isNotEmpty
                      ? MemoryImage(base64Decode(profesor.fotoperfil!))
                      : const AssetImage("assets/images/user.png")
                          as ImageProvider,
                ),
                const SizedBox(height: 16),
                // Nombre del profesor
                Text(
                  profesor.nombre,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                // Información general
                Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Descripción',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          profesor.descripcion ?? "No disponible",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                // Horario
                Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Horario',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          profesor.horario ?? "No disponible",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                // Materias que da el profesor
                Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Materias que asiste',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ...profesorMaterias.map((materia) => Text(
                              materia.nombre,
                              style: const TextStyle(fontSize: 16),
                            )),
                        if (profesorMaterias.isEmpty)
                          const Text(
                            "No disponible",
                            style: TextStyle(fontSize: 16),
                          ),
                      ],
                    ),
                  ),
                ),
                // Contacto
                Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Contacto',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Email: ${profesor.email}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Teléfono: ${profesor.telefono}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final materiaSeleccionada =
                          await _mostrarSelectorDeMateria(
                              context, profesor.id!, profesorMaterias);
                      if (materiaSeleccionada != null) {
                        final a= await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NuevaTutoriaPage(
                              profesorId: profesor.id,
                              materiaId: materiaSeleccionada,
                            ),
                          ),
                        );
                        if(a==true){
                          ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  '¡Tutoria Solicitada!')),
                                        );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Solicitar Tutoria',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<String?> _mostrarSelectorDeMateria(
      BuildContext context, String profesorId, List<Materia> materias) async {
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Selecciona una materia'),
          content: SingleChildScrollView(
            // Agregar el SingleChildScrollView
            child: ListBody(
              children: materias.map((materia) {
                return ListTile(
                  title: Text(materia.nombre),
                  onTap: () {
                    Navigator.pop(context, materia.id);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
