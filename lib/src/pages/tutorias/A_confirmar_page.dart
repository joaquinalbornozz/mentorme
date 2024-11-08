import 'package:flutter/material.dart';
import 'package:mentorme/src/database/database.dart';
import 'package:mentorme/src/models/tutoria.dart';
import 'package:mentorme/src/models/user.dart';
import 'package:mentorme/src/pages/tutorias/confirmar_tutoria_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfirmarPage extends StatefulWidget {
  const ConfirmarPage({super.key});

  @override
  _ConfirmarPageState createState() => _ConfirmarPageState();
}

class _ConfirmarPageState extends State<ConfirmarPage> {
  List<Tutoria> tutorias = [];
  List<String> nombresAlumnos = [];
  List<String> materias = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTutorias();
  }

  Future<void> fetchTutorias() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int? idProfesor = prefs.getInt('userid');

    // Fetch all tutorias where confirmation is pending and assigned to this professor
    final List<Tutoria> allTutorias = await MentorMeDatabase.instance.getTutorias();
    final List<Tutoria> pendientes = allTutorias
        .where((tutoria) => !tutoria.confirmada && tutoria.idProfesor == idProfesor)
        .toList();

    List<String> fetchedNombresAlumnos = [];

    // Asynchronously fetch student names and subject details
    for (var tutoria in pendientes) {
      //print(tutoria.toMap());
      User? userAlumno = await MentorMeDatabase.instance.getUserbyId(tutoria.idAlumno);
      if (userAlumno != null) {
        fetchedNombresAlumnos.add(userAlumno.nombre);
        
      } else {
        fetchedNombresAlumnos.add('Alumno Desconocido');
      }
    }

    setState(() {
      tutorias = pendientes;
      nombresAlumnos = fetchedNombresAlumnos;
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
                      'Tutorías a Confirmar',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    tutorias.isEmpty
                        ? const Text('No tienes tutorías pendientes de confirmación.',
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
                                      'Alumno: ${nombresAlumnos[index]}',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                      'Fecha: ${tutoria.dia.toLocal()}',
                                    ),
                                    trailing: const Icon(Icons.arrow_forward),
                                    onTap: () async {
                                      final String resultado= await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ConfirmarTutoriaPage(tutoria: tutoria),
                                        ),
                                      );
                                      fetchTutorias();
                                      if(resultado=='confirmada'){
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                              content:
                                                  Text('La Tutoria fue Confirmada')),
                                        );
                                      }else{
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                              content:
                                                  Text('La Tutoria fue rechazada')),
                                        );
                                      }
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                  ],
                ),
              ),
            ),
    );
  }
}
