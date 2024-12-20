import 'package:flutter/material.dart';
import 'package:mentorme/src/models/materia.dart';
import 'package:mentorme/src/services/firebase_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AgregarMateriasPage extends StatefulWidget {

  const AgregarMateriasPage({super.key});

  @override
  _AgregarMateriasPageState createState() => _AgregarMateriasPageState();
}

class _AgregarMateriasPageState extends State<AgregarMateriasPage> {
  List<Materia> materiasDisponibles = [];
  List<String> materiasSeleccionadas = []; 
  String? userid;

  @override
  void initState() {
    super.initState();
    _cargarMateriasDisponibles();
  }

  Future<void> _cargarMateriasDisponibles() async {
    final shared= await SharedPreferences.getInstance();
    final u =shared.getString('userid');
    if(u==null) Navigator.pushNamed(context, 'welcome');
    List<Materia> materias= await FirebaseServices.instance.getAllMateriasFB();
    final materiasAsignadas = await FirebaseServices.instance.getMateriasDelProfesor(u!);
    materias= materias.where((materia) => !materiasAsignadas.contains(materia.id)).toList();
    setState(() {
      materiasDisponibles = materias;
      materiasSeleccionadas = materiasAsignadas;
      userid=u;
    });
  }

  void _guardarMaterias() async {
    await FirebaseServices.instance.updateMateria_Profesor(userid!, materiasSeleccionadas);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Materias'),
      ),
      body: materiasDisponibles.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: materiasDisponibles.length,
                    itemBuilder: (context, index) {
                      final materia = materiasDisponibles[index];
                      final isSelected = materiasSeleccionadas.contains(materia.id);

                      return CheckboxListTile(
                        title: Text(materia.nombre),
                        value: isSelected,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              materiasSeleccionadas.add(materia.id!);
                            } else {
                              materiasSeleccionadas.remove(materia.id);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: materiasSeleccionadas.isEmpty
                        ? null
                        : _guardarMaterias, // Desactivar botón si no hay selección
                    child: const Text('Guardar Materias'),
                  ),
                ),
              ],
            ),
    );
  }
}
