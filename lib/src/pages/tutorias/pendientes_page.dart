import 'package:flutter/material.dart';
import 'package:mentorme/src/database/database.dart';
import 'package:mentorme/src/models/materia.dart';
import 'package:mentorme/src/models/tutoria.dart';
import 'package:mentorme/src/models/user.dart';
import 'package:mentorme/src/pages/tutorias/tutoria_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PendientesPage extends StatefulWidget {
  const PendientesPage({super.key});

  @override
  _PendientesPageState createState() => _PendientesPageState();
}

class _PendientesPageState extends State<PendientesPage> {
  List<Tutoria> tutorias = [];
  List<String> nombresProf=[];
  List<String> materias=[];
  String? rol; // Role can be either 'Alumno' or 'Profesor'
  String? userName; // Either the student or professor name
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
    int? idAlumno = prefs.getInt('userid');

    final List<Tutoria> allTutorias = await MentorMeDatabase.instance.getTutorias();
    final List<Tutoria> pendientes = allTutorias.where((tutoria) => !tutoria.confirmada).where((tutoria)=> tutoria.idAlumno==idAlumno).toList();

    List<String> fetchedNombresProf = [];
    List<String> fetchedMaterias = [];

    for (var tutoria in pendientes) {
     
      User? userPro = await MentorMeDatabase.instance.getUserbyId(tutoria.idProfesor);
      if (userPro != null) {
        fetchedNombresProf.add(userPro.nombre);
        Materia? materia = await MentorMeDatabase.instance.getMateriaById(userPro.idMateria);
        fetchedMaterias.add(materia?.nombre ?? 'Materia Desconocida');
      } else {
        fetchedNombresProf.add('Desconocido');
        fetchedMaterias.add('Materia Desconocida');
      }
    }

    setState(() {
      tutorias = pendientes;
      nombresProf = fetchedNombresProf;
      materias = fetchedMaterias;
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
                                      'Profesor: ${nombresProf[index]}', 
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text('Materia: ${materias[index]}\n'
                                        'Fecha: ${tutoria.dia.toLocal()}'),
                                  onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => TutoriaPage(tutoria: tutoria),
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
