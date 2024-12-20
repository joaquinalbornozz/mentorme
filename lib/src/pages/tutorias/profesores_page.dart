import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mentorme/src/models/materia.dart';
import 'package:mentorme/src/models/user.dart';
import 'package:mentorme/src/pages/tutorias/profesor_page.dart';
import 'package:mentorme/src/services/firebase_services.dart';

class ProfesoresPage extends StatefulWidget {
  const ProfesoresPage({super.key});

  @override
  State<ProfesoresPage> createState() => _ProfesoresPageState();
}

class _ProfesoresPageState extends State<ProfesoresPage> {
  List<User> profesores = [];
  List<User> filteredProfesores = [];
  bool isLoading = true;
  List<Materia> materias = [];
  Materia? selectedMateria;

  @override
  void initState() {
    super.initState();
    _loadProfesores();
  }

  Future<void> _loadProfesores() async {
    final profesorList = await FirebaseServices.instance.getProfesores();
    final mat = await FirebaseServices.instance.getAllMateriasFB();
    setState(() {
      profesores = profesorList;
      filteredProfesores = profesorList; // Inicialmente, mostrar todos
      materias = mat;
      isLoading = false;
    });
  }

  void _filterProfesoresByMateria(Materia? materia) {
    setState(() {
      selectedMateria = materia;
      if (materia != null) {
        filteredProfesores = profesores
            .where((profesor) =>
                profesor.idMateria != null &&
                profesor.idMateria!.contains(materia.id))
            .toList();
      } else {
        filteredProfesores = profesores;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profesores')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: DropdownButton<Materia>(
                    isExpanded: true,
                    value: selectedMateria,
                    hint: const Text('Filtrar por materia'),
                    items: [
                      const DropdownMenuItem<Materia>(
                        value: null,
                        child: Text('Todas las materias'),
                      ),
                      ...materias.map((materia) {
                        return DropdownMenuItem<Materia>(
                          value: materia,
                          child: Text(materia.nombre),
                        );
                      }).toList(),
                    ],
                    onChanged: (materia) => _filterProfesoresByMateria(materia),
                  ),
                ),
                Expanded(
                  child: filteredProfesores.isNotEmpty
                      ? ListView.builder(
                          itemCount: filteredProfesores.length,
                          itemBuilder: (context, index) {
                            final profesor = filteredProfesores[index];
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
                                      builder: (context) => ProfesorDetallePage(profesor: profesor,materias: materias,),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Text(
                            "No hay profesores para la materia seleccionada",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.amber[800], fontSize: 20),
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}
