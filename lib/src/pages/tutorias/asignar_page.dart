import 'package:flutter/material.dart';
import 'package:mentorme/src/models/materia.dart';
import 'package:mentorme/src/models/tutoria.dart';
import 'package:mentorme/src/models/user.dart';
import 'package:mentorme/src/pages/tutorias/tutoria_page.dart';
import 'package:mentorme/src/services/firebase_services.dart';
import 'package:mentorme/src/utils/responsive.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AsignarTareasPage extends StatefulWidget {
  const AsignarTareasPage({super.key});

  @override
  _AsignarTareasPageState createState() => _AsignarTareasPageState();
}

class _AsignarTareasPageState extends State<AsignarTareasPage> {
  List<Map<String,dynamic>> tutorias = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTutorias();
  }

  Future<void> fetchTutorias() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? idProfesor = prefs.getString('userid');

    final List<Map<String,dynamic>> allTutorias = await FirebaseServices.instance.getTutorias('Profesor',idProfesor!);
    final List<Map<String,dynamic>> pendientes = allTutorias
        .where((tutoria) => !tutoria['confirmada'])
        .where((tutoria)=> DateTime.parse(tutoria['dia']).isBefore(DateTime.now()) && (tutoria['devolucion']==null || tutoria['notasSeguimiento']==null || tutoria['tareasAsignadas']==null))
        .toList();
    for (var tutoria in pendientes) {
      tutoria['tutoria']=Tutoria.fromMap(tutoria);
      User? userAlumno = await FirebaseServices.instance.getUserById(tutoria['idAlumno']);
      tutoria['nombreAlu']=userAlumno?.nombre ?? "Descononocido";
      Materia? materia= await FirebaseServices.instance.getMateriaById(tutoria['idMateria']);
      tutoria['nombreMateria']=materia?.nombre?? "Materia Desconocida";
    }

    setState(() {
      tutorias = pendientes;
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
                                      'Alumno: ${tutoria['nombreAlu']}',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                      'Materia: ${tutoria['nombreMateria']} \n Fecha: ${tutoria['tutoria'].dia.toLocal()}',
                                    ),
                                    trailing: const Icon(Icons.arrow_forward),
                                    onTap: () async {
                                      final String resultado= await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => TutoriaPage(tutoria: tutoria['tutoria']),
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
