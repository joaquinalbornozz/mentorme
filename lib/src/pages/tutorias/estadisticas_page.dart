// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:mentorme/src/models/materia.dart';
import 'package:mentorme/src/models/user.dart';
import 'package:mentorme/src/pages/tutorias/estadisticaAlumno_page.dart';
import 'package:mentorme/src/pages/tutorias/estadisticasprofesor_page.dart';
import 'package:mentorme/src/services/firebase_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EstadisticasPage extends StatefulWidget {
  const EstadisticasPage({super.key});

  @override
  _EstadisticasPageState createState() => _EstadisticasPageState();
}

class _EstadisticasPageState extends State<EstadisticasPage> {
  bool isAlumno = false;
  User? user;
  Map<String, dynamic> data = {}; 

  @override
  void initState() {
    super.initState();
    checkUserRole();
  }

  Future<User?> getUsuario() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userid = prefs.getString('userid');
    if (userid == null) {
      navigateToWelcome();
      return null;
    }
    final db = FirebaseServices.instance;
    User? alu = await db.getUserById(userid);
    return alu;
  }

  Future<void> checkUserRole() async {
    final usuario = await getUsuario();
    if (usuario == null) return;
    
    setState(() {
      user = usuario;
      isAlumno = user?.rol == 'Alumno';
    });

    if (isAlumno) {
      await estadisticaAlumno();
    } else {
      await estadisticasProfesor();
    }
  }

  Future<void> estadisticaAlumno() async {
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        navigateToWelcome();
      });
      return;
    }
    final db = FirebaseServices.instance;
    List<Map<String,dynamic>> tutorias = await db.getTutorias('Alumno',user!.id!);

    num totalCalificacion = 0;
    int tutoriasCompletadas = 0;
    Map<String, int> materias = {};

    for (var t in tutorias) {
      totalCalificacion += t['calificacionalumno'] ?? 1;
      if (t['dia'].isBefore(DateTime.now())) tutoriasCompletadas++;

      Materia? materia = await db.getMateriaById(t['idMateria']);

      if (materia != null) {
        materias[materia.nombre] = (materias[materia.nombre] ?? 0) + 1;
      }
    }

    Map<String, double> porcentajes = {};
    for (var mat in materias.keys) {
      porcentajes[mat] = (materias[mat]! * 100) / tutoriasCompletadas;
    }

    double promedioCalificaciones = tutorias.isNotEmpty 
        ? totalCalificacion / tutorias.length 
        : 0;

    setState(() {
      data['promAlu'] = promedioCalificaciones;
      data['tutoriasCompletadas'] = tutoriasCompletadas;
      data['progresoPorMateria'] = materias;
      data['porcentajesTuto'] = porcentajes;
    });
  }

  Future<void> estadisticasProfesor() async {
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        navigateToWelcome();
      });
      return;
    }
    final db = FirebaseServices.instance;
    List<Map<String,dynamic>> tutorias = await db.getTutorias('Profesor',user!.id!);

    num totalCalificacion = 0;
    int tutoriasCompletadas = 0;
    int tareasAsignadas = 0;
    int notasSeguimiento = 0;
    int cantAlumnos = 0;
    List<int> idAlumnos = [];

    for (var t in tutorias) {
      totalCalificacion += t['calificacionProfesor'] ?? 0;
      if (t['dia'].isBefore(DateTime.now())) tutoriasCompletadas++;
      if (t['tareasAsignadas']?.isNotEmpty ?? false) tareasAsignadas++;
      if (t['notasSeguimiento']?.isNotEmpty ?? false) notasSeguimiento++;
      
      if (!idAlumnos.contains(t['idAlumno'])) {
        idAlumnos.add(t['idAlumno']);
        cantAlumnos++;
      }
    }

    double promedioCalificaciones = tutorias.isNotEmpty 
        ? totalCalificacion / tutorias.length 
        : 0;

    setState(() {
      data['promProfe'] = promedioCalificaciones;
      data['tutoriasCompletadas'] = tutoriasCompletadas;
      data['tareasAsignadas'] = tareasAsignadas;
      data['notasSeguimiento'] = notasSeguimiento;
      data['cantAlumnos'] = cantAlumnos;
    });
  }

  void navigateToWelcome() {
    Navigator.pushNamed(context, 'welcome');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isAlumno
              ? AlumnoEstadisticas(data: data)
              : ProfesorEstadisticas(data: data),
        ],
      ),
    );
  }
}
