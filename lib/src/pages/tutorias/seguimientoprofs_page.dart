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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfesores();
  }

  Future<void> _loadProfesores() async {
    final db = FirebaseServices.instance;
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userid');
    final profesorList = await db.getProfesoresPorAlumno(userId!);
    setState(() {
      profesores = profesorList;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seguimiento por Profesor')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : profesores.isNotEmpty
              ? ListView.builder(
                  itemCount: profesores.length,
                  itemBuilder: (context, index) {
                    final profesor = profesores[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundImage: profesor.fotoperfil != null &&
                                  profesor.fotoperfil!.isNotEmpty
                              ? MemoryImage(base64Decode(profesor.fotoperfil!))
                              : const AssetImage("assets/images/user.png")
                                  as ImageProvider,
                        ),
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
                    );
                  },
                )
              : Center(
                  child: Text(
                    "No tienes seguimiento con profesores",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.amber[800], fontSize: 20),
                  ),
                ),
    );
  }
}
