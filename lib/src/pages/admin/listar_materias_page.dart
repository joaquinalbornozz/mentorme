import 'package:flutter/material.dart';
import 'package:mentorme/src/services/firebase_services.dart';
import 'package:mentorme/src/utils/responsive.dart'; // Importar el archivo responsive.dart
import '../../models/materia.dart';
import 'modificar_materia_page.dart';

class ListarMateriasPage extends StatefulWidget {
  const ListarMateriasPage({super.key});

  @override
  State<ListarMateriasPage> createState() => _ListarMateriasPageState();
}

class _ListarMateriasPageState extends State<ListarMateriasPage> {
  Future<List<Materia>> _getMaterias() async {
    return await FirebaseServices.instance.getAllMateriasFB();
  }

  @override
  Widget build(BuildContext context) {
    final Responsive responsive = Responsive.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Materias'),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: responsive.wp(5), 
          vertical: responsive.hp(2),  
        ),
        child: FutureBuilder<List<Materia>>(
          future: _getMaterias(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              List<Materia> materias = snapshot.data!;
              return ListView.builder(
                itemCount: materias.length,
                itemBuilder: (context, index) {
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 4, 
                    margin: EdgeInsets.symmetric(
                      vertical: responsive.hp(1),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: responsive.wp(4),
                        vertical: responsive.hp(1.5),
                      ),
                      title: Text(
                        materias[index].nombre,
                        style: TextStyle(
                          fontSize: responsive.dp(1.8),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: const Icon(Icons.edit, color: Colors.orange),
                      onTap: () {
                        _navegarAModificarMateria(context, materias[index]);
                      },
                    ),
                  );
                },
              );
            } else {
              return const Center(child: Text('No hay materias disponibles'));
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushReplacementNamed(context,'crearMateria');
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add), 
      ),
    );
  }

  void _navegarAModificarMateria(BuildContext context, Materia materia) async {
    bool result=await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ModificarMateriaPage(materia: materia),
      ),
    );
    if(result) {
      _getMaterias();
    }
  }
}
