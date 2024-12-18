import 'package:flutter/material.dart';
import 'package:mentorme/src/models/materia.dart';
import 'package:mentorme/src/models/tutoria.dart';
import 'package:mentorme/src/models/user.dart';
import 'package:mentorme/src/pages/tutorias/tutoria_page.dart';
import 'package:mentorme/src/services/firebase_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PendientesPage extends StatefulWidget {
  const PendientesPage({super.key});

  @override
  _PendientesPageState createState() => _PendientesPageState();
}

class _PendientesPageState extends State<PendientesPage> {
  List<Map<String,dynamic>> tutorias = [];
  String? rol; 
  String? userName; 
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTutorias();
  }

  Future<void> fetchTutorias() async { 
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    rol = prefs.getString('rol');
    userName = prefs.getString('nombre');
    String? idAlumno = prefs.getString('userid');
    if (idAlumno == null) {
      Navigator.pushNamed(context, 'welcome');
      return;
    }
    final List<Map<String, dynamic>> allTutorias = await FirebaseServices.instance.getTutorias(rol!,idAlumno);
    final List<Map<String,dynamic>> pendientes = allTutorias.where((tutoria) {return !tutoria['confirmada'];}).toList();

    

    for (var tutoria in pendientes) {
      tutoria['tutoria']=Tutoria.fromMap(tutoria);
      User? userPro = await FirebaseServices.instance.getUserById(tutoria['idProfesor']);
      if (userPro != null) {
        tutoria['nombrePro']=userPro.nombre;
        Materia? materia = await FirebaseServices.instance.getMateriaById(tutoria['idMateria']);
        tutoria['nombreMateria']=materia?.nombre ?? "Materia Desconocida";
      } 
    }

    setState(() {
      tutorias = pendientes;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
            onRefresh: fetchTutorias,
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tutorias no Confrimadas',
                      style:  TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'Debes esperar que tu Profesor/a confirme',
                      style:  TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 20),
                    tutorias.isEmpty
                        ? const Text('No tienes tutorías pendientes.',
                            style: TextStyle(fontSize: 16, color: Colors.grey))
                        : Expanded(
                            child: ListView.builder(
                              itemCount: tutorias.length,
                              itemBuilder: (context, index) {
                                final tutoria = tutorias[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(vertical: 10),
                                  child: ListTile(
                                    title: Text(
                                      'Profesor: ${tutoria['nombrePro']}', 
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text('Materia: ${tutoria['nombreMateria']}\n'
                                        'Fecha: ${tutoria['tutoria'].dia.toLocal()}'),
                                  onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => TutoriaPage(tutoria: tutoria['tutoria']),
                                        ),
                                  ),
                                  )
                                );
                                
                              },
                            ),
                          ),
                  ],
                ),
              ),
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, 'requestTutoria');
          if (result == true) {
            fetchTutorias(); 
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

}
