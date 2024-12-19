import 'package:flutter/material.dart';
import 'package:mentorme/src/utils/responsive.dart';
import 'package:shared_preferences/shared_preferences.dart'; 

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  Future<void> _cerrarSesion() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('rol');
    prefs.remove('userid');
    prefs.remove('isLoggedIn');
    prefs.remove('email');
    prefs.remove('nombre');
  }

  @override
  Widget build(BuildContext context) {
    final Responsive responsive = Responsive.of(context);

    return Scaffold(
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
                'Bienvenido, Admin!',
                style: TextStyle(
                  fontSize: responsive.dp(2.4), 
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: responsive.hp(4)), 

              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, 'crearMateria');
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
                child: const Text('Crear Materia'),
              ),
              SizedBox(height: responsive.hp(2)), 

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
                onPressed: () async {
                  await _cerrarSesion();
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
