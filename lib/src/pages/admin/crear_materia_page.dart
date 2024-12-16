import 'package:flutter/material.dart';
import 'package:mentorme/src/services/firebase_services.dart';
import 'package:mentorme/src/utils/responsive.dart'; 

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
    final Responsive responsive = Responsive.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Materia'),
      ),
      body: Center( 
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: responsive.wp(5), 
            vertical: responsive.hp(3),   
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, 
            crossAxisAlignment: CrossAxisAlignment.center, 
            children: [
              Text(
                'Crea una nueva Materia',
                style: TextStyle(
                  fontSize: responsive.dp(2.4), 
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
                    horizontal: responsive.wp(3), 
                    vertical: responsive.hp(2),
                  ),
                ),
              ),
              SizedBox(height: responsive.hp(4)), 

              ElevatedButton(
                onPressed: () {
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
                    horizontal: responsive.wp(10), 
                    vertical: responsive.hp(2),   
                  ),
                  textStyle: TextStyle(
                    fontSize: responsive.dp(1.8),
                  ),
                  backgroundColor: Colors.orange, 
                ),
                child: const Text('Guardar Materia'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _crearMateria(String nombre) async {
    Materia mat = Materia(nombre: nombre);
    await FirebaseServices.instance.insertarMateria(mat);
    Navigator.pop(context);
  }
}
