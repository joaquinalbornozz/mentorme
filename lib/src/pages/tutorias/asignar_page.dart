import 'package:flutter/material.dart';
import 'package:mentorme/src/database/database.dart';
import 'package:mentorme/src/models/tutoria.dart';
import 'package:mentorme/src/models/user.dart';
import 'package:mentorme/src/pages/tutorias/confirmar_tutoria_page.dart';
import 'package:mentorme/src/utils/responsive.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AsignarTareasPage extends StatefulWidget {
  const AsignarTareasPage({super.key});

  @override
  _AsignarTareasPageState createState() => _AsignarTareasPageState();
}

class _AsignarTareasPageState extends State<AsignarTareasPage> {
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

    final List<Tutoria> allTutorias = await MentorMeDatabase.instance.getTutorias();
    final List<Tutoria> pendientes = allTutorias
        .where((tutoria) => !tutoria.confirmada && tutoria.idProfesor == idProfesor)
        .where((tutoria)=> tutoria.dia.isBefore(DateTime.now()) && (tutoria.devolucion==null || tutoria.notasSeguimiento==null || tutoria.tareasAsignadas==null))
        .toList();

    List<String> fetchedNombresAlumnos = [];

    for (var tutoria in pendientes) {
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
    final responsive = Responsive.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Historial de Tutorias',
          style: TextStyle(fontSize: responsive.dp(2.5), fontWeight: FontWeight.w500, color: Colors.amber[800]),
        ),
        centerTitle: true,
      ),
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
                      'Asignar tareas, devoluciones y notas de Seguimiento',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    tutorias.isEmpty
                        ? const Text('No tienes tutorías para asignar tareas.',
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
