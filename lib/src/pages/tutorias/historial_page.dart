import 'package:flutter/material.dart';
import 'package:mentorme/src/database/database.dart';
import 'package:mentorme/src/models/materia.dart';
import 'package:mentorme/src/models/tutoria.dart';
import 'package:mentorme/src/models/user.dart';
import 'package:mentorme/src/pages/tutorias/tutoria_page.dart';
import 'package:mentorme/src/utils/responsive.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistorialPage extends StatefulWidget {
  const HistorialPage({super.key});

  @override
  _HistorialPageState createState() => _HistorialPageState();
}

class _HistorialPageState extends State<HistorialPage> {
  List<Tutoria> tutorias = [];
  List<String> nombresAlu=[];
  List<String> nombresProf=[];
  List<String> materias=[];
  String? rol; // Role can be either 'Alumno' or 'Profesor'
  String? userName; // Either the student or professor name
  int? userid;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTutorias();
  }

  Future<void> fetchTutorias() async {  // Retrieve role and user information from SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    rol = prefs.getString('rol');
    userName = prefs.getString('nombre');
    userid= prefs.getInt('userid');
    if(userid==null){
      Navigator.pushNamed(context, 'welcome');
    }
    

    final List<Tutoria> allTutorias = await MentorMeDatabase.instance.getTutorias();
    final List<Tutoria> confirmedTutorias = rol=='Profesor'
                                              ? allTutorias.where((tutoria) => tutoria.confirmada).where((tutoria)=> tutoria.idProfesor==userid).where((tutoria)=> tutoria.dia.isBefore(DateTime.now())).toList()
                                              :allTutorias.where((tutoria) => tutoria.confirmada).where((tutoria)=> tutoria.idAlumno==userid).where((tutoria)=> tutoria.dia.isBefore(DateTime.now())).toList();

    List<String> fetchedNombresAlu = [];
    List<String> fetchedNombresProf = [];
    List<String> fetchedMaterias = [];

    for (var tutoria in confirmedTutorias) {
      if (rol=='Profesor') {
        User? userAlu = await MentorMeDatabase.instance.getUserbyId(tutoria.idAlumno);
        fetchedNombresAlu.add(userAlu?.nombre ?? 'Desconocido');
      }else{
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
    }

    // Update state once all data is fetched
    setState(() {
      tutorias = confirmedTutorias;
      nombresAlu = fetchedNombresAlu;
      nombresProf = fetchedNombresProf;
      materias = fetchedMaterias;
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
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Acá encuentras las tutorías que has tomado',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400,color: Colors.amber[900]),
                  ),
                  const SizedBox(height: 20),
                  tutorias.isEmpty
                      ? const Text('No has tenido tutorías hasta el momento.',
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
                                    rol == 'Profesor'
                                        ? 'Alumno: ${nombresAlu[index]}' // Use fetched student name
                                        : 'Profesor: ${nombresProf[index]}', // Use fetched professor name
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  
                                  subtitle: rol == 'Alumno'
                                              ?Text('Materia: ${materias[index]}\n''Fecha: ${tutoria.dia.toLocal()}')
                                              :Text('Fecha: ${tutoria.dia.toLocal()}'),
                                  onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => TutoriaPage(tutoria: tutoria),
                                        ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ],
              ),
            ),
    );
  }

}
