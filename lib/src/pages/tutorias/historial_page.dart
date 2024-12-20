import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mentorme/src/models/materia.dart';
import 'package:mentorme/src/models/tutoria.dart';
import 'package:mentorme/src/models/user.dart';
import 'package:mentorme/src/pages/tutorias/tutoria_page.dart';
import 'package:mentorme/src/services/firebase_services.dart';
import 'package:mentorme/src/utils/responsive.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistorialPage extends StatefulWidget {
  const HistorialPage({super.key});

  @override
  _HistorialPageState createState() => _HistorialPageState();
}

class _HistorialPageState extends State<HistorialPage> {
  List<Map<String,dynamic>> tutorias = [];
  String? rol; // Role can be either 'Alumno' or 'Profesor'
  String? userName; // Either the student or professor name
  String? userid;
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
    userid= prefs.getString('userid');
    if(userid==null){
      Navigator.pushNamed(context, 'welcome');
    }
    

    final List<Map<String,dynamic>> allTutorias = await FirebaseServices.instance.getTutorias(rol!, userid!);
    final List<Map<String,dynamic>> confirmedTutorias = allTutorias.where((tutoria) {return tutoria['confirmada'] && DateTime.parse(tutoria['dia']).isBefore(DateTime.now()); }).toList();
    confirmedTutorias.sort((a,b)=>DateTime.parse(a['dia']).compareTo(DateTime.parse(b['dia'])));
    for (var tutoria in confirmedTutorias) {
      tutoria['tutoria'] =Tutoria.fromMap(tutoria);
      if (rol=='Profesor') {
        User? userAlu = await FirebaseServices.instance.getUserById(tutoria['idAlumno']);
        tutoria['nombreAlu']= userAlu?.nombre;
      }else{
        User? userPro = await FirebaseServices.instance.getUserById(tutoria['idProfesor']);
        tutoria['nombrePro']= userPro?.nombre;
      }
      Materia? materia = await FirebaseServices.instance.getMateriaById(tutoria['idMateria']);
      tutoria['nombreMateria']= materia?.nombre;
    }

    setState(() {
      tutorias = confirmedTutorias;
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
                                        ? 'Alumno: ${tutoria['nombreAlu']}' 
                                        : 'Profesor: ${tutoria['nombrePro']}', 
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  
                                  subtitle:Text('Materia: ${tutoria['nombreMateria']}\n''Fecha: ${DateFormat('dd/MM/yyyy')
                                    .format(tutoria['tutoria'].dia)}'),
                                  onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => TutoriaPage(tutoria: tutoria['tutoria']),
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
