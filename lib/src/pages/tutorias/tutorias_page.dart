import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mentorme/src/models/materia.dart';
import 'package:mentorme/src/models/tutoria.dart';
import 'package:mentorme/src/models/user.dart';
import 'package:mentorme/src/pages/tutorias/tutoria_page.dart';
import 'package:mentorme/src/services/firebase_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TutoriasPage extends StatefulWidget {
  const TutoriasPage({super.key});

  @override
  _TutoriasPageState createState() => _TutoriasPageState();
}

class _TutoriasPageState extends State<TutoriasPage> {
  List<Map<String,dynamic>> tutorias = [];
  String? rol; 
  String? userName; 
  String? userid;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTutorias();
  }

  Future<void> fetchTutorias() async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final FirebaseServices db = FirebaseServices.instance;
    rol = prefs.getString('rol');
    userName = prefs.getString('nombre');
    userid = prefs.getString('userid');
    if (userid == null) {
      Navigator.pushNamed(context, 'welcome');
      return;
    }

    final allTutorias = await db.getTutorias(rol!, userid!);
    final confirmedTutorias = allTutorias.where((tutoria) {
      return tutoria['confirmada'] && DateTime.parse(tutoria['dia']).isAfter(DateTime.now());
    }).toList();

    for (var tutoria in confirmedTutorias) {
      tutoria['tutoria'] = Tutoria.fromMap(tutoria);
      if (rol == 'Profesor') {
        User? userAlu = await db.getUserById(tutoria['idAlumno']);
        tutoria['nombreAlu'] = userAlu?.nombre ?? "Desconocido";
      } else {
        User? userPro = await db.getUserById(tutoria['idProfesor']);
        Materia? materia = await db.getMateriaById(tutoria['idMateria']);
        tutoria['nombrePro'] = userPro?.nombre ?? "Desconocido";
        tutoria['nombreMateria'] = materia?.nombre ?? "Materia Desconocida";
      }
    }

    setState(() {
      tutorias = confirmedTutorias;
      isLoading = false;
    });
  } catch (e) {
    print("Error al cargar las tutorías: $e");
    setState(() {
      isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ocurrió un error al cargar las tutorías')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¡Bienvenido, $userName!',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                              final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(tutoria['tutoria'].dia.toDate());
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 10),
                                child: ListTile(
                                  title: Text(
                                    rol == 'Profesor'
                                        ? 'Alumno: ${tutoria['nombreAlu']}' 
                                        : 'Profesor: ${tutoria['nombrePro']}', 
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  
                                  subtitle: Text('Materia: ${tutoria['nombreMateria']}\n''Fecha: $formattedDate'),
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
      floatingActionButton: rol =='Alumno'?FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, 'requestTutoria'); 
        },
        child: const Icon(Icons.add),
      ):null,
    );
  }

}
