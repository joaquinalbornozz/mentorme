import 'package:flutter/material.dart';
import 'package:mentorme/src/utils/responsive.dart'; // Importar el archivo responsive.dart

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Instanciar Responsive para obtener medidas del dispositivo
    final Responsive responsive = Responsive.of(context);

    return Scaffold(
      body: Center( // Utilizar Center para centrar el contenido
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: responsive.wp(5), // Márgenes horizontales responsivos
            vertical: responsive.hp(3),   // Márgenes verticales responsivos
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Centramos los elementos verticalmente
            crossAxisAlignment: CrossAxisAlignment.center, // Centramos los elementos horizontalmente
            children: [
              Text(
                'Bienvenido, Admin!',
                style: TextStyle(
                  fontSize: responsive.dp(2.4), // Tamaño de texto responsivo
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: responsive.hp(4)), // Espaciado responsivo

              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, 'crearMateria');
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
                child: const Text('Crear Materia'),
              ),
              SizedBox(height: responsive.hp(2)), // Espaciado responsivo

              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, 'modificarMaterias');
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.wp(7.5),
                    vertical: responsive.hp(2),
                  ),
                  textStyle: TextStyle(
                    fontSize: responsive.dp(1.8),
                  ),
                  backgroundColor: Colors.orange,
                ),
                child: const Text('Modificar Materias'),
              ),
              SizedBox(height: responsive.hp(2)),

              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/');
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
                child: const Text('Cerrar Sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
