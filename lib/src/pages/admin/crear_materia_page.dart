import 'package:flutter/material.dart';
import 'package:mentorme/src/database/database.dart';
import 'package:mentorme/src/utils/responsive.dart'; // Importar el archivo responsive.dart

import '../../models/materia.dart';

class CrearMateriaPage extends StatefulWidget {
  const CrearMateriaPage({super.key});

  @override
  _CrearMateriaPageState createState() => _CrearMateriaPageState();
}

class _CrearMateriaPageState extends State<CrearMateriaPage> {
  final TextEditingController _nombreController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Instanciar Responsive para obtener medidas del dispositivo
    final Responsive responsive = Responsive.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Materia'),
      ),
      body: Center( // Utilizar Center para centrar el contenido
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: responsive.wp(5), // Márgenes horizontales responsivos
            vertical: responsive.hp(3),   // Márgenes verticales responsivos
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Centramos verticalmente
            crossAxisAlignment: CrossAxisAlignment.center, // Centramos horizontalmente
            children: [
              Text(
                'Crea una nueva Materia',
                style: TextStyle(
                  fontSize: responsive.dp(2.4), // Tamaño de texto responsivo
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: responsive.hp(4)), 
              TextField(
                controller: _nombreController,
                decoration: InputDecoration(
                  labelText: 'Nombre de la Materia',
                  border: const OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: responsive.wp(3), // Padding interno responsivo
                    vertical: responsive.hp(2),
                  ),
                ),
              ),
              SizedBox(height: responsive.hp(4)), // Espaciado responsivo

              ElevatedButton(
                onPressed: () {
                  // Validar que el nombre no esté vacío
                  if (_nombreController.text.isNotEmpty) {
                    _crearMateria(_nombreController.text);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Por favor, ingresa un nombre.')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.wp(10), // Ancho del botón responsivo
                    vertical: responsive.hp(2),    // Altura del botón responsivo
                  ),
                  textStyle: TextStyle(
                    fontSize: responsive.dp(1.8), // Tamaño de texto responsivo
                  ),
                  backgroundColor: Colors.orange, // Color de fondo del botón
                ),
                child: const Text('Guardar Materia'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Método para crear una nueva materia (aquí se debería hacer la inserción en la BD)
  Future<void> _crearMateria(String nombre) async {
    Materia mat = Materia(nombre: nombre);
    await MentorMeDatabase.instance.insertMateria(mat);
    Navigator.pop(context);
  }
}
