import 'package:flutter/material.dart';
import 'package:mentorme/src/database/database.dart';

import '../../models/materia.dart';

class ModificarMateriaPage extends StatefulWidget {
  final Materia materia;

  const ModificarMateriaPage({super.key, required this.materia});

  @override
  // ignore: library_private_types_in_public_api
  _ModificarMateriaPageState createState() => _ModificarMateriaPageState();
}

class _ModificarMateriaPageState extends State<ModificarMateriaPage> {
  late TextEditingController _nombreController;

  @override
  void initState() {
    super.initState();
    // Inicializamos el controlador con el nombre actual de la materia
    _nombreController = TextEditingController(text: widget.materia.nombre);
  }

  @override
  void dispose() {
    // Liberar el controlador cuando ya no se necesite
    _nombreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modificar Materia'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(
                labelText: 'Nombre de la Materia',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _modificarMateria(context);
              },
              child: const Text('Guardar Cambios'),
            ),
          ],
        ),
      ),
    );
  }

  // Método para modificar la materia
  Future<void> _modificarMateria(BuildContext context) async {
    if (_nombreController.text.isNotEmpty) {
      Materia materia= Materia(id:widget.materia.id,nombre:_nombreController.text);
      await MentorMeDatabase.instance.updateMateria(materia);
      Navigator.pop(context,true);
    } else {
      // Si el nombre está vacío, mostrar un mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre no puede estar vacío')),
      );
    }
  }
}
