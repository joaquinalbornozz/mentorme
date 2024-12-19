import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mentorme/src/models/user.dart';
import 'package:mentorme/src/pages/tutorias/detalleseguimiento_page.dart';
import 'package:mentorme/src/services/firebase_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SeguimientoPorProfesorPage extends StatefulWidget {
  const SeguimientoPorProfesorPage({super.key});

  @override
  State<SeguimientoPorProfesorPage> createState() =>
      _SeguimientoPorProfesorPageState();
}

class _SeguimientoPorProfesorPageState
    extends State<SeguimientoPorProfesorPage> {
  List<User> profesores = [];

  @override
  void initState() {
    super.initState();
    _loadProfesores();
  }

  Future<void> _loadProfesores() async {
    // Load professors who have had tutoring sessions with the student
    final db = FirebaseServices.instance;
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userid');
    final profesorList = await db.getProfesoresPorAlumno(userId!);
    setState(() {
      profesores = profesorList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seguimiento por Profesor')),
      body: ListView.builder(
        itemCount: profesores.length,
        itemBuilder: (context, index) {
          final profesor = profesores[index];
          return Card(
            child: Row(
              children: [
                CircleAvatar(
                    radius: 10,
                    backgroundImage: profesor.fotoperfil != null &&
                            profesor.fotoperfil!.isNotEmpty
                        ? MemoryImage(base64Decode(profesor.fotoperfil!))
                        : const AssetImage("assets/images/user.png")),
                ListTile(
                  title: Text(profesor.nombre),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DetalleSeguimientoPage(profesor: profesor),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
