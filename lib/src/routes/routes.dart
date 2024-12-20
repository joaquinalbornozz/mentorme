import 'package:flutter/material.dart';
import 'package:mentorme/src/pages/admin/crear_materia_page.dart';
import 'package:mentorme/src/pages/admin/listar_materias_page.dart';
import 'package:mentorme/src/pages/modificar_page.dart';
import 'package:mentorme/src/pages/tutorias/asignar_page.dart';
import 'package:mentorme/src/pages/tutorias/estadisticas_page.dart';
import 'package:mentorme/src/pages/tutorias/historial_page.dart';
import 'package:mentorme/src/pages/tutorias/profesores_page.dart';
import 'package:mentorme/src/pages/tutorias/requesttutoria.dart';
import 'package:mentorme/src/pages/tutorias/seguimientoprofs_page.dart';
import 'package:mentorme/src/pages/welcome_page.dart';
import 'package:mentorme/src/pages/registro_page.dart';
import 'package:mentorme/src/pages/login_page.dart';
import 'package:mentorme/src/pages/home_page.dart';

Map<String, WidgetBuilder> getAplicationRoutes() {
  return <String, WidgetBuilder>{
    '/': (BuildContext context) => const WelcomePage(),
    'registrar':(BuildContext context) => const RegistroPage(),
    'login': (BuildContext context) => const LoginPage(),
    'home': (BuildContext context) => const HomePage(),
    'crearMateria': (BuildContext context) => const CrearMateriaPage(),
    'modificarMaterias': (BuildContext context) => const ListarMateriasPage(),
    'requestTutoria': (BuildContext context) => const NuevaTutoriaPage(),
    'historial':(BuildContext context) => const HistorialPage(),
    'asignar': (BuildContext context) => const AsignarTareasPage(),
    'modificarperfil':(BuildContext context) => const ModificarPerfilPage(),
    'estadistica':(BuildContext context) =>  const EstadisticasPage(),
    'seguimiento': (BuildContext context) => const SeguimientoPorProfesorPage(),
    'profesores': (BuildContext context) => const ProfesoresPage()
  };
}